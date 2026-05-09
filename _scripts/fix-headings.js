const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const SKIP = new Set(['_generate', '_scripts', 'exiftool', 'node_modules', '.git', '.wrangler', 'dist']);

function walk(dir, out = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (SKIP.has(e.name)) continue;
    const full = path.join(dir, e.name);
    if (e.isDirectory()) walk(full, out);
    else if (e.name.endsWith('.html')) out.push(full);
  }
  return out;
}

let total = 0;
for (const f of walk(ROOT)) {
  let html = fs.readFileSync(f, 'utf8');
  const before = html;
  html = html.replace(/<h4(\s[^>]*)?>/g, '<h3$1>').replace(/<\/h4>/g, '</h3>');
  if (html !== before) {
    fs.writeFileSync(f, html);
    total++;
  }
}
console.log(`Updated ${total} files (h4 -> h3)`);
