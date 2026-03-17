import { Effect } from "effect"
import fs from "fs/promises"
import path from "path"
import { parseChapter, parseProblem, ParsedChapter, ParsedProblem } from "./typst-parser"

const PAPER_DIR = path.join(process.cwd(), "..", "paper")

const STACK_LAYERS = [
  { id: "execution-harness", file: "chapters/stack/execution-harness.typ", label: "Execution Harness" },
  { id: "software-framework", file: "chapters/stack/software-framework.typ", label: "Software & ML Framework" },
  { id: "orchestration-cloud", file: "chapters/stack/orchestration-cloud.typ", label: "Orchestration & Cloud" },
  { id: "firmware-lowlevel", file: "chapters/stack/firmware-lowlevel.typ", label: "Firmware & Low-Level Systems" },
  { id: "hardware-supply-chain", file: "chapters/stack/hardware-supply-chain.typ", label: "Hardware & Physical Supply Chain" },
] as const

export type LayerId = (typeof STACK_LAYERS)[number]["id"]

export interface StackLayer {
  id: LayerId
  label: string
  chapter: ParsedChapter
}

export interface SiteContent {
  stack: StackLayer[]
  problems: ParsedProblem[]
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
      Effect.map((raw) => ({ id, label, chapter: parseChapter(id, raw) }) satisfies StackLayer)
    )
  ),
  { concurrency: "unbounded" }
)

const loadProblems = Effect.gen(function* () {
  const dir = path.join(PAPER_DIR, "problems")
  const files = yield* readDir(dir)
  const typFiles = files.filter((f) => f.endsWith(".typ") && f !== "authors.typ")
  const problems = yield* Effect.all(
    typFiles.map((f) => {
      const id = f.replace(".typ", "")
      return readFile(path.join(dir, f)).pipe(
        Effect.map((raw) => parseProblem(id, raw))
      )
    }),
    { concurrency: "unbounded" }
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
