import { NextRequest, NextResponse } from "next/server"
import { supabaseAdmin } from "../../../../lib/supabase"

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  const admin = request.cookies.get("admin-session")?.value
  if (!admin || admin !== process.env.ADMIN_PASSWORD) {
    return NextResponse.json({ error: "admin required" }, { status: 403 })
  }

  const { id } = await params

  const { error } = await supabaseAdmin
    .from("comments")
    .delete()
    .eq("id", id)

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return new NextResponse(null, { status: 204 })
}
