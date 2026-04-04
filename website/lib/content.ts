import { Effect } from "effect"
import fs from "fs/promises"
import fsSync from "fs"
import path from "path"
import { parseChapterMeta, parseProblemMeta, stripHtml } from "./typst-parser"
import type { ChapterMeta, ProblemMeta } from "./typst-parser"
import { compileFragmentToHtml, compileSnippetToHtml, extractLabels } from "./typst-compiler"
import type { LabelEntry } from "./typst-compiler"

const PAPER_DIR = path.join(process.cwd(), "..", "paper")

const PAPER_STACK_DIR = "stack"
const PAPER_PROBLEMS_DIR = "problems"
const PAPER_COMMON_DIR = "common"

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

export type { Problem } from "./types"
import type { Problem } from "./types"

/** Machine-readable layer-problem mapping, built from problem file headers. */
export interface Digraph {
  layers: Record<string, { label: string; sec: string }>
  problems: Record<string, { label: string; sec: string; layers: string[]; category: string }>
}

export interface SiteContent {
  stack: StackLayer[]
  problems: Problem[]
  abstractHtml: string
  labelRegistry: Record<string, LabelEntry>
  digraph: Digraph
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
 */
function routeForTypFile(absolutePath: string): string | null {
  const rel = path.relative(PAPER_DIR, absolutePath)
  const parts = rel.split(path.sep)

  if (parts[0] === PAPER_COMMON_DIR) return null
  if (parts[0] === PAPER_STACK_DIR) return "/stack"
  if (parts[0] === PAPER_PROBLEMS_DIR) {
    if (parts.length === 2) {
      const id = parts[1].replace(".typ", "")
      return id === "main" ? "/problems" : `/problems/${id}`
    }
    return "/problems"
  }
  if (parts.length === 1) return "/"

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

/** Build digraph from problem file comment headers and the STACK_LAYERS constant. */
function loadDigraph(): Digraph {
  const layers: Digraph["layers"] = {}
  for (const { id, label } of STACK_LAYERS) {
    layers[id] = { label, sec: `sec:${id}` }
  }

  const problems: Digraph["problems"] = {}
  const problemDir = path.join(PAPER_DIR, "problems")
  const files = fsSync.readdirSync(problemDir).filter((f) => f.endsWith(".typ") && f !== "main.typ")
  for (const f of files) {
    const src = fsSync.readFileSync(path.join(problemDir, f), "utf-8")
    const tagMatch = src.match(/^\/\/ Tag: (.+)$/m)
    const layersMatch = src.match(/^\/\/ Layers: (.+)$/m)
    const categoryMatch = src.match(/^\/\/ Category: (.+)$/m)
    const headingMatch = src.match(/^==\s+(.+?)\s+<(sec:[a-z0-9-]+)>/m)
    if (tagMatch && layersMatch && headingMatch) {
      const tag = tagMatch[1].trim()
      const fileLayers = layersMatch[1].split(",").map((s) => s.trim())
      const category = categoryMatch?.[1].trim() ?? "widget"
      problems[tag] = {
        label: headingMatch[1].trim(),
        sec: headingMatch[2],
        layers: fileLayers,
        category,
      }
    }
  }

  return { layers, problems }
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
  const digraph = loadDigraph()

  return { stack, problems, abstractHtml, labelRegistry, digraph } satisfies SiteContent
})

export async function getSiteContent(): Promise<SiteContent> {
  return Effect.runPromise(loadAll)
}
