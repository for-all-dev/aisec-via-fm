#!/usr/bin/env bun
/**
 * Re-insert the 4 comments salvaged from Chromium's HTTP cache
 * (see scripts/recovered-comments.json, gitignored) into the
 * self-hosted Postgres after migrating off Supabase.
 *
 * Preserves original ids and created_at timestamps so URLs / anchors
 * referencing these comments remain stable.
 *
 *   DATABASE_URL=postgres://... bun run scripts/seed-recovered-comments.ts
 */
import postgres from "postgres"
import { readFileSync } from "node:fs"
import { fileURLToPath } from "node:url"
import { dirname, join } from "node:path"

const DATABASE_URL = process.env.DATABASE_URL
if (!DATABASE_URL) {
  console.error("DATABASE_URL is not set")
  process.exit(1)
}

type Comment = {
  id: string
  page: string
  anchor: string
  body: string
  name: string | null
  created_at: string
  resolved: boolean
}

const here = dirname(fileURLToPath(import.meta.url))
const path = join(here, "recovered-comments.json")
const comments: Comment[] = JSON.parse(readFileSync(path, "utf8"))

const sql = postgres(DATABASE_URL, { ssl: "require" })

let inserted = 0
let skipped = 0
for (const c of comments) {
  const result = await sql`
    insert into comments (id, page, anchor, body, name, created_at, resolved)
    values (${c.id}, ${c.page}, ${c.anchor}, ${c.body}, ${c.name}, ${c.created_at}, ${c.resolved})
    on conflict (id) do nothing
    returning id
  `
  if (result.length > 0) {
    inserted++
    console.log(`  + ${c.created_at}  ${c.name ?? "anon"}  ${c.page}#${c.anchor}`)
  } else {
    skipped++
    console.log(`  = ${c.id}  (already present, skipped)`)
  }
}

console.log(`\ninserted: ${inserted} / skipped: ${skipped} / total in file: ${comments.length}`)
await sql.end()
