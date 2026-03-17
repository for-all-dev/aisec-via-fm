# Website Implementation Notes

## Architecture

- Next.js 16.1.7 App Router, statically generated, Vercel-ready
- All pages use `export const dynamic = "force-static"` — file reads happen at build time
- `proxy.ts` (Next.js 16 renamed middleware → proxy) handles password protection
- Password stored in `PASSWORD` env var; checked against `pw-session` cookie

## Content Pipeline

1. `website/lib/typst-parser.ts` — pure parser: typst syntax → structured TS types
   - Parses `= h1`, `== h2`, `=== h3`, `#lorem(n)` (substitutes lorem ipsum), `// Tag:`, `// Layers:`, `// Authors:` comments
2. `website/lib/content.ts` — uses Effect for parallel file reads
   - Reads from `../paper/` relative to `website/` (i.e., `process.cwd()`)
   - Returns `{ stack: StackLayer[], problems: ParsedProblem[] }`

## Routes

- `/` — homepage, stack layer dropdowns + problems index + calendly link
- `/about` — authors, partial authorship shown per author from problem `// Authors:` tags
- `/problems` — all problems list
- `/problems/[id]` — individual problem detail with stack context

## Authorship System

Problem `.typ` files support `// Authors: Name1, Name2` comments.
If absent from a problem, that problem shows under all authors on the `/about` page (by design — update when real authorship is known).

To add authorship to a problem, edit e.g.:
```
// Authors: Quinn Dougherty
```
at the top of the relevant `paper/problems/<id>.typ` file.

## Colors

tsdh-dark palette from Doom Emacs, defined as CSS variables in `globals.css`.
Key vars: `--bg`, `--fg`, `--green`, `--yellow`, `--blue`, `--muted`, `--border`.

## Next Steps

- Add `// Authors:` to problem .typ files as authorship becomes clear
- Add real content (replace `#lorem(n)` in .typ files) — parser handles it transparently
- Retrofit Supabase for commenting if desired (see CLAUDE.md)
- Consider adding PDF download link once paper is compiled
