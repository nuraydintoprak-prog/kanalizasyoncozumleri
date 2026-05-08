# Template helpers for Kanalizasyon Çözümleri site generator
# Dot-sourced by run.ps1

function Get-Photo {
    param([int]$Idx)
    $n = (((($Idx - 1) % 40) + 40) % 40) + 1
    return ("kanalizasyon-{0:D3}.avif" -f $n)
}

function Build-Header {
    param([string]$BasePath = '../')
    return @"
<header class="site-header">
  <div class="container">
    <a href="${BasePath}index.html" class="brand" aria-label="Kanalizasyon Çözümleri ana sayfa">
      <img src="${BasePath}assets/logo.svg" alt="Kanalizasyon Çözümleri logo" width="42" height="42" />
      <span class="brand-text">Kanalizasyon Çözümleri<small>İstanbul · 7/24</small></span>
    </a>
    <nav class="nav" aria-label="Ana menü">
      <a href="${BasePath}index.html">Ana Sayfa</a>
      <a href="${BasePath}hizmetler.html">Hizmetler</a>
      <a href="${BasePath}ilceler/">İlçelerimiz</a>
      <a href="${BasePath}hakkimizda.html">Hakkımızda</a>
      <a href="${BasePath}sss.html">S.S.S.</a>
      <a href="${BasePath}iletisim.html">İletişim</a>
    </nav>
    <div class="header-cta">
      <a href="tel:+905520076034" class="header-tel"><span class="pulse"></span><span class="tel-label">0552 007 60 34</span></a>
      <a href="${BasePath}iletisim.html" class="btn btn-primary">Ücretsiz Keşif</a>
      <button class="menu-toggle" aria-label="Menüyü aç" aria-expanded="false">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M4 7h16M4 12h16M4 17h16"/></svg>
      </button>
    </div>
  </div>
</header>
"@
}

function Build-Footer {
    param([string]$BasePath = '../', [array]$NeighborLinks = @(), [string]$ContextLine = "İstanbul''un her ilçesinde, 7/24.")
    $neighborHtml = ""
    if ($NeighborLinks.Count -gt 0) {
        $items = ($NeighborLinks | ForEach-Object { "<li><a href=`"${BasePath}ilceler/$($_.slug).html`">$($_.name)</a></li>" }) -join "`n          "
        $neighborTitle = "Komşu İlçeler"
    } else {
        $items = @"
<li><a href="${BasePath}ilceler/kadikoy.html">Kadıköy</a></li>
          <li><a href="${BasePath}ilceler/besiktas.html">Beşiktaş</a></li>
          <li><a href="${BasePath}ilceler/uskudar.html">Üsküdar</a></li>
          <li><a href="${BasePath}ilceler/fatih.html">Fatih</a></li>
"@
        $neighborTitle = "Popüler İlçeler"
    }
    return @"
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">
      <div class="footer-brand">
        <a href="${BasePath}index.html" class="brand">
          <img src="${BasePath}assets/logo.svg" alt="Kanalizasyon Çözümleri" width="42" height="42" />
          <span class="brand-text" style="color:#fff;">Kanalizasyon Çözümleri<small>İstanbul · 7/24</small></span>
        </a>
        <p>İstanbul genelinde 20 yıllık tecrübeyle kanalizasyon, gider, lavabo ve klozet açma hizmeti veriyoruz.</p>
      </div>
      <div>
        <h4>Hizmetler</h4>
        <ul>
          <li><a href="${BasePath}hizmetler/kanalizasyon-acma.html">Kanalizasyon Açma</a></li>
          <li><a href="${BasePath}hizmetler/gider-acma.html">Gider Açma</a></li>
          <li><a href="${BasePath}hizmetler/lavabo-acma.html">Lavabo Açma</a></li>
          <li><a href="${BasePath}hizmetler/rogar-acma.html">Rögar Açma</a></li>
          <li><a href="${BasePath}hizmetler/foseptik-temizligi.html">Foseptik Temizliği</a></li>
          <li><a href="${BasePath}hizmetler.html">Tüm Hizmetler →</a></li>
        </ul>
      </div>
      <div>
        <h4>$neighborTitle</h4>
        <ul>
          $items
        </ul>
      </div>
      <div>
        <h4>İletişim</h4>
        <ul>
          <li><a href="tel:+905520076034">📞 0552 007 60 34</a></li>
          <li><a href="https://wa.me/905520076034">💬 WhatsApp</a></li>
          <li>⏰ 7/24 Açığız</li>
          <li><a href="${BasePath}kvkk.html">KVKK & Gizlilik</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      <div>© <span data-year>2026</span> Kanalizasyon Çözümleri. Tüm hakları saklıdır.</div>
      <div>$ContextLine</div>
    </div>
  </div>
</footer>
"@
}

function Build-FabStack {
    return @'
<div class="fab-stack" aria-label="Hızlı iletişim">
  <a class="fab wa" href="https://wa.me/905520076034" aria-label="WhatsApp ile yaz" rel="noopener">
    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.768.967-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.71.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 0 1-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 0 1-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 0 1 2.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0 0 12.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 0 0 5.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 0 0-3.48-8.413"/></svg>
  </a>
  <a class="fab tel" href="tel:+905520076034" aria-label="Telefonla ara">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6A19.79 19.79 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.37 1.9.72 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.35 1.85.59 2.81.72A2 2 0 0 1 22 16.92Z"/></svg>
  </a>
</div>
'@
}

function Build-AllServicesList {
    param([string]$BasePath = '../')
    return @"
<ul class="two-col-list">
  <li><a href="${BasePath}hizmetler/kanalizasyon-acma.html">Kanalizasyon açma</a></li>
  <li><a href="${BasePath}hizmetler/gider-acma.html">Gider açma</a></li>
  <li><a href="${BasePath}hizmetler/lavabo-acma.html">Lavabo açma</a></li>
  <li><a href="${BasePath}hizmetler/tuvalet-acma.html">Tuvalet ve klozet açma</a></li>
  <li><a href="${BasePath}hizmetler/mutfak-gideri-acma.html">Mutfak gideri açma</a></li>
  <li><a href="${BasePath}hizmetler/banyo-gideri-acma.html">Banyo ve duş gideri açma</a></li>
  <li><a href="${BasePath}hizmetler/rogar-acma.html">Rögar (logar) açma ve temizliği</a></li>
  <li><a href="${BasePath}hizmetler/pissu-hatti-acma.html">Pissu hattı açma</a></li>
  <li><a href="${BasePath}hizmetler/kamera-ile-goruntuleme.html">Kamera ile boru görüntüleme</a></li>
  <li><a href="${BasePath}hizmetler/basincli-su-temizligi.html">Basınçlı su ile boru temizliği</a></li>
  <li><a href="${BasePath}hizmetler/foseptik-temizligi.html">Foseptik temizliği</a></li>
  <li><a href="${BasePath}hizmetler/yag-tutucu-temizligi.html">Yağ tutucu temizliği</a></li>
  <li><a href="${BasePath}hizmetler/koku-giderme.html">Koku giderme</a></li>
  <li><a href="${BasePath}hizmetler/boru-tespit.html">Boru tespit (yer altı)</a></li>
  <li><a href="${BasePath}hizmetler/apartman-site-sozlesmeli.html">Apartman ve site sözleşmeli</a></li>
  <li><a href="${BasePath}hizmetler/cekvalf-montaji.html">Çekvalf montajı</a></li>
  <li><a href="${BasePath}hizmetler/logar-tamiri.html">Logar (rögar) tamiri</a></li>
  <li><a href="${BasePath}hizmetler/drenaj-ustasi.html">Drenaj ustası hizmetleri</a></li>
  <li><a href="${BasePath}hizmetler/foseptik-cukuru-acma.html">Foseptik çukuru açma</a></li>
  <li><a href="${BasePath}hizmetler/lagim-cukuru-acma.html">Lağım çukuru açma</a></li>
  <li><a href="${BasePath}hizmetler/drenaj-kuyusu-kuyu-acma.html">Drenaj kuyusu ve kuyu açma</a></li>
  <li><a href="${BasePath}hizmetler/drenaj-kanali-acma.html">Drenaj kanalı açma</a></li>
  <li><a href="${BasePath}hizmetler/kanalizasyon-tamiri.html">Kanalizasyon tamiri</a></li>
  <li><a href="${BasePath}hizmetler/kanalizasyon-baglantisi.html">Kanalizasyon bağlantısı</a></li>
  <li><a href="${BasePath}hizmetler/kanalizasyon-hatti-yenileme.html">Kanalizasyon hattı yenileme</a></li>
  <li><a href="${BasePath}hizmetler/logar-kapagi-yenileme.html">Logar kapağı yenileme ve montajı</a></li>
  <li><a href="${BasePath}hizmetler/vidanjor-hizmeti.html">Vidanjör hizmeti</a></li>
  <li><a href="${BasePath}hizmetler/kostebek-tunel-acma.html">Köstebek sistemi ile tünel açma</a></li>
  <li><a href="${BasePath}hizmetler/dalgic-pompa-montaji.html">Dalgıç pompa montajı</a></li>
  <li><a href="${BasePath}hizmetler/izolasyon-hizmetleri.html">İzolasyon hizmetleri</a></li>
  <li><a href="${BasePath}hizmetler/drenaj-hatti-yenileme.html">Drenaj hattı yenileme</a></li>
  <li><a href="${BasePath}hizmetler/ariza-noktasal-tespit.html">Kanalizasyon arıza ve noktasal tespit</a></li>
  <li><a href="${BasePath}hizmetler/beton-kirma.html">Beton kırma</a></li>
  <li><a href="${BasePath}hizmetler/hafriyat-kazi.html">Hafriyat ve kazı işleri</a></li>
</ul>
"@
}

function Build-DistrictPage {
    param($d)

    $photo = Get-Photo -Idx $d.photo
    $banner = Get-Photo -Idx ($d.photo + 1)
    $mahalleHtml = ($d.mahalleler | ForEach-Object { "<li>$_ Mahallesi</li>" }) -join "`n        "
    $problemsHtml = ($d.problems | ForEach-Object { "<li><strong>$($_.t):</strong> $($_.d)</li>" }) -join "`n        "
    $calloutsHtml = ($d.callouts | ForEach-Object { "<div class=`"callout`"><strong>$($_.t):</strong> $($_.d)</div>" }) -join "`n      "
    $timesHtml = ($d.times | ForEach-Object { "<li><strong>$($_.a):</strong> $($_.t)</li>" }) -join "`n        "
    $faqsHtml = ($d.faqs | ForEach-Object { @"
<details class="faq-item">
        <summary>$($_.q)</summary>
        <div class="faq-body">$($_.a)</div>
      </details>
"@ }) -join "`n      "
    $allServices = Build-AllServicesList -BasePath '../'
    $header = Build-Header -BasePath '../'
    $footer = Build-Footer -BasePath '../' -NeighborLinks $d.neighborLinks -ContextLine "$($d.name) ve İstanbul''un her ilçesinde, 7/24."
    $fab = Build-FabStack

    return @"
<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>$($d.name) Kanalizasyon Açma — 7/24 Acil Servis | Kanalizasyon Çözümleri</title>
<meta name="description" content="$($d.name) ve tüm mahallelerinde 7/24 kanalizasyon, gider ve lavabo açma. 30 dakikada kapınızdayız, ücretsiz keşif yapıyoruz. 20 yıllık tecrübemizle iş bitiriyoruz. 0552 007 60 34" />
<meta name="keywords" content="$($d.slug -replace '-', ' ') kanalizasyon açma, $($d.slug -replace '-', ' ') gider açma, $($d.slug -replace '-', ' ') lavabo açma, $($d.slug -replace '-', ' ') tıkanıklık açma" />
<link rel="canonical" href="https://kanalizasyoncozumleri.com.tr/ilceler/$($d.slug).html" />
<meta property="og:type" content="article" />
<meta property="og:title" content="$($d.name) Kanalizasyon Açma — 7/24 Acil Servis" />
<meta property="og:description" content="$($d.name)'$($d.locSuffix) her mahallesinde 30 dakikada kapınızda, ücretsiz keşifle hizmetinizdeyiz." />
<meta property="og:url" content="https://kanalizasyoncozumleri.com.tr/ilceler/$($d.slug).html" />
<meta property="og:image" content="https://kanalizasyoncozumleri.com.tr/assets/img/$photo" />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="../assets/css/style.css" />
<link rel="icon" type="image/svg+xml" href="../assets/logo.svg" />
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Service",
  "serviceType": "Kanalizasyon Açma",
  "provider": {
    "@type": "LocalBusiness",
    "name": "Kanalizasyon Çözümleri",
    "telephone": "+905520076034",
    "url": "https://kanalizasyoncozumleri.com.tr/"
  },
  "areaServed": {
    "@type": "AdministrativeArea",
    "name": "$($d.name), İstanbul"
  },
  "name": "$($d.name) Kanalizasyon Açma",
  "description": "$($d.name) ve tüm mahallelerinde 7/24 kanalizasyon, gider, lavabo ve klozet açma hizmeti."
}
</script>
</head>
<body>

$header

<section class="page-hero">
  <div class="container">
    <div class="breadcrumb">
      <a href="../index.html">Ana Sayfa</a><span>›</span>
      <a href="./">İlçeler</a><span>›</span>
      $($d.name)
    </div>
    <h1>$($d.loc) Kanalizasyon Açma — 7/24 Yanınızdayız</h1>
    <p>$($d.intro)</p>
  </div>
</section>

<section class="section">
  <div class="container article">
    <div class="article-body">

      <div class="article-img">
        <picture>
          <source srcset="../assets/img/$photo" type="image/avif" />
          <img src="../assets/img/$photo" alt="$($d.loc) kanalizasyon açma ekibi sahada" loading="lazy" decoding="async" width="1200" height="525" />
        </picture>
      </div>

      <h2>$($d.loc) 7/24 Kanalizasyon Açma Hizmeti</h2>
      <p>$($d.para1)</p>
      <p>$($d.para2)</p>

      <h2>$($d.gen) Hangi Mahallelerinde Hizmet Veriyoruz</h2>
      <p>$($d.gen) <strong>$($d.mahalleler.Count) mahallesinde</strong> aktif olarak çalışıyoruz. Hangi sokakta olursanız olun, ekibimiz size ulaşacaktır:</p>
      <ul class="two-col-list">
        $mahalleHtml
      </ul>

      <h2>$($d.loc) En Sık Karşılaştığımız Tıkanıklık Sorunları</h2>
      <p>$($d.problemsIntro)</p>
      <ul>
        $problemsHtml
      </ul>

      <h2>$($d.loc) Sunduğumuz Tüm Hizmetler</h2>
      <p>Sorununuz ne olursa olsun, çözümü tek bir telefonla bulabileceğiniz bir firma olmaya çalışıyoruz. $($d.loc) aktif olarak şu hizmetleri veriyoruz:</p>
      $allServices

      <h2>$($d.gen) Yapı Çeşitliliğine Göre Yaklaşımımız</h2>
      <p>$($d.calloutsIntro)</p>
      $calloutsHtml

      <div class="article-img">
        <picture>
          <source srcset="../assets/img/$banner" type="image/avif" />
          <img src="../assets/img/$banner" alt="$($d.name) bölgesinde profesyonel ekipmanlarımız iş başında" loading="lazy" decoding="async" width="1200" height="525" />
        </picture>
      </div>

      <h2>$($d.extraTitle)</h2>
      <p>$($d.extraBody)</p>

      <h2>Apartman Yöneticilerine Özel Sözleşmeli Hizmet</h2>
      <p>$($d.loc) birçok apartman ve sitenin yöneticisiyle uzun yıllardır çalışıyoruz. Sözleşmeli hizmet kapsamında şunları sunuyoruz:</p>
      <ul>
        <li>Yılda iki kez ücretsiz altyapı kontrolü</li>
        <li>Acil müdahalede %30''a varan indirim</li>
        <li>Telefonla aradığınızda öncelikli sıraya alınma</li>
        <li>Yapılan tüm işlerin kayıt altına alınması ve raporlanması</li>
        <li>Sigortalı hizmet ve yazılı garanti</li>
      </ul>
      <p>Yönetici olarak aidat tahsilatında "kanalizasyon açma" kalemini büyük tutmaktansa, sabit yıllık bütçeyle iş garanti altına almak hem daha ekonomik hem daha sürdürülebilir.</p>

      <h2>$($d.dat) Ne Kadar Sürede Geliyoruz?</h2>
      <p>$($d.timesIntro)</p>
      <ul>
        $timesHtml
      </ul>

      <h2>Kullandığımız Profesyonel Ekipmanlar</h2>
      <p>Sorunun türüne göre doğru aleti seçmek, işin yarısı. Ekibimizin sahaya çıkardığı ekipmanlar:</p>
      <ul>
        <li><strong>Robotik spiral makineler:</strong> 12''liden 100''lüye kadar farklı çaplarda, 60 metreye uzanan çelik spirallerimiz var.</li>
        <li><strong>Yüksek basınçlı su tankerleri:</strong> 200 bar''a kadar basınç, kireç ve yağ tıkanıklıklarına etkili.</li>
        <li><strong>HD görüntüleme kameraları:</strong> Boru içini gerçek zamanlı izlemenizi sağlayan 50 metre mesafeli kameralarımız.</li>
        <li><strong>Vidanjör araçlarımız:</strong> Foseptik ve rögar boşaltma için yeterli kapasitede.</li>
        <li><strong>Sinyal cihazları:</strong> Yer altı borularını kırmadan tespit edebilmek için.</li>
      </ul>

      <h2>Ücretsiz Keşif Sürecimiz</h2>
      <p>$($d.loc) keşif süreci şöyle ilerliyor: aramanızdan sonra ekibimiz adresinize geliyor, sorunu yerinde inceliyor, çözümü ve <strong>net fiyatı size söylüyoruz</strong>. Onaylarsanız hemen başlıyoruz; onaylamazsanız hiçbir ücret almadan ayrılıyoruz. <strong>"Yol parası", "geldim ücreti" gibi gizli kalemler bizde yok.</strong> Şeffaflık, 20 yıldır müşterilerimizin bizi tekrar tekrar aramasının başlıca sebebi.</p>

      <h2>$($d.name) Müşterilerimizden Sıkça Aldığımız Sorular</h2>
      $faqsHtml

      <h2>$($d.loc) Tıkanıklık Sorununu Bekletmeyin</h2>
      <p>$($d.closing)</p>

    </div>

    <aside class="sticky-side">
      <div class="side-card">
        <h4>Hemen Bize Ulaşın</h4>
        <a href="tel:+905520076034" class="big-tel">0552 007 60 34</a>
        <div class="small">7/24 açığız · Keşif ücretsiz</div>
        <a href="tel:+905520076034" class="btn btn-primary">📞 Hemen Ara</a>
      </div>
      <div class="side-card">
        <h4>WhatsApp ile Yazın</h4>
        <div class="small">Fotoğraf gönderin, durumu hızlıca değerlendirip sahaya çıkalım.</div>
        <a href="https://wa.me/905520076034" class="btn btn-outline">💬 WhatsApp</a>
      </div>
      <div class="side-card">
        <h4>$($d.loc) Hizmetlerimiz</h4>
        <ul style="list-style: none; padding: 0;">
          <li style="margin-bottom: 6px;">✓ Kanalizasyon açma</li>
          <li style="margin-bottom: 6px;">✓ Lavabo ve gider açma</li>
          <li style="margin-bottom: 6px;">✓ Tuvalet açma</li>
          <li style="margin-bottom: 6px;">✓ Rögar (logar) temizliği</li>
          <li style="margin-bottom: 6px;">✓ Foseptik çekimi</li>
          <li style="margin-bottom: 6px;">✓ Kamera ile inceleme</li>
          <li>✓ Basınçlı su temizliği</li>
        </ul>
      </div>
    </aside>
  </div>
</section>

<section class="section">
  <div class="container">
    <div class="cta-banner">
      <div>
        <h2>$($d.gen) her noktasındayız. Bekletmeyelim.</h2>
        <p>Aramanızdan 30 dakika sonra ekibimiz adresinizde olur, keşif yapar, fiyatı söyler. Onaylarsanız iş başlar; onaylamazsanız bir kuruş ödemezsiniz.</p>
      </div>
      <a href="tel:+905520076034" class="btn btn-light">📞 0552 007 60 34</a>
    </div>
  </div>
</section>

$footer

$fab

<script src="../assets/js/main.js" defer></script>
</body>
</html>
"@
}

function Build-ServicePage {
    param($s)

    $photo = Get-Photo -Idx $s.photo
    $banner = Get-Photo -Idx ($s.photo + 1)
    $methodsHtml = ($s.methods | ForEach-Object { "<h3>$($_.t)</h3>`n      <p>$($_.d)</p>" }) -join "`n      "
    $causesHtml = ($s.causes | ForEach-Object { "<li><strong>$($_.t):</strong> $($_.d)</li>" }) -join "`n        "
    $faqsHtml = ($s.faqs | ForEach-Object { @"
<details class="faq-item">
        <summary>$($_.q)</summary>
        <div class="faq-body">$($_.a)</div>
      </details>
"@ }) -join "`n      "
    $header = Build-Header -BasePath '../'
    $footer = Build-Footer -BasePath '../' -ContextLine "İstanbul''un her ilçesinde, 7/24."
    $fab = Build-FabStack

    return @"
<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>$($s.name) — İstanbul''da 7/24 Profesyonel Hizmet | Kanalizasyon Çözümleri</title>
<meta name="description" content="$($s.metaDesc)" />
<meta name="keywords" content="$($s.keywords)" />
<link rel="canonical" href="https://kanalizasyoncozumleri.com.tr/hizmetler/$($s.slug).html" />
<meta property="og:type" content="article" />
<meta property="og:title" content="$($s.name) — İstanbul''da Profesyonel Hizmet" />
<meta property="og:description" content="$($s.metaDesc)" />
<meta property="og:image" content="https://kanalizasyoncozumleri.com.tr/assets/img/$photo" />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="../assets/css/style.css" />
<link rel="icon" type="image/svg+xml" href="../assets/logo.svg" />
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Service",
  "serviceType": "$($s.name)",
  "provider": {
    "@type": "LocalBusiness",
    "name": "Kanalizasyon Çözümleri",
    "telephone": "+905520076034",
    "url": "https://kanalizasyoncozumleri.com.tr/"
  },
  "areaServed": "İstanbul",
  "name": "$($s.name)",
  "description": "$($s.metaDesc)"
}
</script>
</head>
<body>

$header

<section class="page-hero">
  <div class="container">
    <div class="breadcrumb">
      <a href="../index.html">Ana Sayfa</a><span>›</span>
      <a href="../hizmetler.html">Hizmetler</a><span>›</span>
      $($s.name)
    </div>
    <h1>$($s.h1)</h1>
    <p>$($s.heroLead)</p>
  </div>
</section>

<section class="section">
  <div class="container article">
    <div class="article-body">

      <div class="article-img">
        <picture>
          <source srcset="../assets/img/$photo" type="image/avif" />
          <img src="../assets/img/$photo" alt="$($s.name) hizmeti — sahada profesyonel müdahale" loading="lazy" decoding="async" width="1200" height="525" />
        </picture>
      </div>

      <h2>$($s.introTitle)</h2>
      <p>$($s.intro1)</p>
      <p>$($s.intro2)</p>

      <h2>$($s.causesTitle)</h2>
      <p>$($s.causesIntro)</p>
      <ul>
        $causesHtml
      </ul>

      <h2>$($s.signsTitle)</h2>
      <p>$($s.signsBody)</p>
      <div class="callout"><strong>İpucu:</strong> $($s.signsTip)</div>

      <h2>$($s.methodsTitle)</h2>
      <p>$($s.methodsIntro)</p>
      $methodsHtml

      <div class="article-img">
        <picture>
          <source srcset="../assets/img/$banner" type="image/avif" />
          <img src="../assets/img/$banner" alt="$($s.name) için kullandığımız profesyonel ekipmanlar" loading="lazy" decoding="async" width="1200" height="525" />
        </picture>
      </div>

      <h2>$($s.specialTitle)</h2>
      <p>$($s.specialBody)</p>

      <h2>$($s.bonusTitle)</h2>
      <p>$($s.bonusBody)</p>

      <h2>Acil Müdahale Süremiz</h2>
      <p>İstanbul içinde ortalama varış süremiz 30 dakika. İlçeye, saate ve trafiğe göre bu süre değişir; aramanızdan hemen sonra size net süre söylüyoruz. Bayram, gece, hafta sonu — fark etmiyor; ekibimiz dönüşümlü olarak 7/24 sahada. Aciliyet bildirildiğinde en yakın ekibi yönlendiriyoruz.</p>

      <h2>Ücretsiz Keşif Süreci</h2>
      <p>$($s.name) fiyatı, sorunun büyüklüğüne, hattın uzunluğuna, kullanılacak ekipmana göre değişir. Bu yüzden telefonda kesin fiyat söylemek yerine, ekibimiz adresinize gelir, sorunu yerinde inceler, <strong>net fiyatı yüz yüze söyler</strong>. Beğenirseniz işe başlıyoruz; beğenmezseniz hiçbir ücret talep etmiyoruz.</p>

      <h2>Garanti ve Sigortalı Hizmet</h2>
      <p>Yaptığımız her işin arkasındayız. Müdahale tipine göre 30 gün ile 6 ay arasında <strong>yazılı garanti</strong> veriyoruz. Aynı sorun aynı noktada tekrarlarsa, garanti süresi içinde ücretsiz dönüyoruz. Sigortalı hizmet sunuyoruz, faturalı çalışıyoruz, e-fatura ihtiyacı olan işletmelere gerekli belgeleri kesiyoruz.</p>

      <h2>Hangi Bölgelerde Bu Hizmeti Veriyoruz?</h2>
      <p>İstanbul''un Adalar dışındaki <strong>tüm 38 ilçesinde</strong> aktif olarak hizmet veriyoruz. Anadolu yakası ya da Avrupa yakası fark etmez, hangi mahallede olursanız olun ekibimiz size ulaşır. <a href="../index.html#ilceler">Tüm hizmet ilçelerimizi buradan görebilirsiniz.</a></p>

      <h2>Sıkça Sorulan Sorular</h2>
      $faqsHtml

      <h2>$($s.closingTitle)</h2>
      <p>$($s.closingBody)</p>

    </div>

    <aside class="sticky-side">
      <div class="side-card">
        <h4>Hemen Bize Ulaşın</h4>
        <a href="tel:+905520076034" class="big-tel">0552 007 60 34</a>
        <div class="small">7/24 açığız · Keşif ücretsiz</div>
        <a href="tel:+905520076034" class="btn btn-primary">📞 Hemen Ara</a>
      </div>
      <div class="side-card">
        <h4>WhatsApp ile Yazın</h4>
        <div class="small">Fotoğraf gönderin, durumu hızlıca değerlendirelim.</div>
        <a href="https://wa.me/905520076034" class="btn btn-outline">💬 WhatsApp</a>
      </div>
      <div class="side-card">
        <h4>İlgili Hizmetlerimiz</h4>
        <ul style="list-style: none; padding: 0;">
          <li style="margin-bottom: 6px;"><a href="kanalizasyon-acma.html">→ Kanalizasyon Açma</a></li>
          <li style="margin-bottom: 6px;"><a href="kamera-ile-goruntuleme.html">→ Kamera ile Görüntüleme</a></li>
          <li style="margin-bottom: 6px;"><a href="basincli-su-temizligi.html">→ Basınçlı Su Temizliği</a></li>
          <li style="margin-bottom: 6px;"><a href="rogar-acma.html">→ Rögar Açma</a></li>
          <li><a href="../hizmetler.html">→ Tüm Hizmetler</a></li>
        </ul>
      </div>
    </aside>
  </div>
</section>

<section class="section">
  <div class="container">
    <div class="cta-banner">
      <div>
        <h2>$($s.ctaTitle)</h2>
        <p>$($s.ctaBody)</p>
      </div>
      <a href="tel:+905520076034" class="btn btn-light">📞 0552 007 60 34</a>
    </div>
  </div>
</section>

$footer

$fab

<script src="../assets/js/main.js" defer></script>
</body>
</html>
"@
}
