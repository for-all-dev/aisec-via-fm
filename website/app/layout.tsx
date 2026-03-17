import type { Metadata } from "next"
import { Geist_Mono } from "next/font/google"
import Link from "next/link"
import "./globals.css"

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
})

export const metadata: Metadata = {
  title: "Tractable Problems in AI Security via Formal Methods",
  description:
    "A position paper surveying tractable formal-methods approaches to AI security across the ML stack.",
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={geistMono.variable}>
      <body>
        <nav>
          <Link href="/" className="site-title">
            tractable.for-all.dev
          </Link>
          <Link href="/">the stack</Link>
          <Link href="/problems">problems</Link>
          <Link href="/about">about</Link>
        </nav>
        {children}
      </body>
    </html>
  )
}
