$dir = "C:\claude\gun2\_generate"
$files = Get-ChildItem "$dir\*.ps1" -File | Where-Object {
    $_.Name -notin @("templates.ps1","run.ps1","convert_to_json.ps1","repair.ps1")
}

foreach ($file in $files) {
    $lines = Get-Content -Encoding UTF8 $file.FullName
    $fixed = @()
    $changed = $false

    foreach ($line in $lines) {
        if ($line -notmatch "=\s*'") { $fixed += $line; continue }
        $sb = New-Object System.Text.StringBuilder
        $i = 0; $len = $line.Length
        while ($i -lt $len) {
            if ($i+1 -lt $len -and $line[$i] -eq '=' -and $line[$i+1] -eq "''") {
                [void]$sb.Append("='"); $i += 2
                $inner = New-Object System.Text.StringBuilder
                while ($i -lt $len) {
                    if ($line[$i] -eq "'") {
                        $j = $i+1
                        while ($j -lt $len -and $line[$j] -eq ' ') { $j++ }
                        if ($j -ge $len -or $line[$j] -in @(';',',','}',')')) { break }
                        else { [void]$inner.Append("''"); $i++ }
                    } else { [void]$inner.Append($line[$i]); $i++ }
                }
                [void]$sb.Append($inner.ToString())
                if ($i -lt $len) { [void]$sb.Append("'"); $i++ }
            } else { [void]$sb.Append($line[$i]); $i++ }
        }
        $newLine = $sb.ToString()
        if ($newLine -ne $line) { $changed = $true }
        $fixed += $newLine
    }

    $fn = $file.Name
    if ($changed) {
        $fixed | Set-Content -Path $file.FullName -Encoding UTF8
        Write-Host "Duzeltildi: $fn"
    } else {
        Write-Host "Degisiklik yok: $fn"
    }
}
Write-Host ""
Write-Host "Tamamlandi." -ForegroundColor Green
