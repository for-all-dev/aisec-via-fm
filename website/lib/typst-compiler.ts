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
 */
export function compileFragmentToHtml(relPath: string): string {
  const uid = Math.random().toString(36).slice(2, 10)
  const wrapperPath = path.join(PAPER_DIR, `__wrapper_${uid}.typ`)
  const wrapper = `#import "common/fns.typ": *\n#include "${relPath}"\n#bibliography("refs.bib")\n`
  fs.writeFileSync(wrapperPath, wrapper)
  try {
    const c = getCompiler()
    const bytes = c.html({ mainFilePath: wrapperPath })
    if (!bytes) throw new Error(`typst compilation returned null for ${relPath}`)
    const html = Buffer.from(bytes).toString("utf-8")
    // Extract just the <body> content
    const bodyMatch = html.match(/<body>([\s\S]*)<\/body>/)
    return bodyMatch ? bodyMatch[1].trim() : html
  } finally {
    fs.unlinkSync(wrapperPath)
  }
}
