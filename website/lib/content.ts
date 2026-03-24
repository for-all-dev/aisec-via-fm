import { Effect } from "effect"
import fs from "fs/promises"
import path from "path"
import { parseChapterMeta, parseProblemMeta, stripHtml } from "./typst-parser"
import type { ChapterMeta, ProblemMeta } from "./typst-parser"
import { compileFragmentToHtml } from "./typst-compiler"

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

const loadStack = Effect.all(
  STACK_LAYERS.map(({ id, file, label }) =>
    readFile(path.join(PAPER_DIR, file)).pipe(
      Effect.map((raw) => {
        const meta = parseChapterMeta(id, raw)
        const html = compileFragmentToHtml(file)
        return { id, label, meta, html } satisfies StackLayer
      })
    )
  ),
)

const loadProblems = Effect.gen(function* () {
  const dir = path.join(PAPER_DIR, "problems")
  const files = yield* readDir(dir)
  const typFiles = files.filter((f) => f.endsWith(".typ") && f !== "main.typ")
  const problems = yield* Effect.all(
    typFiles.map((f) => {
      const id = f.replace(".typ", "")
      return readFile(path.join(dir, f)).pipe(
        Effect.map((raw): Problem => {
          const meta = parseProblemMeta(id, raw)
          const html = compileFragmentToHtml(`problems/${f}`)
          const preview = stripHtml(html).slice(0, 200)
          return { ...meta, html, preview }
        })
      )
    }),
  )
  return problems
})

const loadAll = Effect.gen(function* () {
  const [stack, problems] = yield* Effect.all([loadStack, loadProblems])
  return { stack, problems } satisfies SiteContent
})

export async function getSiteContent(): Promise<SiteContent> {
  return Effect.runPromise(loadAll)
}
