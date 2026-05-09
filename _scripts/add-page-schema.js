const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const SITE = 'https://kanalizasyoncozumleri.com.tr';

const ADDITIONS = [
  {
    file: 'hizmetler.html',
    schema: {
      '@context': 'https://schema.org',
      '@type': 'CollectionPage',
      'name': 'Tüm Hizmetlerimiz',
      'description': '34 farklı uzmanlık alanı: kanalizasyon açma, gider açma, foseptik temizliği, kameralı tespit, drenaj, vidanjör.',
      'url': `${SITE}/hizmetler.html`,
      'isPartOf': { '@type': 'WebSite', 'name': 'Kanalizasyon Çözümleri', 'url': `${SITE}/` },
      'about': { '@type': 'Service', 'name': 'Kanalizasyon ve Gider Açma Hizmetleri', 'provider': { '@id': `${SITE}/#business` } },
    },
  },
  {
    file: 'ilceler/index.html',
    schema: {
      '@context': 'https://schema.org',
      '@type': 'CollectionPage',
      'name': 'Hizmet Verdiğimiz İlçeler',
      'description': 'Adalar hariç İstanbul\'un 38 ilçesinde 7/24 kanalizasyon ve gider açma hizmeti.',
      'url': `${SITE}/ilceler/`,
      'isPartOf': { '@type': 'WebSite', 'name': 'Kanalizasyon Çözümleri', 'url': `${SITE}/` },
    },
  },
  {
    file: 'kvkk.html',
    schema: {
      '@context': 'https://schema.org',
      '@type': 'WebPage',
      'name': 'KVKK Aydınlatma Metni',
      'description': 'Kişisel Verilerin Korunması Kanunu kapsamında bilgilendirme.',
      'url': `${SITE}/kvkk.html`,
      'isPartOf': { '@type': 'WebSite', 'name': 'Kanalizasyon Çözümleri', 'url': `${SITE}/` },
    },
  },
];

let count = 0;
for (const a of ADDITIONS) {
  const p = path.join(ROOT, a.file);
  if (!fs.existsSync(p)) continue;
  let html = fs.readFileSync(p, 'utf8');
  if (html.match(new RegExp(`"@type":\\s*"${a.schema['@type']}"`))) {
    console.log(`  ${a.file} already has ${a.schema['@type']}`);
    continue;
  }
  const block = `<script type="application/ld+json">\n${JSON.stringify(a.schema, null, 2)}\n</script>\n`;
  html = html.replace('</head>', block + '</head>');
  fs.writeFileSync(p, html);
  console.log(`  ${a.file}  +${a.schema['@type']}`);
  count++;
}
console.log(`\nUpdated ${count} files`);
