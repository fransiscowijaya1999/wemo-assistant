// Copies pdf.js's wasm image decoders (JBIG2/JPX/qcms) into public/pdfjs-wasm so
// the app can pass them as `wasmUrl` to getDocument(). The catalog diagrams are
// JBIG2 stencils — without these, pdf.js silently renders pages with a blank
// diagram region. public/pdfjs-wasm is gitignored; this runs before dev/build so
// the copy always matches the installed pdfjs-dist version.
import { cp, mkdir } from 'fs/promises';
import { createRequire } from 'module';
import path from 'path';
import { fileURLToPath } from 'url';

const here = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);
const src = path.join(path.dirname(require.resolve('pdfjs-dist/package.json')), 'wasm');
const dest = path.join(here, '..', 'public', 'pdfjs-wasm');

await mkdir(dest, { recursive: true });
await cp(src, dest, { recursive: true });
console.log(`copied pdfjs wasm -> ${dest}`);
