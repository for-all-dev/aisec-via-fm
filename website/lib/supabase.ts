import { createClient } from "@supabase/supabase-js"

const url = process.env.NEXT_PUBLIC_SUPABASE_URL!
const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!

/** Client-safe: respects RLS (public read, public insert) */
export const supabase = createClient(url, anonKey)

/** Server-only: bypasses RLS for resolve/delete */
export const supabaseAdmin = createClient(url, serviceKey)

export type Comment = {
  id: string
  page: string
  anchor: string
  body: string
  name: string | null
  created_at: string
  resolved: boolean
}
