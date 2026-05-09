const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const IMG_DIR = path.join(__dirname, '..', 'assets', 'img');
const BACKUP_DIR = path.join(IMG_DIR, '_orig');
const HERO_FILE = 'kanalizasyon-014.avif';

const SIZES = [
  { width: 480, quality: 50, suffix: '-480' },
  { width: 768, quality: 50, suffix: '-768' },
  { width: 1152, quality: 50, suffix: '' },
];

(async () => {
  const src = path.join(BACKUP_DIR, HERO_FILE);
  if (!fs.existsSync(src)) { console.error('Missing _orig source:', src); process.exit(1); }

  for (const s of SIZES) {
    const outName = HERO_FILE.replace('.avif', s.suffix + '.avif');
    const out = path.join(IMG_DIR, outName);
    const buf = await sharp(src)
      .resize({ width: s.width, withoutEnlargement: true })
      .avif({ quality: s.quality, effort: 6 })
      .toBuffer();
    fs.writeFileSync(out, buf);
    console.log(`${outName}  ${s.width}w  ${(buf.length/1024).toFixed(0)} KB`);
  }
})();
