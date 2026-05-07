import { NextRequest, NextResponse } from "next/server"
import { sql, type Comment } from "../../../lib/db"

export async function GET(request: NextRequest) {
  const page = request.nextUrl.searchParams.get("page")
  const anchor = request.nextUrl.searchParams.get("anchor")
  const admin =
    request.cookies.get("admin-session")?.value === process.env.ADMIN_PASSWORD

  const rows = await sql<Comment[]>`
    select id, page, anchor, body, name, created_at, resolved
    from comments
    where ${admin ? sql`true` : sql`resolved = false`}
      and ${page ? sql`page = ${page}` : sql`true`}
      and ${anchor ? sql`anchor = ${anchor}` : sql`true`}
    order by created_at asc
  `

  return NextResponse.json(rows)
}

export async function POST(request: NextRequest) {
  const { page, anchor, body, name } = await request.json()

  if (!page || !anchor || !body) {
    return NextResponse.json(
      { error: "page, anchor, and body are required" },
      { status: 400 },
    )
  }

  const [row] = await sql<{ id: string }[]>`
    insert into comments (page, anchor, body, name)
    values (${page}, ${anchor}, ${body}, ${name || null})
    returning id
  `

  return NextResponse.json({ id: row.id }, { status: 201 })
}
