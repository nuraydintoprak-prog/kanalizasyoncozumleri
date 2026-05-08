const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const SKIP_DIRS = new Set(['_generate', '_scripts', 'exiftool', 'node_modules', '.git', '.wrangler']);
const SITE = 'https://kanalizasyoncozumleri.com.tr';
const DEFAULT_IMG = 'kanalizasyon-014.avif';

function walk(dir, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (SKIP_DIRS.has(entry.name)) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, out);
    else if (entry.name.endsWith('.html')) out.push(full);
  }
  return out;
}

function update(file) {
  const rel = path.relative(ROOT, file).replace(/\\/g, '/');
  let html = fs.readFileSync(file, 'utf8');

  if (html.includes('property="og:image"')) return false;

  const imgMatch = html.match(/<img\s+[^>]*src="(?:\.\.\/)?(assets\/img\/kanalizasyon-\d+\.avif)"/);
  const imgPath = imgMatch ? imgMatch[1] : `assets/img/${DEFAULT_IMG}`;
  const imgUrl = `${SITE}/${imgPath}`;

  const ogBlock =
    `\n<meta property="og:image" content="${imgUrl}" />\n` +
    `<meta property="og:image:width" content="1200" />\n` +
    `<meta property="og:image:height" content="630" />`;

  const ogAnchorRe = /(<meta\s+property="og:url"\s+content="[^"]+"\s*\/>)/i;
  const ogAnchorRe2 = /(<meta\s+property="og:description"\s+content="[^"]+"\s*\/>)/i;
  const ogAnchorRe3 = /(<meta\s+property="og:title"\s+content="[^"]+"\s*\/>)/i;

  if (ogAnchorRe.test(html)) html = html.replace(ogAnchorRe, '$1' + ogBlock);
  else if (ogAnchorRe2.test(html)) html = html.replace(ogAnchorRe2, '$1' + ogBlock);
  else if (ogAnchorRe3.test(html)) html = html.replace(ogAnchorRe3, '$1' + ogBlock);
  else return false;

  if (html.includes('name="twitter:card"') && !html.includes('name="twitter:image"')) {
    const twAnchor = /(<meta\s+name="twitter:description"\s+content="[^"]+"\s*\/>)/i;
    if (twAnchor.test(html)) {
      html = html.replace(twAnchor, `$1\n<meta name="twitter:image" content="${imgUrl}" />`);
    }
  }

  fs.writeFileSync(file, html);
  console.log(`  ${rel}  -> ${path.basename(imgPath)}`);
  return true;
}

const files = walk(ROOT);
let count = 0;
for (const f of files) if (update(f)) count++;
console.log(`\nAdded og:image to: ${count} files`);
