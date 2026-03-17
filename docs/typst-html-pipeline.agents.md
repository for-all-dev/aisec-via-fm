# Typst → HTML Pipeline Research

_Last updated: 2026-03-17_

## TL;DR Recommendation

Use **`@myriaddreamin/typst-ts-node-compiler`** (typst.ts) as the primary Node.js API.
For dev watch mode, run `typst watch --features html` as a sidecar from the Makefile.

---

## Option 1: `typst compile --features html` (Official, Experimental)

- Available since Typst 0.13.0 (Feb 2025), expanded in 0.14.0 (Oct 2025). Current stable: 0.14.2.
- Feature flag still required; **not recommended for production** upstream.

```bash
typst compile --features html --format html input.typ output.html
typst watch --features html input.typ output.html  # dev server on :3000
# or: TYPST_FEATURES=html typst compile ...
```

**What works:** headings, paragraphs, lists, images, footnotes, TOC, bibliography, code blocks, underline/strikethrough/sub/sup, meta tags, `html.*` typed element API (`html.div`, `html.elem`, etc.), `html.frame()` for layout-dependent content (renders as inline SVG).

**What's missing:**
- No CSS output — completely unstyled semantic HTML
- Single-file output only (multi-asset directories planned, not shipped)
- Math renders as inline SVG via `html.frame()` — MathML planned but not shipped
- Multi-document/bundled export still immature as of March 2026
- Existing `.typ` files may need `target` conditionals for good HTML output

**Watch mode:** Yes, `typst watch` with `--features html` launches a live-reloading HTTP server (`:3000`).

---

## Option 2: `typst.ts` / `@myriaddreamin/typst-ts-node-compiler` ⭐ Recommended

- Repo: https://github.com/Myriad-Dreamin/typst.ts (~1k stars, actively maintained)
- Rust-backed Node.js native addon — no shell-out required

```js
import { NodeCompiler } from '@myriaddreamin/typst-ts-node-compiler';

const $typst = NodeCompiler.create({ workspace: './paper' });
const result = await $typst.tryHtml({ mainFilePath: './paper/main.typ' });

result.result.html()      // full HTML document string
result.result.body()      // just <body> content
result.result.bodyBytes() // Uint8Array (no string allocation, faster)
result.result.title()     // document title
```

**Three rendering modes:**
1. `tryHtml()` — same experimental HTML exporter as above, but via Node API
2. `plainSvg()` / `svg()` — vector artifacts, embed directly in Next.js pages
3. typst.ts vector format → `@myriaddreamin/typst.react` React component (client-side, SVG-based, incremental/responsive)

**For this project (Next.js):**
- Run `NodeCompiler` in a build script or custom webpack plugin to walk `./paper/**/*.typ` at `next build` time
- Write outputs to `./website/src/generated/` (or inject directly into page data layer)
- Wrap output in `dangerouslySetInnerHTML` inside a Next.js page template; apply Tailwind classes
- Or parse the HTML AST with `rehype` to attach CSS classes programmatically
- For `next dev`: run `typst watch --features html` as a Makefile sidecar; Next.js watches generated files for HMR

**Caveats:**
- Native binary per platform (Linux/macOS/Windows, x64/arm64) — adds CI/Docker complexity; pre-built binaries available on npm
- HTML quality still depends on the same experimental exporter
- No built-in Node.js filesystem watcher; use sidecar `typst watch` or `chokidar`
- Fonts must be explicitly configured

---

## Option 3: Pandoc

- `pandoc --from typst --to html` works for basic prose
- **Not recommended** for this project: loses custom Typst functions, show rules, layout, and hayagriva bibliography integration
- Math output is actually better (MathJax/KaTeX) but the rest degrades too much

---

## Option 4: tinymist

- `tinymist export --format html` wraps the same typst HTML exporter
- No advantage over `typst compile` for pipeline use; useful if you want a single binary covering LSP + preview + export

---

## Summary Table

| Tool | HTML Quality | Math | Watch | Next.js Integration | Maturity |
|------|-------------|------|-------|--------------------|----|
| `typst compile --features html` | Semantic, unstyled | SVG frame | Built-in dev server | Shell out | Low–Med |
| **typst.ts NodeCompiler** | Same, via Node API | SVG frame | Via sidecar | Native Node API ⭐ | Med |
| typst.ts + React component | SVG vector render | SVG | Via sidecar | `@myriaddreamin/typst.react` | Med |
| Pandoc | Limited Typst support | MathJax/KaTeX | No (need sidecar) | Shell out | High/Low |
| tinymist | Same as typst CLI | SVG frame | No | Shell out | Med |

---

## Proposed Makefile Targets

```makefile
# Build: compile all .typ → HTML into website generated dir
paper-build:
	node scripts/compile-paper.mjs

# Dev: watch .typ files + run Next.js dev server concurrently
dev:
	concurrently \
	  "typst watch --features html paper/main.typ website/src/generated/paper.html" \
	  "cd website && pnpm run dev"
```

## Known Issues / Open Questions

- Math rendering: inline SVG is acceptable for MVP; watch for MathML support in Typst 0.15+
- Multi-chapter output: currently the whole paper compiles to one HTML blob; will need post-processing to split by chapter for the website's routing
- The `target` conditional pattern in Typst may be needed once we add layout-heavy content
