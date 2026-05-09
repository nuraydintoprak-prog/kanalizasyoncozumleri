const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const SKIP = new Set(['_generate', '_scripts', 'exiftool', 'node_modules', '.git', '.wrangler', 'dist']);
const SITE = 'https://kanalizasyoncozumleri.com.tr';

const HIZMET_LABELS = {
  'kanalizasyon-acma': 'Kanalizasyon Açma',
  'gider-acma': 'Gider Açma',
  'lavabo-acma': 'Lavabo Açma',
  'tuvalet-acma': 'Tuvalet Açma',
  'mutfak-gideri-acma': 'Mutfak Gideri Açma',
  'banyo-gideri-acma': 'Banyo Gideri Açma',
  'rogar-acma': 'Rögar Açma',
  'pissu-hatti-acma': 'Pissu Hattı Açma',
  'kamera-ile-goruntuleme': 'Kamera ile Görüntüleme',
  'basincli-su-temizligi': 'Basınçlı Su Temizliği',
  'foseptik-temizligi': 'Foseptik Temizliği',
  'yag-tutucu-temizligi': 'Yağ Tutucu Temizliği',
  'koku-giderme': 'Koku Giderme',
  'boru-tespit': 'Boru Tespiti',
  'apartman-site-sozlesmeli': 'Apartman / Site Sözleşmeli',
  'ariza-noktasal-tespit': 'Arıza Noktasal Tespit',
  'beton-kirma': 'Beton Kırma',
  'cekvalf-montaji': 'Çekvalf Montajı',
  'dalgic-pompa-montaji': 'Dalgıç Pompa Montajı',
  'drenaj-hatti-yenileme': 'Drenaj Hattı Yenileme',
  'drenaj-kanali-acma': 'Drenaj Kanalı Açma',
  'drenaj-kuyusu-kuyu-acma': 'Drenaj Kuyusu Açma',
  'drenaj-ustasi': 'Drenaj Ustası',
  'foseptik-cukuru-acma': 'Foseptik Çukuru Açma',
  'hafriyat-kazi': 'Hafriyat ve Kazı',
  'izolasyon-hizmetleri': 'İzolasyon Hizmetleri',
  'kanalizasyon-baglantisi': 'Kanalizasyon Bağlantısı',
  'kanalizasyon-hatti-yenileme': 'Kanalizasyon Hattı Yenileme',
  'kanalizasyon-tamiri': 'Kanalizasyon Tamiri',
  'kostebek-tunel-acma': 'Köstebek Tünel Açma',
  'lagim-cukuru-acma': 'Lağım Çukuru Açma',
  'logar-kapagi-yenileme': 'Logar Kapağı Yenileme',
  'logar-tamiri': 'Logar Tamiri',
  'vidanjor-hizmeti': 'Vidanjör Hizmeti',
};

const ROOT_LABELS = {
  'hakkimizda.html': 'Hakkımızda',
  'iletisim.html': 'İletişim',
  'sss.html': 'Sıkça Sorulan Sorular',
  'kvkk.html': 'KVKK',
  'hizmetler.html': 'Hizmetler',
};

function walk(dir, out = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (SKIP.has(e.name)) continue;
    const full = path.join(dir, e.name);
    if (e.isDirectory()) walk(full, out);
    else if (e.name.endsWith('.html')) out.push(full);
  }
  return out;
}

function getTitle(html) {
  const m = html.match(/<title>([^<]+)<\/title>/);
  if (!m) return null;
  return m[1].split('—')[0].split('|')[0].trim();
}

function buildBreadcrumb(file) {
  const rel = path.relative(ROOT, file).replace(/\\/g, '/');

  // Skip homepage
  if (rel === 'index.html') return null;

  const items = [{ name: 'Anasayfa', url: `${SITE}/` }];

  if (rel.startsWith('hizmetler/')) {
    items.push({ name: 'Hizmetler', url: `${SITE}/hizmetler.html` });
    const slug = rel.replace('hizmetler/', '').replace('.html', '');
    items.push({ name: HIZMET_LABELS[slug] || slug, url: `${SITE}/${rel}` });
  } else if (rel.startsWith('ilceler/')) {
    items.push({ name: 'İlçeler', url: `${SITE}/ilceler/` });
    if (rel !== 'ilceler/index.html') {
      const slug = rel.replace('ilceler/', '').replace('.html', '');
      const label = slug.charAt(0).toLocaleUpperCase('tr') + slug.slice(1);
      items.push({ name: label, url: `${SITE}/${rel}` });
    }
  } else if (ROOT_LABELS[rel]) {
    items.push({ name: ROOT_LABELS[rel], url: `${SITE}/${rel}` });
  } else {
    return null;
  }

  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    'itemListElement': items.map((it, i) => ({
      '@type': 'ListItem',
      'position': i + 1,
      'name': it.name,
      'item': it.url,
    })),
  };
}

let count = 0;
for (const f of walk(ROOT)) {
  let html = fs.readFileSync(f, 'utf8');
  if (html.includes('"BreadcrumbList"')) continue;

  const bc = buildBreadcrumb(f);
  if (!bc) continue;

  const block = `<script type="application/ld+json">\n${JSON.stringify(bc, null, 2)}\n</script>\n`;
  if (!html.includes('</head>')) continue;
  html = html.replace('</head>', block + '</head>');
  fs.writeFileSync(f, html);
  count++;
}
console.log(`Added BreadcrumbList JSON-LD to ${count} files`);
