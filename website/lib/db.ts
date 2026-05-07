import postgres from "postgres"

const connectionString = process.env.DATABASE_URL

if (!connectionString) {
  throw new Error("DATABASE_URL is not set")
}

export const sql = postgres(connectionString, {
  ssl: "require",
  max: 5,
  idle_timeout: 20,
  connect_timeout: 10,
})

export type Comment = {
  id: string
  page: string
  anchor: string
  body: string
  name: string | null
  created_at: string
  resolved: boolean
}
