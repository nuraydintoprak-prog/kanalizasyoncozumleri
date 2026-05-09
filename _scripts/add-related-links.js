const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');

// Komşu ilçeler (her ilçenin yakınında olan 4 ilçe)
const NEIGHBORS = {
  'kadikoy':       ['uskudar', 'maltepe', 'atasehir', 'kartal'],
  'uskudar':       ['kadikoy', 'beykoz', 'cekmekoy', 'umraniye'],
  'maltepe':       ['kadikoy', 'kartal', 'atasehir', 'pendik'],
  'atasehir':      ['kadikoy', 'umraniye', 'maltepe', 'cekmekoy'],
  'kartal':        ['maltepe', 'pendik', 'sancaktepe', 'sultanbeyli'],
  'pendik':        ['kartal', 'tuzla', 'sultanbeyli', 'sancaktepe'],
  'tuzla':         ['pendik', 'sancaktepe', 'sultanbeyli', 'kartal'],
  'beykoz':        ['uskudar', 'cekmekoy', 'sariyer', 'umraniye'],
  'umraniye':      ['uskudar', 'cekmekoy', 'atasehir', 'sancaktepe'],
  'cekmekoy':      ['uskudar', 'umraniye', 'sancaktepe', 'beykoz'],
  'sancaktepe':    ['sultanbeyli', 'cekmekoy', 'umraniye', 'pendik'],
  'sultanbeyli':   ['sancaktepe', 'pendik', 'tuzla', 'kartal'],
  'sile':          ['beykoz', 'cekmekoy', 'sariyer', 'umraniye'],

  'besiktas':      ['sisli', 'sariyer', 'beyoglu', 'kagithane'],
  'sisli':         ['besiktas', 'kagithane', 'beyoglu', 'sariyer'],
  'beyoglu':       ['besiktas', 'sisli', 'fatih', 'kagithane'],
  'fatih':         ['beyoglu', 'eyupsultan', 'zeytinburnu', 'bayrampasa'],
  'sariyer':       ['besiktas', 'eyupsultan', 'sisli', 'kagithane'],
  'kagithane':     ['sisli', 'besiktas', 'eyupsultan', 'beyoglu'],
  'eyupsultan':    ['sariyer', 'kagithane', 'gaziosmanpasa', 'fatih'],
  'gaziosmanpasa': ['eyupsultan', 'sultangazi', 'bayrampasa', 'esenler'],
  'bayrampasa':    ['eyupsultan', 'gaziosmanpasa', 'esenler', 'fatih'],
  'sultangazi':    ['gaziosmanpasa', 'eyupsultan', 'esenler', 'arnavutkoy'],
  'esenler':       ['bayrampasa', 'bagcilar', 'gaziosmanpasa', 'gungoren'],
  'bagcilar':      ['esenler', 'bahcelievler', 'gungoren', 'basaksehir'],
  'bahcelievler':  ['bagcilar', 'gungoren', 'bakirkoy', 'kucukcekmece'],
  'bakirkoy':      ['bahcelievler', 'zeytinburnu', 'kucukcekmece', 'avcilar'],
  'kucukcekmece':  ['bahcelievler', 'bakirkoy', 'avcilar', 'basaksehir'],
  'avcilar':       ['kucukcekmece', 'beylikduzu', 'bakirkoy', 'basaksehir'],
  'beylikduzu':    ['avcilar', 'buyukcekmece', 'esenyurt', 'basaksehir'],
  'buyukcekmece':  ['beylikduzu', 'esenyurt', 'silivri', 'catalca'],
  'esenyurt':      ['beylikduzu', 'buyukcekmece', 'avcilar', 'basaksehir'],
  'basaksehir':    ['bagcilar', 'esenyurt', 'avcilar', 'arnavutkoy'],
  'arnavutkoy':    ['basaksehir', 'sultangazi', 'esenyurt', 'catalca'],
  'silivri':       ['buyukcekmece', 'catalca', 'arnavutkoy', 'esenyurt'],
  'catalca':       ['arnavutkoy', 'silivri', 'buyukcekmece', 'basaksehir'],
  'zeytinburnu':   ['bakirkoy', 'fatih', 'bahcelievler', 'eyupsultan'],
  'gungoren':      ['bagcilar', 'bahcelievler', 'esenler', 'bakirkoy'],
};

// İlçe slug -> Görüntü adı (Türkçe büyük harf düzgün)
const DISTRICT_NAMES = {
  'arnavutkoy': 'Arnavutköy', 'atasehir': 'Ataşehir', 'avcilar': 'Avcılar',
  'bagcilar': 'Bağcılar', 'bahcelievler': 'Bahçelievler', 'bakirkoy': 'Bakırköy',
  'basaksehir': 'Başakşehir', 'bayrampasa': 'Bayrampaşa', 'besiktas': 'Beşiktaş',
  'beykoz': 'Beykoz', 'beylikduzu': 'Beylikdüzü', 'beyoglu': 'Beyoğlu',
  'buyukcekmece': 'Büyükçekmece', 'catalca': 'Çatalca', 'cekmekoy': 'Çekmeköy',
  'esenler': 'Esenler', 'esenyurt': 'Esenyurt', 'eyupsultan': 'Eyüpsultan',
  'fatih': 'Fatih', 'gaziosmanpasa': 'Gaziosmanpaşa', 'gungoren': 'Güngören',
  'kadikoy': 'Kadıköy', 'kagithane': 'Kağıthane', 'kartal': 'Kartal',
  'kucukcekmece': 'Küçükçekmece', 'maltepe': 'Maltepe', 'pendik': 'Pendik',
  'sancaktepe': 'Sancaktepe', 'sariyer': 'Sarıyer', 'sile': 'Şile',
  'silivri': 'Silivri', 'sisli': 'Şişli', 'sultanbeyli': 'Sultanbeyli',
  'sultangazi': 'Sultangazi', 'tuzla': 'Tuzla', 'umraniye': 'Ümraniye',
  'uskudar': 'Üsküdar', 'zeytinburnu': 'Zeytinburnu',
};

// Hizmet ilişkileri (her hizmet için ilgili 4 hizmet)
const RELATED_SERVICES = {
  'kanalizasyon-acma':        ['gider-acma', 'rogar-acma', 'pissu-hatti-acma', 'kamera-ile-goruntuleme'],
  'gider-acma':               ['lavabo-acma', 'mutfak-gideri-acma', 'banyo-gideri-acma', 'tuvalet-acma'],
  'lavabo-acma':              ['gider-acma', 'mutfak-gideri-acma', 'banyo-gideri-acma', 'tuvalet-acma'],
  'tuvalet-acma':             ['lavabo-acma', 'pissu-hatti-acma', 'banyo-gideri-acma', 'gider-acma'],
  'mutfak-gideri-acma':       ['lavabo-acma', 'yag-tutucu-temizligi', 'gider-acma', 'banyo-gideri-acma'],
  'banyo-gideri-acma':        ['lavabo-acma', 'tuvalet-acma', 'gider-acma', 'mutfak-gideri-acma'],
  'rogar-acma':               ['kanalizasyon-acma', 'logar-tamiri', 'logar-kapagi-yenileme', 'pissu-hatti-acma'],
  'pissu-hatti-acma':         ['kanalizasyon-acma', 'rogar-acma', 'drenaj-kanali-acma', 'kamera-ile-goruntuleme'],
  'kamera-ile-goruntuleme':   ['boru-tespit', 'kanalizasyon-tamiri', 'ariza-noktasal-tespit', 'kanalizasyon-hatti-yenileme'],
  'basincli-su-temizligi':    ['kanalizasyon-acma', 'yag-tutucu-temizligi', 'pissu-hatti-acma', 'foseptik-temizligi'],
  'foseptik-temizligi':       ['vidanjor-hizmeti', 'foseptik-cukuru-acma', 'lagim-cukuru-acma', 'yag-tutucu-temizligi'],
  'yag-tutucu-temizligi':     ['foseptik-temizligi', 'vidanjor-hizmeti', 'mutfak-gideri-acma', 'basincli-su-temizligi'],
  'koku-giderme':             ['kanalizasyon-acma', 'pissu-hatti-acma', 'foseptik-temizligi', 'logar-tamiri'],
  'boru-tespit':              ['kamera-ile-goruntuleme', 'ariza-noktasal-tespit', 'kanalizasyon-tamiri', 'kanalizasyon-hatti-yenileme'],
  'apartman-site-sozlesmeli': ['kanalizasyon-acma', 'rogar-acma', 'foseptik-temizligi', 'kamera-ile-goruntuleme'],
  'ariza-noktasal-tespit':    ['boru-tespit', 'kamera-ile-goruntuleme', 'kanalizasyon-tamiri', 'kanalizasyon-hatti-yenileme'],
  'beton-kirma':              ['hafriyat-kazi', 'kanalizasyon-tamiri', 'kanalizasyon-hatti-yenileme', 'drenaj-hatti-yenileme'],
  'cekvalf-montaji':          ['dalgic-pompa-montaji', 'izolasyon-hizmetleri', 'kanalizasyon-baglantisi', 'logar-tamiri'],
  'dalgic-pompa-montaji':     ['cekvalf-montaji', 'izolasyon-hizmetleri', 'foseptik-cukuru-acma', 'drenaj-kuyusu-kuyu-acma'],
  'drenaj-hatti-yenileme':    ['drenaj-kanali-acma', 'drenaj-ustasi', 'kanalizasyon-hatti-yenileme', 'beton-kirma'],
  'drenaj-kanali-acma':       ['drenaj-hatti-yenileme', 'drenaj-ustasi', 'pissu-hatti-acma', 'rogar-acma'],
  'drenaj-kuyusu-kuyu-acma':  ['drenaj-kanali-acma', 'drenaj-hatti-yenileme', 'dalgic-pompa-montaji', 'foseptik-cukuru-acma'],
  'drenaj-ustasi':            ['drenaj-kanali-acma', 'drenaj-hatti-yenileme', 'drenaj-kuyusu-kuyu-acma', 'izolasyon-hizmetleri'],
  'foseptik-cukuru-acma':     ['foseptik-temizligi', 'vidanjor-hizmeti', 'lagim-cukuru-acma', 'kostebek-tunel-acma'],
  'hafriyat-kazi':            ['beton-kirma', 'kanalizasyon-hatti-yenileme', 'drenaj-hatti-yenileme', 'kostebek-tunel-acma'],
  'izolasyon-hizmetleri':     ['drenaj-ustasi', 'kanalizasyon-tamiri', 'logar-tamiri', 'cekvalf-montaji'],
  'kanalizasyon-baglantisi':  ['kanalizasyon-hatti-yenileme', 'kanalizasyon-tamiri', 'rogar-acma', 'logar-tamiri'],
  'kanalizasyon-hatti-yenileme': ['kanalizasyon-tamiri', 'kanalizasyon-baglantisi', 'kamera-ile-goruntuleme', 'beton-kirma'],
  'kanalizasyon-tamiri':      ['kanalizasyon-hatti-yenileme', 'kamera-ile-goruntuleme', 'boru-tespit', 'logar-tamiri'],
  'kostebek-tunel-acma':      ['hafriyat-kazi', 'beton-kirma', 'foseptik-cukuru-acma', 'lagim-cukuru-acma'],
  'lagim-cukuru-acma':        ['foseptik-cukuru-acma', 'foseptik-temizligi', 'vidanjor-hizmeti', 'kostebek-tunel-acma'],
  'logar-kapagi-yenileme':    ['logar-tamiri', 'rogar-acma', 'kanalizasyon-tamiri', 'kanalizasyon-baglantisi'],
  'logar-tamiri':             ['logar-kapagi-yenileme', 'rogar-acma', 'kanalizasyon-tamiri', 'kanalizasyon-baglantisi'],
  'vidanjor-hizmeti':         ['foseptik-temizligi', 'foseptik-cukuru-acma', 'yag-tutucu-temizligi', 'lagim-cukuru-acma'],
};

const SERVICE_NAMES = {
  'kanalizasyon-acma': 'Kanalizasyon Açma',
  'gider-acma': 'Gider Açma', 'lavabo-acma': 'Lavabo Açma', 'tuvalet-acma': 'Tuvalet Açma',
  'mutfak-gideri-acma': 'Mutfak Gideri Açma', 'banyo-gideri-acma': 'Banyo Gideri Açma',
  'rogar-acma': 'Rögar Açma', 'pissu-hatti-acma': 'Pissu Hattı Açma',
  'kamera-ile-goruntuleme': 'Kamera ile Görüntüleme', 'basincli-su-temizligi': 'Basınçlı Su Temizliği',
  'foseptik-temizligi': 'Foseptik Temizliği', 'yag-tutucu-temizligi': 'Yağ Tutucu Temizliği',
  'koku-giderme': 'Koku Giderme', 'boru-tespit': 'Boru Tespiti',
  'apartman-site-sozlesmeli': 'Apartman / Site Sözleşmeli', 'ariza-noktasal-tespit': 'Arıza Noktasal Tespit',
  'beton-kirma': 'Beton Kırma', 'cekvalf-montaji': 'Çekvalf Montajı',
  'dalgic-pompa-montaji': 'Dalgıç Pompa Montajı', 'drenaj-hatti-yenileme': 'Drenaj Hattı Yenileme',
  'drenaj-kanali-acma': 'Drenaj Kanalı Açma', 'drenaj-kuyusu-kuyu-acma': 'Drenaj Kuyusu Açma',
  'drenaj-ustasi': 'Drenaj Ustası', 'foseptik-cukuru-acma': 'Foseptik Çukuru Açma',
  'hafriyat-kazi': 'Hafriyat ve Kazı', 'izolasyon-hizmetleri': 'İzolasyon Hizmetleri',
  'kanalizasyon-baglantisi': 'Kanalizasyon Bağlantısı', 'kanalizasyon-hatti-yenileme': 'Kanalizasyon Hattı Yenileme',
  'kanalizasyon-tamiri': 'Kanalizasyon Tamiri', 'kostebek-tunel-acma': 'Köstebek Tünel Açma',
  'lagim-cukuru-acma': 'Lağım Çukuru Açma', 'logar-kapagi-yenileme': 'Logar Kapağı Yenileme',
  'logar-tamiri': 'Logar Tamiri', 'vidanjor-hizmeti': 'Vidanjör Hizmeti',
};

const MARKER = '<!-- RELATED-LINKS -->';

function buildSection(eyebrow, title, items, prefix) {
  const cards = items.map(it => `        <a href="${prefix}${it.href}" class="related-card">${it.label}</a>`).join('\n');
  return `\n${MARKER}\n  <section class="section section-soft related-section">\n    <div class="container">\n      <div class="section-head">\n        <span class="eyebrow">${eyebrow}</span>\n        <h2>${title}</h2>\n      </div>\n      <div class="related-grid">\n${cards}\n      </div>\n    </div>\n  </section>\n`;
}

function inject(file, html, section) {
  if (html.includes(MARKER)) return html; // idempotent
  // Try to inject before <section ...><div class="container"><div class="cta-banner"> sequence
  const ctaIdx = html.indexOf('class="cta-banner"');
  if (ctaIdx !== -1) {
    // Walk back to find the enclosing <section>
    const before = html.slice(0, ctaIdx);
    const sectionStart = before.lastIndexOf('<section');
    if (sectionStart !== -1) {
      return html.slice(0, sectionStart) + section.trimStart() + '\n' + html.slice(sectionStart);
    }
  }
  // Fallback: before <footer class="site-footer">
  const footerIdx = html.indexOf('<footer class="site-footer"');
  if (footerIdx !== -1) {
    return html.slice(0, footerIdx) + section.trimStart() + '\n' + html.slice(footerIdx);
  }
  return html;
}

let total = 0;

// İlçe sayfaları
const ilceDir = path.join(ROOT, 'ilceler');
for (const f of fs.readdirSync(ilceDir)) {
  if (!f.endsWith('.html') || f === 'index.html') continue;
  const slug = f.replace('.html', '');
  const neighbors = NEIGHBORS[slug];
  if (!neighbors) continue;
  const items = neighbors.map(n => ({ href: `${n}.html`, label: DISTRICT_NAMES[n] || n }));
  const section = buildSection('Yakın İlçeler', 'Bu Bölgeye Yakın Diğer İlçeler', items, '');
  const fp = path.join(ilceDir, f);
  let html = fs.readFileSync(fp, 'utf8');
  const out = inject(fp, html, section);
  if (out !== html) { fs.writeFileSync(fp, out); total++; console.log(`  ilceler/${f}  +${neighbors.length} neighbors`); }
}

// Hizmet sayfaları
const hizmetDir = path.join(ROOT, 'hizmetler');
for (const f of fs.readdirSync(hizmetDir)) {
  if (!f.endsWith('.html')) continue;
  const slug = f.replace('.html', '');
  const related = RELATED_SERVICES[slug];
  if (!related) continue;
  const items = related.map(r => ({ href: `${r}.html`, label: SERVICE_NAMES[r] || r }));
  const section = buildSection('İlgili Hizmetler', 'Diğer Uzmanlık Alanlarımız', items, '');
  const fp = path.join(hizmetDir, f);
  let html = fs.readFileSync(fp, 'utf8');
  const out = inject(fp, html, section);
  if (out !== html) { fs.writeFileSync(fp, out); total++; console.log(`  hizmetler/${f}  +${related.length} related`); }
}

console.log(`\nTotal pages updated: ${total}`);
