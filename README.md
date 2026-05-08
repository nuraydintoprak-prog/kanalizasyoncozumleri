# Kanalizasyon Çözümleri — Web Sitesi

İstanbul genelinde 7/24 kanalizasyon, gider ve lavabo açma hizmeti veren firmaya ait kurumsal web sitesi. Saf HTML/CSS/JS, framework yok.

- **Domain:** `kanalizasyoncozumleri.com.tr`
- **Hosting:** Cloudflare Pages
- **Sayfa sayısı:** 1 anasayfa + 5 kurumsal + 38 ilçe + 34 hizmet ≈ **78 sayfa**

---

## Yerel Önizleme

PowerShell'de proje klasöründen:

```powershell
# Python varsa
python -m http.server 8000

# veya Node varsa
npx serve .
```

Tarayıcıda: <http://localhost:8000/>

> Dosyaları çift tıklayıp `file://` ile açmak da çalışır ama bazı tarayıcılarda göreli yollar/fontlar düzgün yüklenmez. HTTP sunucusu önerilir.

---

## Cloudflare Pages — Deploy Adımları

1. <https://dash.cloudflare.com> → **Workers & Pages** → **Create** → **Pages** → **Direct upload**
2. Proje adı: `kanalizasyon-cozumleri` (veya tercih ettiğin)
3. Bu klasörün **içeriğini** zip olarak yükle (klasörün kendisini değil — `index.html` zip'in kökünde olmalı)
   - `_generate/` ve `exiftool/` klasörlerini zip'e dahil etme (kaynak araçları, sitenin parçası değil)
   - `robots.txt` zaten `Disallow: /_generate/` diyor ama gereksiz boyut
4. Yükleme bitince Cloudflare otomatik yayınlar (genelde 30 sn).
5. **Custom domains** sekmesi → `kanalizasyoncozumleri.com.tr` ekle → DNS yönlendirmesi otomatik kurulur.
6. SSL otomatik aktive olur (≈5 dk).

### Güncelleme yaparken

Aynı projeye yeniden Direct Upload yapabilirsin; her yükleme yeni bir "deployment" olur ve Cloudflare otomatik canlıya alır. Önceki sürümlere de tek tıkla geri dönülebilir.

### Alternatif: GitHub bağlantısı

Repo'yu GitHub'a koyarsan, Cloudflare Pages her commit'te otomatik deploy yapar. Direct upload daha hızlı başlangıç için, GitHub uzun vadede daha pratik.

---

## Web3Forms (İletişim Formu)

Form şu an **devre dışı modda** çalışıyor: kullanıcı submit ettiğinde "Form henüz aktive edilmedi, lütfen telefonla ulaşın" mesajı görüp telefon/WhatsApp'a yönlendiriliyor.

Aktive etmek için:

1. <https://web3forms.com> üzerinden e-posta ile bedava hesap aç (ayda 250 mesaj ücretsiz).
2. Verilen `access_key` kodunu kopyala.
3. `iletisim.html` dosyasında şu satırı bul:
   ```html
   <input type="hidden" name="access_key" value="YOUR_WEB3FORMS_KEY" />
   ```
   `YOUR_WEB3FORMS_KEY` yerine kodunu yapıştır, dosyayı kaydet, Cloudflare'e yeniden yükle.

Mesajlar Web3Forms'ta verdiğin e-posta adresine düşer.

---

## Klasör Yapısı

```
.
├── index.html
├── hizmetler.html, hakkimizda.html, iletisim.html, sss.html, kvkk.html
├── robots.txt, sitemap.xml
├── _headers                  ← Cloudflare Pages cache & güvenlik header'ları
├── assets/
│   ├── css/style.css
│   ├── js/main.js
│   ├── logo.svg
│   └── img/                  ← 40 AVIF + SVG fallback
├── ilceler/
│   ├── index.html            ← liste sayfası
│   └── 38 ilçe (.html)
├── hizmetler/
│   └── 34 hizmet (.html)
├── _generate/                ← deploy'a dahil etme
└── exiftool/                 ← deploy'a dahil etme
```

---

## Renkler & Tasarım Sistemi

| Token | Değer | Kullanım |
|---|---|---|
| `--navy` | `#0B2447` | Ana kurumsal renk, başlıklar, header |
| `--orange` | `#F76C0C` | CTA butonları, vurgular |
| `--bg-soft` | `#F5F7FA` | Açık zeminli bölümler |

Tüm tema `assets/css/style.css` başındaki `:root` bloğunda. Yeni sayfa eklerken mevcut sınıfları yeniden kullan, yeni CSS dosyası ekleme.

---

## Yeni Sayfa Ekleme

Toplu içerik için `_generate/` altındaki PowerShell scriptlerini ve `districts.json` / `services.json` dosyalarını kullan. Tek sayfa için mevcut bir kalıbı (örn. `ilceler/kadikoy.html`) kopyalayıp uyarla.

Yeni sayfa eklediğinde **`sitemap.xml`'e de ekle** ve `lastmod` tarihini güncelle.

---

## Deploy Sonrası Yapılacaklar

- [ ] Cloudflare Pages'e ilk yükleme
- [ ] Custom domain bağlama (`kanalizasyoncozumleri.com.tr`)
- [ ] SSL'in aktif olduğunu doğrula (https:// ile aç)
- [ ] Google Search Console'a domain ekle, sitemap submit et: `https://kanalizasyoncozumleri.com.tr/sitemap.xml`
- [ ] Bing Webmaster Tools'a aynı şekilde ekle
- [ ] Google Business Profile aç (yerel SEO için kritik)
- [ ] Web3Forms anahtarını yerleştirip formu aktive et
- [ ] Telefonla / WhatsApp'la kendi numaranı arayıp linklerin çalıştığını test et
- [ ] Mobil cihazda canlı siteyi test et (özellikle sticky butonlar ve mobil menü)
