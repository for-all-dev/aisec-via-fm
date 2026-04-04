import { Effect } from "effect"
import fs from "fs/promises"
import fsSync from "fs"
import path from "path"
import { parseChapterMeta, parseProblemMeta, stripHtml } from "./typst-parser"
import type { ChapterMeta, ProblemMeta } from "./typst-parser"
import { compileFragmentToHtml, compileSnippetToHtml, extractLabels } from "./typst-compiler"
import type { LabelEntry } from "./typst-compiler"

const PAPER_DIR = path.join(process.cwd(), "..", "paper")

const STACK_LAYERS = [
  { id: "execution-harness", file: "stack/execution-harness.typ", label: "Execution Harness" },
  { id: "software-framework", file: "stack/software-framework.typ", label: "Software & ML Framework" },
  { id: "orchestration-cloud", file: "stack/orchestration-cloud.typ", label: "Orchestration & Cloud" },
  { id: "firmware-lowlevel", file: "stack/firmware-lowlevel.typ", label: "Firmware & Low-Level Systems" },
  { id: "hardware-supply-chain", file: "stack/hardware-supply-chain.typ", label: "Hardware & Physical Supply Chain" },
] as const

export type LayerId = (typeof STACK_LAYERS)[number]["id"]

export interface StackLayer {
  id: LayerId
  label: string
  meta: ChapterMeta
  html: string
}

export interface Problem {
  id: string
  tag: string
  layers: string[]
  authors: string[]
  title: string
  html: string
  preview: string
}

export interface SiteContent {
  stack: StackLayer[]
  problems: Problem[]
  abstractHtml: string
  labelRegistry: Record<string, LabelEntry>
}

const readFile = (filePath: string) =>
  Effect.tryPromise({
    try: () => fs.readFile(filePath, "utf8"),
    catch: (e) => new Error(`Failed to read ${filePath}: ${e}`),
  })

const readDir = (dirPath: string) =>
  Effect.tryPromise({
    try: () => fs.readdir(dirPath),
    catch: (e) => new Error(`Failed to read dir ${dirPath}: ${e}`),
  })

/**
 * Recursively collect all .typ file paths under a directory.
 */
function walkTypFiles(dir: string): string[] {
  const results: string[] = []
  for (const entry of fsSync.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) {
      results.push(...walkTypFiles(full))
    } else if (entry.isFile() && entry.name.endsWith(".typ")) {
      results.push(full)
    }
  }
  return results
}

/**
 * Derive the website route for a .typ file given its absolute path.
 *
 * Rules (first match wins):
 *  - paper/stack/*.typ           → /stack
 *  - paper/problems/<id>.typ     → /problems/<id>  (main.typ → /problems)
 *  - paper/common/*.typ          → null (utility/macro files, no content route)
 *  - paper/<dir>/main.typ        → /<dir>
 *  - paper/<dir>/<file>.typ      → /<dir>/<file>
 *  - paper/main.typ              → /
 */
function routeForTypFile(absolutePath: string): string | null {
  const rel = path.relative(PAPER_DIR, absolutePath) // e.g. "stack/execution-harness.typ"
  const parts = rel.split(path.sep) // ["stack", "execution-harness.typ"]

  if (parts[0] === "common") return null
  if (parts[0] === "stack") return "/stack"
  if (parts[0] === "problems") {
    if (parts.length === 2) {
      const id = parts[1].replace(".typ", "")
      return id === "main" ? "/problems" : `/problems/${id}`
    }
    return "/problems"
  }
  if (parts.length === 1) return "/" // paper/main.typ

  // e.g. paper/executive/main.typ → /executive
  const dir = parts[0]
  const file = parts[parts.length - 1].replace(".typ", "")
  return file === "main" ? `/${dir}` : `/${dir}/${file}`
}

/**
 * Build a label registry by recursively scanning all .typ source files under
 * the paper directory. Maps each label to the website route where it lives +
 * its title. This runs synchronously at build time before any compilation.
 */
function buildLabelRegistry(): Map<string, LabelEntry> {
  const registry = new Map<string, LabelEntry>()

  for (const absolutePath of walkTypFiles(PAPER_DIR)) {
    const route = routeForTypFile(absolutePath)
    if (route === null) continue

    const src = fsSync.readFileSync(absolutePath, "utf-8")
    for (const entry of extractLabels(src)) {
      registry.set(entry.label, { ...entry, route })
    }
  }

  return registry
}

const loadAll = Effect.gen(function* () {
  // Build label registry first (synchronous scan of all .typ files)
  const registryMap = buildLabelRegistry()

  // Load stack layers with cross-page ref resolution
  const stack = yield* Effect.all(
    STACK_LAYERS.map(({ id, file, label }) =>
      readFile(path.join(PAPER_DIR, file)).pipe(
        Effect.map((raw) => {
          const meta = parseChapterMeta(id, raw)
          const html = compileFragmentToHtml(file, registryMap)
          return { id, label, meta, html } satisfies StackLayer
        })
      )
    ),
  )

  // Load problems with cross-page ref resolution
  const dir = path.join(PAPER_DIR, "problems")
  const files = yield* readDir(dir)
  const typFiles = files.filter((f: string) => f.endsWith(".typ") && f !== "main.typ")
  const problems = yield* Effect.all(
    typFiles.map((f: string) => {
      const id = f.replace(".typ", "")
      return readFile(path.join(dir, f)).pipe(
        Effect.map((raw): Problem => {
          const meta = parseProblemMeta(id, raw)
          const html = compileFragmentToHtml(`problems/${f}`, registryMap)
          const preview = stripHtml(html).slice(0, 200)
          return { ...meta, html, preview }
        })
      )
    }),
  )

  const abstractHtml = compileSnippetToHtml(
    `#import "common/fns.typ": paper_abstract\n#paper_abstract`,
  )

  // Convert registry map to plain object for JSON serialization
  const labelRegistry = Object.fromEntries(registryMap)

  return { stack, problems, abstractHtml, labelRegistry } satisfies SiteContent
})

export async function getSiteContent(): Promise<SiteContent> {
  return Effect.runPromise(loadAll)
}
