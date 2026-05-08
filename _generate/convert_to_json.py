# PS1 veri dosyalarini JSON'a ceviren converter.
# Kullanim: python convert_to_json.py C:/claude/gun2/_generate

import re, json, os, sys, glob

def parse_ps_string(raw):
    """PowerShell string değerini parse et — hem tek hem karışık tırnak destekli."""
    raw = raw.strip()
    if not raw:
        return ''
    # tek tırnaklı: 'değer' ('' kaçış karakteri içinde)
    if raw[0] == "'":
        out, i = [], 1
        while i < len(raw):
            if raw[i] == "'" and i+1 < len(raw) and raw[i+1] == "'":
                out.append("'"); i += 2
            elif raw[i] == "'":
                break
            else:
                out.append(raw[i]); i += 1
        return ''.join(out)
    # çift tırnaklı başlayıp tek tırnaklı biten (bozuk format): "değer''ek'
    if raw[0] == '"':
        out, i = [], 1
        while i < len(raw):
            if raw[i] == '"':
                break
            elif raw[i] == "'" and i+1 < len(raw) and raw[i+1] == "'":
                out.append("'"); i += 2
            elif raw[i] == "'":
                break  # bozuk kapanış
            else:
                out.append(raw[i]); i += 1
        return ''.join(out)
    # tırnaksız (sayı vs)
    try:
        return int(raw)
    except:
        return raw.strip("'\"")

def extract_balanced(text, start, open_ch='@{', close_ch='}'):
    """Dengesiz parantez/küme için eşleşen kapanışı bul."""
    depth = 0
    i = start
    while i < len(text):
        # @( veya @{ aç
        if text[i:i+2] in ('@{', '@('):
            depth += 1; i += 2
        elif text[i] in ('}', ')'):
            depth -= 1
            if depth == 0:
                return i
            i += 1
        else:
            i += 1
    return -1

def parse_simple_array(text):
    """@('a','b','c') formatını liste olarak parse et."""
    text = text.strip()
    if text.startswith('@('):
        text = text[2:]
        if text.endswith(')'):
            text = text[:-1]
    items = []
    for part in re.split(r",\s*", text):
        part = part.strip()
        if part:
            items.append(parse_ps_string(part))
    return items

def parse_hash_array(text):
    """@(@{k=v;k=v}, @{...}) formatını dict listesi olarak parse et."""
    items = []
    i = 0
    while i < len(text):
        idx = text.find('@{', i)
        if idx == -1:
            break
        end = extract_balanced(text, idx, '@{', '}')
        if end == -1:
            break
        block = text[idx+2:end]
        d = {}
        for m in re.finditer(r"(\w+)\s*=\s*'((?:[^']|'')*)'", block):
            d[m.group(1)] = m.group(2).replace("''", "'")
        items.append(d)
        i = end + 1
    return items

def parse_neighbor_array(text):
    items = []
    for m in re.finditer(r"@\{slug='([^']+)'[^}]*name='([^']+)'", text):
        items.append({'slug': m.group(1), 'name': m.group(2)})
    return items

def parse_district_block(block):
    d = {}

    # --- Tek satır basit alanlar ---
    # slug, side, locSuffix (tek tırnak)
    for field in ['slug','side','locSuffix']:
        m = re.search(rf"{field}\s*=\s*'((?:[^']|'')*)'", block)
        if m:
            d[field] = m.group(1).replace("''","'")

    # name — bazen Türkçe karakter içeriyor
    m = re.search(r"name\s*=\s*'((?:[^']|'')*)'", block)
    if m:
        d['name'] = m.group(1).replace("''","'")

    # photo (sayı)
    m = re.search(r"photo\s*=\s*(\d+)", block)
    if m:
        d['photo'] = int(m.group(1))

    # loc, gen, dat — bozuk çift tırnak başlı olabilir: field="değer''ek'
    for field in ['loc','gen','dat']:
        m = re.search(rf"{field}=[\"']((?:[^\"']|'')*)[\"']", block)
        if m:
            d[field] = m.group(1).replace("''","'")

    # --- Uzun metin alanları (çok satır olabilir) ---
    for field in ['intro','para1','para2','problemsIntro','calloutsIntro',
                  'extraTitle','extraBody','timesIntro','closing']:
        # tek tırnaktan başlayıp tek tırnağa kadar ('' escape destekli)
        m = re.search(rf"{field}\s*=\s*'((?:[^']|'')*)'", block, re.DOTALL)
        if m:
            d[field] = m.group(1).replace("''","'")

    # --- Diziler ---
    m = re.search(r"mahalleler\s*=\s*@\((.*?)\)", block, re.DOTALL)
    if m:
        d['mahalleler'] = [x.strip().strip("'") for x in re.split(r",\s*", m.group(1)) if x.strip().strip("'")]

    for arr_field in ['problems','callouts','times','faqs']:
        m = re.search(rf"{arr_field}\s*=\s*(@\(.*?\))\s*(?:\n|$|\w)", block, re.DOTALL)
        if m:
            d[arr_field] = parse_hash_array(m.group(1))

    m = re.search(r"neighborLinks\s*=\s*(@\(.*?\))", block, re.DOTALL)
    if m:
        d['neighborLinks'] = parse_neighbor_array(m.group(1))

    return d

def parse_service_block(block):
    """Service blokları için (district ile benzer yapı)."""
    return parse_district_block(block)  # alan isimleri örtüşüyor

def convert_file(filepath):
    with open(filepath, encoding='utf-8', errors='replace') as f:
        content = f.read()

    # Her @{ ... } bloğunu bul
    items = []
    i = 0
    while True:
        idx = content.find('@{', i)
        if idx == -1:
            break
        # $script:DistrictData += @( içindeki ana @{ bloklarını al
        end = extract_balanced(content, idx)
        if end == -1:
            break
        block = content[idx+2:end]
        # Sadece slug alanı olan bloklar gerçek data
        if re.search(r"slug\s*=", block):
            parsed = parse_district_block(block)
            if parsed.get('slug'):
                items.append(parsed)
        i = end + 1

    return items

def main():
    if len(sys.argv) < 2:
        gen_dir = os.path.dirname(os.path.abspath(__file__))
    else:
        gen_dir = sys.argv[1]

    pattern = os.path.join(gen_dir, '*.ps1')
    files = [f for f in glob.glob(pattern)
             if os.path.basename(f) not in ('run.ps1', 'templates.ps1')]

    if not files:
        print(f"PS1 dosyası bulunamadı: {pattern}")
        return

    all_districts = []
    all_services = []

    for fp in sorted(files):
        base = os.path.basename(fp)
        items = convert_file(fp)
        print(f"{base}: {len(items)} kayıt")
        if 'district' in base:
            all_districts.extend(items)
        elif 'service' in base:
            all_services.extend(items)
        else:
            # slug varsa district kabul et
            all_districts.extend(items)

    # JSON yaz
    dist_out = os.path.join(gen_dir, 'districts.json')
    svc_out  = os.path.join(gen_dir, 'services.json')

    with open(dist_out, 'w', encoding='utf-8') as f:
        json.dump(all_districts, f, ensure_ascii=False, indent=2)
    print(f"\n✓ {dist_out}  ({len(all_districts)} ilçe)")

    if all_services:
        with open(svc_out, 'w', encoding='utf-8') as f:
            json.dump(all_services, f, ensure_ascii=False, indent=2)
        print(f"✓ {svc_out}  ({len(all_services)} hizmet)")

if __name__ == '__main__':
    main()
