# Kanalizasyon Çözümleri site generator — main orchestrator
# Adım 1: python _generate\convert_to_json.py _generate
# Adım 2: powershell -ExecutionPolicy Bypass -File _generate\run.ps1

$ErrorActionPreference = "Stop"
$root    = Split-Path -Parent $PSScriptRoot
$genDir  = $PSScriptRoot

Write-Host "=== Kanalizasyon Çözümleri Generator ===" -ForegroundColor Cyan
Write-Host "Project root: $root"                      -ForegroundColor Gray

# UTF-8 çıktı
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

# ── Şablonları yükle — script scope'ta inline (fonksiyon içinde değil) ───────
$_txt = Get-Content -Raw -Encoding UTF8 -Path "$genDir\templates.ps1"
$_tmp = [System.IO.Path]::GetTempFileName() + ".ps1"
[System.IO.File]::WriteAllText($_tmp, $_txt, [System.Text.Encoding]::UTF8)
. $_tmp
Remove-Item $_tmp -Force -ErrorAction SilentlyContinue

# ── Veri — JSON'dan yükle ────────────────────────────────────────────────────
$distFile = "$genDir\districts.json"
$svcFile  = "$genDir\services.json"

if (-not (Test-Path $distFile)) {
  Write-Host "HATA: $distFile bulunamadı." -ForegroundColor Red
  Write-Host "Önce çalıştır: python _generate\convert_to_json.py _generate" -ForegroundColor Yellow
  exit 1
}
if (-not (Test-Path $svcFile)) {
  Write-Host "HATA: $svcFile bulunamadı." -ForegroundColor Red
  exit 1
}

# JSON → PS nesnesi (Türkçe karakter sorunsuz)
$distJson = Get-Content -Raw -Encoding UTF8 $distFile | ConvertFrom-Json
$svcJson  = Get-Content -Raw -Encoding UTF8 $svcFile  | ConvertFrom-Json

$script:DistrictData = $distJson
$script:ServiceData  = $svcJson

Write-Host "Yüklendi: $($script:DistrictData.Count) ilçe, $($script:ServiceData.Count) hizmet" -ForegroundColor Green

# ── UTF-8 BOM'suz dosya yazıcı ───────────────────────────────────────────────
function Write-Utf8 {
  param([string]$Path, [string]$Content)
  $enc = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

# ── Çıktı dizinleri ──────────────────────────────────────────────────────────
$ilcelerDir   = Join-Path $root "ilceler"
$hizmetlerDir = Join-Path $root "hizmetler"
foreach ($dir in @($ilcelerDir, $hizmetlerDir)) {
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

# ── İlçe sayfaları ───────────────────────────────────────────────────────────
$dCount = 0
foreach ($d in $script:DistrictData) {
  $html    = Build-DistrictPage -d $d
  $outPath = Join-Path $ilcelerDir "$($d.slug).html"
  Write-Utf8 -Path $outPath -Content $html
  $dCount++
  Write-Host "  [ilçe] $($d.slug).html" -ForegroundColor DarkGray
}
Write-Host "Üretildi: $dCount ilçe sayfası" -ForegroundColor Green

# ── Hizmet sayfaları ─────────────────────────────────────────────────────────
$sCount = 0
foreach ($s in $script:ServiceData) {
  $html    = Build-ServicePage -s $s
  $outPath = Join-Path $hizmetlerDir "$($s.slug).html"
  Write-Utf8 -Path $outPath -Content $html
  $sCount++
  Write-Host "  [hizmet] $($s.slug).html" -ForegroundColor DarkGray
}
Write-Host "Üretildi: $sCount hizmet sayfası" -ForegroundColor Green

Write-Host ""
Write-Host "=== Toplam: $($dCount + $sCount) sayfa ===" -ForegroundColor Cyan
