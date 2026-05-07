import { NextRequest, NextResponse } from "next/server"
import { sql } from "../../../../lib/db"

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  const admin = request.cookies.get("admin-session")?.value
  if (!admin || admin !== process.env.ADMIN_PASSWORD) {
    return NextResponse.json({ error: "admin required" }, { status: 403 })
  }

  const { id } = await params

  await sql`delete from comments where id = ${id}`

  return new NextResponse(null, { status: 204 })
}
