import postgres from "postgres"

let client: ReturnType<typeof postgres> | undefined

export function getSql() {
  if (!client) {
    const url = process.env.DATABASE_URL
    if (!url) throw new Error("DATABASE_URL is not set")
    client = postgres(url, {
      ssl: "require",
      max: 5,
      idle_timeout: 20,
      connect_timeout: 10,
    })
  }
  return client
}

export type Comment = {
  id: string
  page: string
  anchor: string
  body: string
  name: string | null
  created_at: string
  resolved: boolean
}
