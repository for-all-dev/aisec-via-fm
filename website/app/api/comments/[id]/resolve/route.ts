import { NextRequest, NextResponse } from "next/server"
import { supabaseAdmin } from "../../../../../lib/supabase"

export async function POST(
  _request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  const admin = _request.cookies.get("admin-session")?.value
  if (!admin || admin !== process.env.ADMIN_PASSWORD) {
    return NextResponse.json({ error: "admin required" }, { status: 403 })
  }

  const { id } = await params

  const { error } = await supabaseAdmin
    .from("comments")
    .update({ resolved: true })
    .eq("id", id)

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({ ok: true })
}
