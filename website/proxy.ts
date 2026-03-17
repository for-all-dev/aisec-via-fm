import { NextRequest, NextResponse } from "next/server"

const PUBLIC = ["/login", "/api/login", "/_next", "/favicon.ico"]

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl
  if (PUBLIC.some((p) => pathname.startsWith(p))) return NextResponse.next()

  const password = process.env.PASSWORD
  if (!password) return NextResponse.next() // no password set → open

  const session = request.cookies.get("pw-session")?.value
  if (session === password) return NextResponse.next()

  const url = request.nextUrl.clone()
  url.pathname = "/login"
  url.searchParams.set("from", pathname)
  return NextResponse.redirect(url)
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon\\.ico).*)"],
}
