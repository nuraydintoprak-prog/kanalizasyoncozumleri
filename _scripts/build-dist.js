const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const DIST = path.join(ROOT, 'dist');

const INCLUDE_FILES = [
  'index.html', 'hizmetler.html', 'hakkimizda.html', 'iletisim.html',
  'sss.html', 'kvkk.html', 'robots.txt', 'sitemap.xml', '_headers',
];
const INCLUDE_DIRS = ['hizmetler', 'ilceler', 'assets'];

if (fs.existsSync(DIST)) fs.rmSync(DIST, { recursive: true, force: true });
fs.mkdirSync(DIST, { recursive: true });

function copyRecursive(src, dst, depth = 0) {
  const stat = fs.statSync(src);
  if (stat.isDirectory()) {
    const base = path.basename(src);
    if (base === '_orig') return;
    fs.mkdirSync(dst, { recursive: true });
    let count = 0;
    for (const entry of fs.readdirSync(src)) {
      count += copyRecursive(path.join(src, entry), path.join(dst, entry), depth + 1);
    }
    return count;
  } else {
    fs.copyFileSync(src, dst);
    return 1;
  }
}

let total = 0;
for (const f of INCLUDE_FILES) {
  const src = path.join(ROOT, f);
  if (fs.existsSync(src)) { fs.copyFileSync(src, path.join(DIST, f)); total++; }
}
for (const d of INCLUDE_DIRS) {
  const src = path.join(ROOT, d);
  if (fs.existsSync(src)) total += copyRecursive(src, path.join(DIST, d));
}

const dirSize = (p) => {
  let size = 0;
  for (const e of fs.readdirSync(p, { withFileTypes: true })) {
    const full = path.join(p, e.name);
    size += e.isDirectory() ? dirSize(full) : fs.statSync(full).size;
  }
  return size;
};
console.log(`Built dist/ with ${total} files, ${(dirSize(DIST)/1024/1024).toFixed(2)} MB`);
