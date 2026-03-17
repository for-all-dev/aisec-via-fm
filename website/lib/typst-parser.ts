const LOREM_WORDS = (
  "lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor " +
  "incididunt ut labore et dolore magna aliqua ut enim ad minim veniam quis nostrud " +
  "exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat duis aute " +
  "irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla " +
  "pariatur excepteur sint occaecat cupidatat non proident sunt in culpa qui officia " +
  "deserunt mollit anim id est laborum sed ut perspiciatis unde omnis iste natus error " +
  "sit voluptatem accusantium doloremque laudantium totam rem aperiam eaque ipsa quae " +
  "ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo " +
  "nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit"
).split(" ")

function loremN(n: number): string {
  const words: string[] = []
  for (let i = 0; i < n; i++) {
    words.push(LOREM_WORDS[i % LOREM_WORDS.length])
  }
  const text = words.join(" ")
  return text.charAt(0).toUpperCase() + text.slice(1) + "."
}

function expandTypst(text: string): string {
  return text.replace(/#lorem\((\d+)\)/g, (_, n) => loremN(parseInt(n, 10)))
}

export interface Section {
  level: 2 | 3
  title: string
  body: string
}

export interface ParsedChapter {
  id: string
  title: string
  body: string
  sections: Section[]
}

export interface ParsedProblem {
  id: string
  tag: string
  layers: string[]
  authors: string[]
  title: string
  body: string
}

export function parseChapter(id: string, raw: string): ParsedChapter {
  const lines = raw.split("\n")
  let title = ""
  let introLines: string[] = []
  const sections: Section[] = []
  let currentSection: { level: 2 | 3; title: string; lines: string[] } | null = null

  const flush = () => {
    if (currentSection) {
      sections.push({
        level: currentSection.level,
        title: currentSection.title,
        body: expandTypst(currentSection.lines.join("\n").trim()),
      })
      currentSection = null
    }
  }

  for (const line of lines) {
    if (line.match(/^#(import|include|show)/)) continue

    const h1 = line.match(/^= (.+)$/)
    const h2 = line.match(/^== (.+)$/)
    const h3 = line.match(/^=== (.+)$/)

    if (h1) {
      title = h1[1].trim()
    } else if (h2) {
      flush()
      currentSection = { level: 2, title: h2[1].trim(), lines: [] }
    } else if (h3) {
      flush()
      currentSection = { level: 3, title: h3[1].trim(), lines: [] }
    } else {
      if (currentSection) {
        currentSection.lines.push(line)
      } else if (title) {
        introLines.push(line)
      }
    }
  }
  flush()

  return {
    id,
    title,
    body: expandTypst(introLines.join("\n").trim()),
    sections,
  }
}

export function parseProblem(id: string, raw: string): ParsedProblem {
  const lines = raw.split("\n")
  let tag = id
  let layers: string[] = []
  let authors: string[] = []
  let title = ""
  const bodyLines: string[] = []

  for (const line of lines) {
    const tagM = line.match(/^\/\/ Tag: (.+)$/)
    const layersM = line.match(/^\/\/ Layers: (.+)$/)
    const authorsM = line.match(/^\/\/ Authors: (.+)$/)
    const h2 = line.match(/^== (.+)$/)

    if (tagM) tag = tagM[1].trim()
    else if (layersM) layers = layersM[1].split(",").map((s) => s.trim())
    else if (authorsM) authors = authorsM[1].split(",").map((s) => s.trim())
    else if (h2) title = h2[1].trim()
    else if (!line.startsWith("//") && !line.startsWith("#")) {
      bodyLines.push(line)
    }
  }

  return {
    id,
    tag,
    layers,
    authors,
    title,
    body: expandTypst(bodyLines.join("\n").trim()),
  }
}
