import { NodeCompiler } from "@myriaddreamin/typst-ts-node-compiler"
import fs from "fs"
import path from "path"

const PAPER_DIR = path.join(process.cwd(), "..", "paper")

let _compiler: NodeCompiler | null = null
function getCompiler(): NodeCompiler {
  if (!_compiler) {
    _compiler = NodeCompiler.create({ workspace: PAPER_DIR })
  }
  return _compiler
}

/**
 * Compile a typst fragment (relative to paper/) to an HTML body string.
 * Creates a temporary wrapper that imports common fns and includes the fragment.
 *
 * Handles `<prefix:label>` and `@prefix:label` cross-references (sec, fig, tab):
 * - Labels on headings become `id` attributes in the HTML
 * - @prefix:label references become <a href="#prefix:label"> links
 * Cross-fragment references (to labels defined in other files) are supported
 * because we pre-process the source to replace refs with placeholders
 * before compilation, then post-process the HTML.
 */
export function compileFragmentToHtml(relPath: string): string {
  const uid = Math.random().toString(36).slice(2, 10)
  const srcPath = path.join(PAPER_DIR, relPath)
  const src = fs.readFileSync(srcPath, "utf-8")

  // Recognized label prefixes: sec (sections), fig (figures), tab (tables)
  const LABEL_RE = /(?:sec|fig|tab):[a-z0-9-]+/

  // Extract labels: heading lines like `== Title <sec:some-label>`
  // Map from heading text (trimmed) -> label
  const labelsByHeading = new Map<string, string>()
  for (const m of src.matchAll(new RegExp(`^(=+)\\s+(.+?)\\s+<(${LABEL_RE.source})>\\s*$`, "gm"))) {
    labelsByHeading.set(m[2].trim(), m[3])
  }

  // Replace @prefix:... references with a placeholder that survives compilation.
  // Use backtick-wrapped raw text so typst passes it through verbatim.
  const processed = src.replace(
    new RegExp(`@(${LABEL_RE.source})`, "g"),
    (_match, label) => `\`XREF:${label}\``,
  )

  // Write the processed source to a temp file and build a wrapper around it
  const tmpSrcPath = path.join(PAPER_DIR, `__src_${uid}.typ`)
  const wrapperPath = path.join(PAPER_DIR, `__wrapper_${uid}.typ`)
  fs.writeFileSync(tmpSrcPath, processed)
  const wrapperRelSrc = path.basename(tmpSrcPath)
  const wrapper = `#import "common/fns.typ": *\n#include "${wrapperRelSrc}"\n#bibliography("refs.bib")\n`
  fs.writeFileSync(wrapperPath, wrapper)
  try {
    const c = getCompiler()
    const bytes = c.html({ mainFilePath: wrapperPath })
    if (!bytes) throw new Error(`typst compilation returned null for ${relPath}`)
    let html = Buffer.from(bytes).toString("utf-8")
    // Extract just the <body> content
    const bodyMatch = html.match(/<body>([\s\S]*)<\/body>/)
    html = bodyMatch ? bodyMatch[1].trim() : html

    // Post-process: add id attributes to headings that had labels
    for (const [headingText, label] of labelsByHeading) {
      // The heading text appears inside <hN>...</hN> tags.
      // Escape regex special chars in heading text.
      const escaped = headingText.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
      html = html.replace(
        new RegExp(`(<h[1-6])([^>]*>\\s*${escaped})`),
        `$1 id="${label}"$2`,
      )
    }

    // Post-process: replace XREF:prefix:label placeholders with anchor links.
    // The backtick-wrapped placeholder becomes <code>XREF:prefix:label</code> in HTML.
    const DISPLAY: Record<string, string> = { sec: "§", fig: "Fig.", tab: "Tab." }
    html = html.replace(
      new RegExp(`<code>XREF:(${LABEL_RE.source})<\\/code>`, "g"),
      (_match, label) => {
        const prefix = label.split(":")[0]
        const sym = DISPLAY[prefix] ?? "§"
        return `<a href="#${label}" class="${prefix}-ref">${sym}</a>`
      },
    )

    return html
  } finally {
    fs.unlinkSync(wrapperPath)
    fs.unlinkSync(tmpSrcPath)
  }
}
