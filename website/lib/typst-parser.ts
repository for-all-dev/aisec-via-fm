/** Extract metadata from typst chapter source (title + invites — body is compiled via typst). */
export interface ChapterMeta {
  id: string
  title: string
  invites: string[]
}

export function parseChapterMeta(id: string, raw: string): ChapterMeta {
  const h1 = raw.match(/^= (.+)$/m)
  const invitesM = raw.match(/^\/\/ Invites: (.+)$/m)
  return {
    id,
    title: h1 ? h1[1].replace(/<(?:sec|fig|tab):[a-z0-9-]+>\s*$/, "").trim() : id,
    invites: invitesM ? invitesM[1].split(",").map((s) => s.trim()) : [],
  }
}

/** Extract metadata from typst problem source (comments + title — body is compiled via typst). */
export interface ProblemMeta {
  id: string
  tag: string
  layers: string[]
  adversaries: string[]
  category: "enabler" | "widget"
  authors: string[]
  title: string
}

export function parseProblemMeta(id: string, raw: string): ProblemMeta {
  let tag = id
  let layers: string[] = []
  let adversaries: string[] = []
  let category: "enabler" | "widget" = "widget"
  let authors: string[] = []
  let title = ""

  for (const line of raw.split("\n")) {
    const tagM = line.match(/^\/\/ Tag: (.+)$/)
    const layersM = line.match(/^\/\/ Layers: (.+)$/)
    const adversariesM = line.match(/^\/\/ Adversaries: (.+)$/)
    const categoryM = line.match(/^\/\/ Category: (.+)$/)
    const authorsM = line.match(/^\/\/ Authors: (.+)$/)
    const h2 = line.match(/^== (.+)$/)

    if (tagM) tag = tagM[1].trim()
    else if (layersM) layers = layersM[1].split(",").map((s) => s.trim())
    else if (adversariesM) adversaries = adversariesM[1].split(",").map((s) => s.trim())
    else if (categoryM) category = categoryM[1].trim() as "enabler" | "widget"
    else if (authorsM) authors = authorsM[1].split(",").map((s) => s.trim())
    else if (h2 && !title) title = h2[1].replace(/<(?:sec|fig|tab):[a-z0-9-]+>\s*$/, "").trim()
  }

  return { id, tag, layers, adversaries, category, authors, title }
}

/** Strip HTML tags for plain-text previews. */
export function stripHtml(html: string): string {
  return html.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim()
}
