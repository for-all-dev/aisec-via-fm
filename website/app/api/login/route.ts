import { NextRequest, NextResponse } from "next/server"

export async function POST(request: NextRequest) {
  const { password } = await request.json()
  const expected = process.env.PASSWORD

  if (!expected || password !== expected) {
    return NextResponse.json({ error: "wrong password" }, { status: 401 })
  }

  const from = request.nextUrl.searchParams.get("from") ?? "/"
  const response = NextResponse.redirect(new URL(from, request.url))
  response.cookies.set("pw-session", expected, {
    httpOnly: true,
    sameSite: "lax",
    path: "/",
    maxAge: 60 * 60 * 24 * 7, // 1 week
  })
  return response
}
