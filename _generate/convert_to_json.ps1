# PS data dosyalarını JSON'a çeviren script
# Çalıştır: powershell -ExecutionPolicy Bypass -File _generate\convert_to_json.ps1

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$genDir = $PSScriptRoot

function Source-Utf8 {
  param([string]$Path)
  $txt = Get-Content -Raw -Encoding UTF8 -Path $Path
  $tmp = [System.IO.Path]::GetTempFileName() + ".ps1"
  [System.IO.File]::WriteAllText($tmp, $txt, [System.Text.Encoding]::UTF8)
  . $tmp
  Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}

Write-Host "İlçe verilerini yükleniyor..." -ForegroundColor Cyan
$script:DistrictData = @()
Source-Utf8 "$genDir\districts-1.ps1"
Source-Utf8 "$genDir\districts-2.ps1"
Source-Utf8 "$genDir\districts-3.ps1"
Source-Utf8 "$genDir\districts-4.ps1"
Write-Host "  $($script:DistrictData.Count) ilçe yüklendi" -ForegroundColor Green

Write-Host "Hizmet verilerini yükleniyor..." -ForegroundColor Cyan
$script:ServiceData = @()
Source-Utf8 "$genDir\services-1.ps1"
Source-Utf8 "$genDir\services-2.ps1"
Source-Utf8 "$genDir\services-3.ps1"
Write-Host "  $($script:ServiceData.Count) hizmet yüklendi" -ForegroundColor Green

# UTF-8 BOM'suz JSON yaz
$utf8 = New-Object System.Text.UTF8Encoding $false

Write-Host "JSON dosyaları yazılıyor..." -ForegroundColor Cyan
$distJson = $script:DistrictData | ConvertTo-Json -Depth 20
$svcJson  = $script:ServiceData  | ConvertTo-Json -Depth 20

[System.IO.File]::WriteAllText("$genDir\districts.json", $distJson, $utf8)
[System.IO.File]::WriteAllText("$genDir\services.json",  $svcJson,  $utf8)

Write-Host "  districts.json yazıldı" -ForegroundColor Green
Write-Host "  services.json yazıldı"  -ForegroundColor Green
Write-Host ""
Write-Host "Şimdi: powershell -ExecutionPolicy Bypass -File _generate\run.ps1" -ForegroundColor Yellow
