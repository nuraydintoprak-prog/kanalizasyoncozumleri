$ErrorActionPreference = 'Stop'
$root = 'C:\claude\gun2'
$version = '20260513b'

$files = @()
$files += Get-ChildItem -Path $root -Filter *.html -File | Where-Object { $_.DirectoryName -eq $root }
$files += Get-ChildItem -Path (Join-Path $root 'ilceler') -Filter *.html -File
$files += Get-ChildItem -Path (Join-Path $root 'hizmetler') -Filter *.html -File

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$changed = 0

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $orig = $content

    # style.css ve main.js icin cache-busting query string ekle/guncelle
    $content = [regex]::Replace($content, 'href="([^"]*?/)?style\.css(\?v=[^"]*)?"', "href=`"`$1style.css?v=$version`"")
    $content = [regex]::Replace($content, 'src="([^"]*?/)?main\.js(\?v=[^"]*)?"', "src=`"`$1main.js?v=$version`"")

    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($f.FullName, $content, $utf8NoBom)
        $changed++
    }
}
Write-Host ("Total files changed: " + $changed)
