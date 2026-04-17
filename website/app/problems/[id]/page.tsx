import { notFound } from "next/navigation"
import Link from "next/link"
import { getSiteContent } from "../../../lib/content"
import { stripHtml } from "../../../lib/typst-parser"
import { CommentableProse } from "../../../components/commentable-prose"
import tooltips from "../../../lib/tooltips.json"

const ADVERSARY_TOOLTIPS = tooltips.adversaries as Record<string, { label: string; desc: string }>

export const dynamic = "force-static"

export async function generateStaticParams() {
  const { problems } = await getSiteContent()
  return problems.map((p) => ({ id: p.id }))
}

export default async function ProblemPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const { problems, stack } = await getSiteContent()
  const problem = problems.find((p) => p.id === id)
  if (!problem) notFound()

  const layerDetails = stack.filter((s) => problem.layers.includes(s.id))

  return (
    <div className="page">
      <div className="page-header">
        <p className="eyebrow">
          <Link href="/problems">problems</Link>
          {" / "}
          <span style={{ color: "var(--green)" }}>{problem.tag}</span>
          {" / "}
          <span style={{ color: problem.category === "enabler" ? "var(--yellow)" : "var(--pink)" }}>{problem.category}</span>
        </p>
        <h1 style={{ color: "var(--yellow)", fontSize: "1.3rem" }}>{problem.title}</h1>
        <div style={{ marginTop: "0.5rem" }}>
          {problem.layers.map((l) => (
            <Link key={l} href={`/stack/${l}`} className="tag-badge">{l}</Link>
          ))}
        </div>
        {problem.adversaries.length > 0 && (
          <div style={{ marginTop: "0.4rem" }}>
            <span style={{ color: "var(--muted)", fontSize: "0.7rem", marginRight: "0.4rem" }}>
              blocks:
            </span>
            {problem.adversaries.map((a) => (
              <Link
                key={a}
                href={`/problems?filter=${a}`}
                className="adversary-badge"
                title={ADVERSARY_TOOLTIPS[a]?.desc}
              >
                {a}
              </Link>
            ))}
          </div>
        )}
        {problem.authors.length > 0 && (
          <p style={{ color: "var(--muted)", fontSize: "0.75rem", marginTop: "0.4rem" }}>
            authors: {problem.authors.join(", ")}
          </p>
        )}
      </div>

      <CommentableProse html={problem.html} page={`/problems/${id}`} className="prose" style={{ marginBottom: "2rem" }} />

      {layerDetails.length > 0 && (
        <section>
          <p
            style={{
              color: "var(--muted)",
              fontSize: "0.75rem",
              marginBottom: "0.75rem",
            }}
          >
            // stack context
          </p>
          {layerDetails.map((layer) => (
            <div
              key={layer.id}
              style={{
                border: "1px solid var(--border)",
                background: "var(--bg-alt)",
                padding: "0.875rem 1rem",
                marginBottom: "0.5rem",
              }}
            >
              <p style={{ color: "var(--cyan)", fontSize: "0.8rem", marginBottom: "0.3rem" }}>
                [{layer.id}] {layer.label}
              </p>
              <p style={{ color: "var(--fg-alt)", fontSize: "0.82rem" }}>
                {stripHtml(layer.html).slice(0, 300)}…
              </p>
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
        <Link href="/problems">← all problems</Link>
      </div>
    </div>
  )
}
