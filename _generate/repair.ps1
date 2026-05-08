# Comprehensive repair: state-machine cleanup of PS data files
# Identifies field boundary quotes vs embedded quotes and escapes embedded ones

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$genDir = $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding $false

function Repair-Line {
  param([string]$line)

  # Skip non-data lines
  if ($line -notmatch "^\s*[a-zA-Z]\w*\s*=") { return $line }
  if ($line -match '^\s*#') { return $line }
  if ($line -match '^\s*\w+\s*=\s*@\(') { return $line }
  if ($line -match '^\s*\w+\s*=\s*\d+\s*$') { return $line }

  # Process: split into segments at field boundaries (= ' ' ; or = ' ' end)
  # Field pattern: word=`'content'` followed by ; or end
  # We rebuild the line, escaping any embedded ' inside content

  $result = New-Object System.Text.StringBuilder
  $i = 0
  $len = $line.Length

  while ($i -lt $len) {
    # Find next "key=" pattern
    $rest = $line.Substring($i)
    if ($rest -match '^(\s*)([a-zA-Z]\w*)\s*=\s*') {
      $prefix = $matches[0]
      $key = $matches[2]
      [void]$result.Append($prefix)
      $i += $prefix.Length

      # What's the value type?
      if ($i -lt $len -and $line[$i] -eq "'") {
        # String value: find the END quote (next ' followed by ; or , or end-of-line or })
        [void]$result.Append("'")
        $i++
        $contentStart = $i
        # Scan forward looking for closing quote
        $contentEnd = -1
        while ($i -lt $len) {
          if ($line[$i] -eq "'") {
            # Is this a closing quote? (followed by ; , } or end)
            $j = $i + 1
            while ($j -lt $len -and $line[$j] -eq ' ') { $j++ }
            if ($j -ge $len -or $line[$j] -in @(';', ',', '}')) {
              # Closing quote
              $contentEnd = $i
              break
            } else {
              # Embedded quote — skip past it
              $i++
            }
          } else {
            $i++
          }
        }
        if ($contentEnd -lt 0) { $contentEnd = $len }

        # Content between quotes; escape embedded '
        $content = $line.Substring($contentStart, $contentEnd - $contentStart)
        $content = $content -replace "'", "''"
        [void]$result.Append($content)
        if ($contentEnd -lt $len) {
          [void]$result.Append("'")
          $i = $contentEnd + 1
        }
      }
      elseif ($i -lt $len -and $line[$i] -match '\d') {
        # Number value
        while ($i -lt $len -and $line[$i] -match '[\d\.]') {
          [void]$result.Append($line[$i])
          $i++
        }
      }
      else {
        # Unknown — append rest
        [void]$result.Append($line.Substring($i))
        $i = $len
      }

      # Skip separator (; or end)
      while ($i -lt $len -and $line[$i] -in @(';', ' ', "`t")) {
        [void]$result.Append($line[$i])
        $i++
      }
    } else {
      # Doesn't start with key=, append rest
      [void]$result.Append($line.Substring($i))
      $i = $len
    }
  }
  return $result.ToString()
}

$files = Get-ChildItem "$genDir\*.ps1" -File | Where-Object { $_.Name -notin @("templates.ps1", "run.ps1", "convert_to_json.ps1", "repair.ps1") }

foreach ($file in $files) {
  $lines = Get-Content -Encoding UTF8 $file.FullName
  $newLines = foreach ($line in $lines) { Repair-Line $line }
  $content = ($newLines -join "`n")
  [System.IO.File]::WriteAllText($file.FullName, $content, $utf8)
  Write-Host "Repaired: $($file.Name)"
}

Write-Host ""
Write-Host "Tamamlandı." -ForegroundColor Green
