import { NextRequest, NextResponse } from "next/server"
import { supabase } from "../../../lib/supabase"

export async function GET(request: NextRequest) {
  const page = request.nextUrl.searchParams.get("page")
  const anchor = request.nextUrl.searchParams.get("anchor")

  let query = supabase
    .from("comments")
    .select("*")
    .order("created_at", { ascending: true })

  if (page) query = query.eq("page", page)
  if (anchor) query = query.eq("anchor", anchor)

  const { data, error } = await query

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json(data)
}

export async function POST(request: NextRequest) {
  const pw = request.cookies.get("pw-session")?.value
  if (!pw || pw !== process.env.PASSWORD) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 })
  }

  const { page, anchor, body, name } = await request.json()

  if (!page || !anchor || !body) {
    return NextResponse.json({ error: "page, anchor, and body are required" }, { status: 400 })
  }

  const { data, error } = await supabase
    .from("comments")
    .insert({ page, anchor, body, name: name || null })
    .select("id")
    .single()

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({ id: data.id }, { status: 201 })
}
