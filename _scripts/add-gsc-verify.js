const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const SKIP = new Set(['_generate', '_scripts', 'exiftool', 'node_modules', '.git', '.wrangler', 'dist']);
const TAG = '<meta name="google-site-verification" content="1ePYdYqADfOcncdgRKrHZ-H3hRmWDobPCAX3FEZUeAQ" />';

function walk(dir, out = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (SKIP.has(e.name)) continue;
    const full = path.join(dir, e.name);
    if (e.isDirectory()) walk(full, out);
    else if (e.name.endsWith('.html')) out.push(full);
  }
  return out;
}

let count = 0;
for (const f of walk(ROOT)) {
  let html = fs.readFileSync(f, 'utf8');
  if (html.includes('google-site-verification')) continue;
  const anchor = /(<meta\s+name="viewport"[^>]*\/>)/;
  if (!anchor.test(html)) continue;
  html = html.replace(anchor, '$1\n' + TAG);
  fs.writeFileSync(f, html);
  count++;
}
console.log(`Added GSC verification to ${count} files`);
