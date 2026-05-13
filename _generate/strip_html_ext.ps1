$ErrorActionPreference = 'Stop'
$root = 'C:\claude\gun2'

$files = @()
$files += Get-ChildItem -Path $root -Filter *.html -File | Where-Object { $_.DirectoryName -eq $root }
$files += Get-ChildItem -Path (Join-Path $root 'ilceler') -Filter *.html -File
$files += Get-ChildItem -Path (Join-Path $root 'hizmetler') -Filter *.html -File
$files += Get-Item (Join-Path $root 'sitemap.xml')

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$changed = 0

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $orig = $content

    # 1) Absolute domain URLs ending in /index.html  -->  trailing slash
    $content = [regex]::Replace($content, '(https?://kanalizasyoncozumleri\.com\.tr[^\s"<>]*?)/index\.html', '$1/')

    # 2) Absolute domain URLs ending in .html  -->  strip .html
    $content = [regex]::Replace($content, '(https?://kanalizasyoncozumleri\.com\.tr[^\s"<>]*?)\.html', '$1')

    # 3) Relative href="...index.html(#anchor)" --> directory path
    $content = [regex]::Replace($content, 'href="((?:\.\./)*(?:[^"]+/)?)index\.html(#[^"]*)?"', {
        param($m)
        $p = $m.Groups[1].Value
        $anchor = $m.Groups[2].Value
        if ($p -eq '') { $p = './' }
        return 'href="' + $p + $anchor + '"'
    })

    # 4) Relative href="...foo.html(#anchor)" --> strip .html (skip http(s) URLs)
    $content = [regex]::Replace($content, 'href="((?!https?://)[^"]+?)\.html(#[^"]*)?"', {
        param($m)
        return 'href="' + $m.Groups[1].Value + $m.Groups[2].Value + '"'
    })

    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($f.FullName, $content, $utf8NoBom)
        Write-Host ("Updated: " + $f.FullName.Substring($root.Length+1))
        $changed++
    }
}
Write-Host ""
Write-Host ("Total files changed: " + $changed)
