const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const file = process.argv[2];
if (!file) { console.error('Usage: node optimize-one.js <filename.avif>'); process.exit(1); }

const IMG_DIR = path.join(__dirname, '..', 'assets', 'img');
const BACKUP_DIR = path.join(IMG_DIR, '_orig');
const HERO = new Set(['kanalizasyon-014.avif']);

(async () => {
  const src = path.join(BACKUP_DIR, file);
  const dst = path.join(IMG_DIR, file);
  if (!fs.existsSync(src)) { console.error('Not in _orig:', src); process.exit(1); }

  const settings = HERO.has(file) ? { maxWidth: 1280, quality: 55 } : { maxWidth: 1280, quality: 45 };
  const meta = await sharp(src).metadata();
  const targetWidth = Math.min(meta.width, settings.maxWidth);
  const before = fs.statSync(src).size;

  const buffer = await sharp(src)
    .resize({ width: targetWidth, withoutEnlargement: true })
    .avif({ quality: settings.quality, effort: 6 })
    .toBuffer();

  fs.writeFileSync(dst, buffer);
  console.log(`${file}: ${meta.width}x${meta.height} -> ${targetWidth}px  ${(before/1024).toFixed(0)}KB -> ${(buffer.length/1024).toFixed(0)}KB`);
})();
