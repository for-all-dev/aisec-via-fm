import { notFound } from "next/navigation"
import Link from "next/link"
import { getSiteContent } from "../../../lib/content"
import { CommentableProse } from "../../../components/commentable-prose"

export const dynamic = "force-static"

export async function generateStaticParams() {
  const { stack } = await getSiteContent()
  return stack.map((s) => ({ slug: s.id }))
}

export default async function StackLayerPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params
  const { stack, problems } = await getSiteContent()
  const layer = stack.find((s) => s.id === slug)
  if (!layer) notFound()

  const related = problems.filter((p) => p.layers.includes(layer.id))

  return (
    <div className="page">
      <div className="page-header">
        <p className="eyebrow">
          <Link href="/stack">the stack</Link>
          {" / "}
          <span style={{ color: "var(--cyan)" }}>{layer.id}</span>
        </p>
        <h1 style={{ color: "var(--yellow)", fontSize: "1.3rem" }}>{layer.label}</h1>
      </div>

      <CommentableProse html={layer.html} page={`/stack/${slug}`} className="prose" style={{ marginBottom: "2rem" }} />

      {related.length > 0 && (
        <section>
          <p
            style={{
              color: "var(--muted)",
              fontSize: "0.75rem",
              marginBottom: "0.75rem",
            }}
          >
            // related tractable problems
          </p>
          {related.map((p) => (
            <div
              key={p.id}
              style={{
                border: "1px solid var(--border)",
                background: "var(--bg-alt)",
                padding: "0.875rem 1rem",
                marginBottom: "0.5rem",
              }}
            >
              <Link href={`/problems/${p.id}`} style={{ textDecoration: "none" }}>
                <p style={{ color: "var(--green)", fontSize: "0.8rem", marginBottom: "0.3rem" }}>
                  {p.tag}
                </p>
                <p style={{ color: "var(--fg-alt)", fontSize: "0.82rem" }}>
                  {p.preview}
                </p>
              </Link>
            </div>
          ))}
        </section>
      )}

      <div
        style={{
          marginTop: "2rem",
          paddingTop: "1rem",
          borderTop: "1px solid var(--border)",
          fontSize: "0.75rem",
          color: "var(--muted)",
        }}
      >
        <Link href="/stack">← all layers</Link>
      </div>
    </div>
  )
}
