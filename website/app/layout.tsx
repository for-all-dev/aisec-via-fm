import type { Metadata } from "next"
import { Geist_Mono } from "next/font/google"
import Link from "next/link"
import { XrefTooltips } from "../components/xref-tooltips"
import { HideCommentsToggle } from "../components/hide-comments-toggle"
import "katex/dist/katex.min.css"
import "./globals.css"

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
})

export const metadata: Metadata = {
  title: "Tractable Problems in AI Security via Formal Methods",
  description:
    "The minimal, sane catalog of formal-methods opportunities across the ML training and inference stack.",
}

const GH_REPO = "https://github.com/for-all-dev/aisec-via-fm"
const commit = process.env.NEXT_PUBLIC_GIT_COMMIT ?? "dev"
const buildDate = process.env.NEXT_PUBLIC_BUILD_DATE ?? ""

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={geistMono.variable} suppressHydrationWarning>
      <body suppressHydrationWarning>
        <nav>
          <Link href="/" className="site-title">
            tractable.for-all.dev
          </Link>
          <Link href="/executive">executive summary</Link>
          <Link href="/stack">the stack</Link>
          <Link href="/problems">problems</Link>
          <Link href="/about">about</Link>
          <Link href="/admin">admin</Link>
          <HideCommentsToggle />
          <a
            href={`${GH_REPO}/commit/${commit}`}
            className="commit-hash"
            style={{ marginLeft: "auto" }}
          >
            {commit}
          </a>
        </nav>
        {children}
        <XrefTooltips />
        <footer>
          built {buildDate} ·{" "}
          <a href={GH_REPO}>for-all-dev/aisec-via-fm</a>
        </footer>
      </body>
    </html>
  )
}
