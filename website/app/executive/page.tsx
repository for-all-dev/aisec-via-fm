import Link from "next/link"
import { getSiteContent } from "../../lib/content"
import { CommentableProse } from "../../components/commentable-prose"

export const dynamic = "force-static"

export default async function ExecutivePage() {
  const { executiveHtml, stack, problems } = await getSiteContent()

  return (
    <div className="page">
      <div className="page-header">
        <p className="eyebrow">executive summary</p>
        <h1>Tractable Problems in AI Security via Formal Methods</h1>
      </div>

      <CommentableProse html={executiveHtml} page="/executive" className="prose" />

      <section style={{ marginTop: "2.5rem" }}>
        <p className="text-muted text-xs mb-3">// navigate the site</p>
        <div style={{ display: "grid", gap: "0.5rem" }}>
          <div
            style={{
              border: "1px solid var(--border)",
              background: "var(--bg-alt)",
              padding: "0.875rem 1rem",
            }}
          >
            <Link href="/stack" style={{ color: "var(--cyan)", fontSize: "0.85rem" }}>
              the stack →
            </Link>
            <p style={{ color: "var(--fg-alt)", fontSize: "0.8rem", marginTop: "0.3rem" }}>
              {stack.length}{" "}layers of the ML training &amp; inference stack, each with status quo and attack surface.
            </p>
          </div>
          <div
            style={{
              border: "1px solid var(--border)",
              background: "var(--bg-alt)",
              padding: "0.875rem 1rem",
            }}
          >
            <Link href="/problems" style={{ color: "var(--green)", fontSize: "0.85rem" }}>
              tractable problems →
            </Link>
            <p style={{ color: "var(--fg-alt)", fontSize: "0.8rem", marginTop: "0.3rem" }}>
              {problems.length}{" "}shovel-ready project specs tagged by stack layer and category (enabler / widget).
            </p>
          </div>
          <div
            style={{
              border: "1px solid var(--border)",
              background: "var(--bg-alt)",
              padding: "0.875rem 1rem",
            }}
          >
            <Link href="/about" style={{ color: "var(--yellow)", fontSize: "0.85rem" }}>
              about &amp; authors →
            </Link>
            <p style={{ color: "var(--fg-alt)", fontSize: "0.8rem", marginTop: "0.3rem" }}>
              Partial authorship system, contribution info, and contact.
            </p>
          </div>
        </div>
      </section>
    </div>
  )
}
