const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const IMG_DIR = path.join(__dirname, '..', 'assets', 'img');
const BACKUP_DIR = path.join(IMG_DIR, '_orig');

if (!fs.existsSync(BACKUP_DIR)) fs.mkdirSync(BACKUP_DIR, { recursive: true });

const TARGETS = {
  default: { maxWidth: 1280, quality: 45, effort: 6 },
  hero: { maxWidth: 1280, quality: 55, effort: 6 },
};

const HERO_IMAGES = new Set(['kanalizasyon-014.avif']);

async function optimize(file) {
  const src = path.join(IMG_DIR, file);
  const backup = path.join(BACKUP_DIR, file);
  const stat = fs.statSync(src);
  const beforeKB = (stat.size / 1024).toFixed(0);

  if (!fs.existsSync(backup)) fs.copyFileSync(src, backup);

  const settings = HERO_IMAGES.has(file) ? TARGETS.hero : TARGETS.default;
  const meta = await sharp(backup).metadata();
  const targetWidth = Math.min(meta.width, settings.maxWidth);

  const buffer = await sharp(backup)
    .resize({ width: targetWidth, withoutEnlargement: true })
    .avif({ quality: settings.quality, effort: settings.effort })
    .toBuffer();

  fs.writeFileSync(src, buffer);
  const afterKB = (buffer.length / 1024).toFixed(0);
  const savedPct = ((1 - buffer.length / stat.size) * 100).toFixed(0);
  console.log(`${file.padEnd(28)} ${meta.width}x${meta.height} -> ${targetWidth}px  ${beforeKB}KB -> ${afterKB}KB  (-${savedPct}%)`);
  return { before: stat.size, after: buffer.length };
}

(async () => {
  const files = fs.readdirSync(IMG_DIR)
    .filter(f => f.startsWith('kanalizasyon-') && f.endsWith('.avif'))
    .sort();

  let totalBefore = 0, totalAfter = 0;
  for (const f of files) {
    const { before, after } = await optimize(f);
    totalBefore += before;
    totalAfter += after;
  }

  const beforeMB = (totalBefore / 1024 / 1024).toFixed(2);
  const afterMB = (totalAfter / 1024 / 1024).toFixed(2);
  const savedPct = ((1 - totalAfter / totalBefore) * 100).toFixed(0);
  console.log(`\nTotal: ${beforeMB}MB -> ${afterMB}MB  (-${savedPct}%)`);
})();
