import { NextRequest, NextResponse } from "next/server"
import { getSql } from "../../../../../lib/db"

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  const admin = request.cookies.get("admin-session")?.value
  if (!admin || admin !== process.env.ADMIN_PASSWORD) {
    return NextResponse.json({ error: "admin required" }, { status: 403 })
  }

  const { id } = await params

  const sql = getSql()
  await sql`update comments set resolved = true where id = ${id}`

  return NextResponse.json({ ok: true })
}
