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

// Recognized label prefixes: sec (sections), fig (figures), tab (tables)
const LABEL_RE = /(?:sec|fig|tab):[a-z0-9-]+/

/** A single entry in the cross-reference label registry. */
export interface LabelEntry {
  /** The label string, e.g. "sec:oci-hardening" */
  label: string
  /** Which prefix: "sec", "fig", or "tab" */
  kind: "sec" | "fig" | "tab"
  /** The route on the website where this label lives, e.g. "/problems/oci-runtime-hardening" */
  route: string
  /** Human-readable title or caption for hover previews */
  title: string
  /** Plain-text preview of the section content (first ~300 chars) */
  preview?: string
}

/**
 * Extract a plain-text preview from the typst source starting after a given
 * match index. Grabs the first non-empty, non-comment, non-directive lines
 * up to ~300 chars.
 */
function extractPreviewAfter(src: string, matchEnd: number): string {
  const rest = src.slice(matchEnd)
  const lines = rest.split("\n")
  let preview = ""
  for (const line of lines) {
    const trimmed = line.trim()
    // skip blanks, comments, typst directives, headings
    if (!trimmed || trimmed.startsWith("//") || trimmed.startsWith("#") || trimmed.startsWith("=")) continue
    if (preview) preview += " "
    preview += trimmed
    if (preview.length >= 300) break
  }
  // Strip typst markup: @refs, inline code, emphasis markers, links
  preview = preview
    .replace(/@[\w:-]+/g, "")
    .replace(/`[^`]*`/g, "")
    .replace(/\*([^*]+)\*/g, "$1")
    .replace(/_([^_]+)_/g, "$1")
    .replace(/#link\([^)]*\)\[[^\]]*\]/g, "")
    .replace(/\s+/g, " ")
    .trim()
  return preview.slice(0, 300) + (preview.length > 300 ? "…" : "")
}

/**
 * Scan a typst source string for label definitions.
 * Returns an array of { label, kind, title, preview } objects (route is filled in by the caller).
 */
export function extractLabels(src: string): Omit<LabelEntry, "route">[] {
  const results: Omit<LabelEntry, "route">[] = []

  // Heading labels: `== Some Title <sec:some-label>`
  const headingRe = new RegExp(`^=+\\s+(.+?)\\s+<(${LABEL_RE.source})>\\s*$`, "gm")
  for (const m of src.matchAll(headingRe)) {
    const title = m[1].trim()
    const label = m[2]
    const kind = label.split(":")[0] as LabelEntry["kind"]
    const preview = extractPreviewAfter(src, m.index! + m[0].length)
    results.push({ label, kind, title, preview })
  }

  // Figure labels: `caption: [text]` followed by `<fig:...>` nearby
  for (const m of src.matchAll(new RegExp(`caption:\\s*\\[([^\\]]+)\\][^<]*<(fig:[a-z0-9-]+)>`, "g"))) {
    const title = m[1].trim()
    const label = m[2]
    if (!results.some((r) => r.label === label)) {
      results.push({ label, kind: "fig", title })
    }
  }

  // Table labels: same pattern for tab:
  for (const m of src.matchAll(new RegExp(`caption:\\s*\\[([^\\]]+)\\][^<]*<(tab:[a-z0-9-]+)>`, "g"))) {
    const title = m[1].trim()
    const label = m[2]
    if (!results.some((r) => r.label === label)) {
      results.push({ label, kind: "tab", title })
    }
  }

  // Standalone fig:/tab: labels on their own line (no caption extracted)
  for (const m of src.matchAll(new RegExp(`^\\s*<((fig|tab):[a-z0-9-]+)>\\s*$`, "gm"))) {
    const label = m[1]
    const kind = m[2] as LabelEntry["kind"]
    if (!results.some((r) => r.label === label)) {
      results.push({ label, kind, title: label })
    }
  }

  return results
}

/**
 * Compile an inline typst snippet (not a file) to HTML.
 * Useful for rendering variables like paper_abstract.
 */
export function compileSnippetToHtml(snippet: string): string {
  const uid = Math.random().toString(36).slice(2, 10)
  const tmpPath = path.join(PAPER_DIR, `__snippet_${uid}.typ`)
  fs.writeFileSync(tmpPath, snippet + '\n#bibliography("common/refs.bib")\n')
  try {
    const c = getCompiler()
    const bytes = c.html({ mainFilePath: tmpPath })
    if (!bytes) throw new Error("typst snippet compilation returned null")
    let html = Buffer.from(bytes).toString("utf-8")
    const bodyMatch = html.match(/<body>([\s\S]*)<\/body>/)
    html = bodyMatch ? bodyMatch[1].trim() : html
    return html
  } finally {
    fs.unlinkSync(tmpPath)
  }
}

/**
 * Compile a typst fragment (relative to paper/) to an HTML body string.
 * Creates a temporary wrapper that imports common fns and includes the fragment.
 *
 * Handles `<prefix:label>` and `@prefix:label` cross-references (sec, fig, tab):
 * - Labels on headings become `id` attributes in the HTML
 * - Non-heading labels (fig:, tab:) get id attributes via placeholder injection
 * - @prefix:label references become <a href="..."> links, resolved against
 *   the label registry for cross-page refs
 *
 * @param relPath - path relative to paper/, e.g. "problems/oci-runtime-hardening.typ"
 * @param labelRegistry - map from label string to LabelEntry, for cross-page resolution
 */
export function compileFragmentToHtml(
  relPath: string,
  labelRegistry?: Map<string, LabelEntry>,
): string {
  const uid = Math.random().toString(36).slice(2, 10)
  const srcPath = path.join(PAPER_DIR, relPath)
  const src = fs.readFileSync(srcPath, "utf-8")

  // Extract labels: heading lines like `== Title <sec:some-label>`
  // Map from heading text (trimmed) -> label
  const labelsByHeading = new Map<string, string>()
  for (const m of src.matchAll(new RegExp(`^(=+)\\s+(.+?)\\s+<(${LABEL_RE.source})>\\s*$`, "gm"))) {
    labelsByHeading.set(m[2].trim(), m[3])
  }

  // Strip <prefix:label> tags from headings so they don't render as visible text.
  // The labels are already captured in labelsByHeading for id attribute injection.
  let processed = src.replace(
    new RegExp(`^(=+\\s+.+?)\\s+<${LABEL_RE.source}>\\s*$`, "gm"),
    "$1",
  )

  // For non-heading labels (fig:, tab:), replace <label> with a placeholder span
  // that we can find in the HTML output and convert to an id attribute.
  processed = processed.replace(
    new RegExp(`<((fig|tab):[a-z0-9-]+)>`, "g"),
    (_match, label) => `\`LABELANCHOR:${label}\``,
  )

  // Replace @prefix:... references with a placeholder that survives compilation.
  // Use backtick-wrapped raw text so typst passes it through verbatim.
  processed = processed.replace(
    new RegExp(`@(${LABEL_RE.source})`, "g"),
    (_match, label) => `\`XREF:${label}\``,
  )

  // Rewrite per-file #import paths for common/fns.typ — the source is copied to
  // a temp file in paper/, so relative paths like "../common/fns.typ" would escape
  // the workspace. Rewrite them to "common/fns.typ" which is correct from paper/.
  processed = processed.replace(
    /^(#import\s+")[^"]*common\/fns\.typ(".*$)/gm,
    "$1common/fns.typ$2",
  )

  // Strip #related-problems(...) and #related-layers(...) calls — the website
  // handles cross-references via its own label registry and digraph, not via
  // Typst's label/link system which requires all fragments in one compilation.
  processed = processed.replace(
    /^#related-(?:problems|layers)\(.*\)\s*$/gm,
    "",
  )

  // Write the processed source to a temp file and build a wrapper around it
  const tmpSrcPath = path.join(PAPER_DIR, `__src_${uid}.typ`)
  const wrapperPath = path.join(PAPER_DIR, `__wrapper_${uid}.typ`)
  fs.writeFileSync(tmpSrcPath, processed)
  const wrapperRelSrc = path.basename(tmpSrcPath)
  const wrapper = `#import "common/fns.typ": *\n#include "${wrapperRelSrc}"\n#bibliography("common/refs.bib")\n`
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

    // Post-process: replace LABELANCHOR placeholders with id-bearing spans.
    // The backtick placeholder becomes <code>LABELANCHOR:fig:xxx</code> in HTML.
    html = html.replace(
      new RegExp(`<code>LABELANCHOR:(${LABEL_RE.source})<\\/code>`, "g"),
      (_match, label) => `<span id="${label}"></span>`,
    )

    // Post-process: replace XREF:prefix:label placeholders with anchor links.
    // The backtick-wrapped placeholder becomes <code>XREF:prefix:label</code> in HTML.
    const DISPLAY: Record<string, string> = { sec: "\u00a7", fig: "Fig.", tab: "Tab." }
    html = html.replace(
      new RegExp(`<code>XREF:(${LABEL_RE.source})<\\/code>`, "g"),
      (_match, label) => {
        const prefix = label.split(":")[0]
        const sym = DISPLAY[prefix] ?? "\u00a7"
        const entry = labelRegistry?.get(label)
        // If the label lives on another page, link to route+anchor.
        // Otherwise fall back to a same-page anchor.
        const href = entry ? `${entry.route}#${label}` : `#${label}`
        const previewAttr = entry?.preview ? ` data-label-preview="${escapeAttr(entry.preview)}"` : ""
        const dataAttrs = entry
          ? ` data-label="${label}" data-label-title="${escapeAttr(entry.title)}" data-label-kind="${entry.kind}"${previewAttr}`
          : ` data-label="${label}"`
        return `<a href="${href}" class="${prefix}-ref xref"${dataAttrs}>${sym}</a>`
      },
    )

    return html
  } finally {
    fs.unlinkSync(wrapperPath)
    fs.unlinkSync(tmpSrcPath)
  }
}

/** Escape a string for use in an HTML attribute value. */
function escapeAttr(s: string): string {
  return s.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
}
