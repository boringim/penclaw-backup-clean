const fs = require('fs');
const path = require('path');

const sources = [
  'C:/Users/Administrator/.openclaw/memory/group-oc-981e.sqlite',
  'C:/Users/Administrator/.openclaw/backup/db/group-oc-981e.sqlite',
  'C:/Users/Administrator/.openclaw/backup/db/index.sqlite',
  'C:/Users/Administrator/.openclaw/backup/db/first_party_sets.db',
  'C:/Users/Administrator/.openclaw/backup/db/heavy_ad_intervention_opt_out.db'
];

const outDir = 'C:/Users/Administrator/backups/openclaw/db';
fs.mkdirSync(outDir, { recursive: true });

const ts = new Date().toISOString().replace(/[:T]/g, '-').slice(0, 19);
let copied = 0;
let skipped = 0;

for (const src of sources) {
  if (!fs.existsSync(src)) {
    console.log(`[SKIP] missing: ${src}`);
    skipped++;
    continue;
  }
  const base = path.basename(src);
  const dest = path.join(outDir, `${base}.${ts}.bak`);
  fs.copyFileSync(src, dest);
  const size = fs.statSync(dest).size;
  console.log(`[OK] ${src} -> ${dest} (${size} bytes)`);
  copied++;
}

console.log(`[SUMMARY] copied=${copied} skipped=${skipped} outDir=${outDir}`);
if (copied === 0) process.exit(1);
