import { NextRequest, NextResponse } from "next/server"

export async function GET(request: NextRequest) {
  const admin = request.cookies.get("admin-session")?.value
  return NextResponse.json({ admin: admin === process.env.ADMIN_PASSWORD })
}
