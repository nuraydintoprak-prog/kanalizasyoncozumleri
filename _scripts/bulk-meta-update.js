const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const SKIP_DIRS = new Set(['_generate', '_scripts', 'exiftool', 'node_modules', '.git', '.wrangler']);

const FONT_URL = 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap';

const FONT_BLOCK_NEW =
  `<link rel="preload" as="style" href="${FONT_URL}" />\n` +
  `<link rel="stylesheet" href="${FONT_URL}" media="print" onload="this.media='all'" />\n` +
  `<noscript><link rel="stylesheet" href="${FONT_URL}" /></noscript>`;

function walk(dir, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (SKIP_DIRS.has(entry.name)) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, out);
    else if (entry.name.endsWith('.html')) out.push(full);
  }
  return out;
}

function getMeta(html, propOrName) {
  const re = new RegExp(`<meta\\s+(?:property|name)=["']${propOrName}["']\\s+content=["']([^"']+)["']`, 'i');
  const m = html.match(re);
  return m ? m[1] : null;
}

function getTitle(html) {
  const m = html.match(/<title>([^<]+)<\/title>/);
  return m ? m[1].trim() : null;
}

function getDesc(html) {
  return getMeta(html, 'description');
}

function update(file) {
  const rel = path.relative(ROOT, file);
  let html = fs.readFileSync(file, 'utf8');
  const before = html;
  const changes = [];

  // 1. FONT — replace the existing single <link href="...family=Inter..." rel="stylesheet" />
  if (!html.includes('media="print" onload="this.media=\'all\'"')) {
    const fontLinkRe = /<link\s+href="https:\/\/fonts\.googleapis\.com\/css2\?family=Inter[^"]*"\s+rel="stylesheet"\s*\/>/;
    if (fontLinkRe.test(html)) {
      html = html.replace(fontLinkRe, FONT_BLOCK_NEW);
      changes.push('font-async');
    }
  }

  // 2. TWITTER CARD — insert after og:image meta, or after og:url if no og:image yet
  if (!html.includes('name="twitter:card"')) {
    const ogTitle = getMeta(html, 'og:title') || getTitle(html);
    const ogDesc = getMeta(html, 'og:description') || getDesc(html);
    const ogImg = getMeta(html, 'og:image');
    if (ogTitle && ogDesc) {
      const twitterBlock =
        `\n\n<meta name="twitter:card" content="summary_large_image" />\n` +
        `<meta name="twitter:title" content="${ogTitle.replace(/"/g, '&quot;')}" />\n` +
        `<meta name="twitter:description" content="${ogDesc.replace(/"/g, '&quot;')}" />` +
        (ogImg ? `\n<meta name="twitter:image" content="${ogImg}" />` : '');

      if (ogImg) {
        const ogImgLineRe = /(<meta\s+property="og:image"\s+content="[^"]+"\s*\/>(?:\s*<meta\s+property="og:image:[^"]+"\s+content="[^"]+"\s*\/>)*)/;
        if (ogImgLineRe.test(html)) {
          html = html.replace(ogImgLineRe, '$1' + twitterBlock);
          changes.push('twitter');
        }
      } else {
        // No og:image — insert after og:description or og:url
        const anchorRe = /(<meta\s+property="og:(?:url|description|title)"\s+content="[^"]+"\s*\/>)(?![\s\S]*<meta\s+property="og:url")/i;
        if (anchorRe.test(html)) {
          html = html.replace(anchorRe, '$1' + twitterBlock);
          changes.push('twitter-noimg');
        }
      }
    }
  }

  // 3. HERO IMAGE: change first <img loading="lazy"> to eager + fetchpriority="high"
  // Skip if already has fetchpriority anywhere (idempotent)
  if (!html.includes('fetchpriority="high"')) {
    const firstImgLazyRe = /(<img\s+[^>]*?)loading="lazy"([^>]*?>)/;
    const m = html.match(firstImgLazyRe);
    if (m) {
      const fixed = m[1] + 'loading="eager" fetchpriority="high"' + m[2];
      html = html.replace(firstImgLazyRe, fixed);
      changes.push('hero-eager');
    }
  }

  if (html !== before) {
    fs.writeFileSync(file, html);
    console.log(`  ${rel}  [${changes.join(', ')}]`);
    return true;
  }
  return false;
}

const files = walk(ROOT);
console.log(`Total HTML files: ${files.length}\n`);
let count = 0;
for (const f of files) if (update(f)) count++;
console.log(`\nUpdated: ${count} / ${files.length}`);
