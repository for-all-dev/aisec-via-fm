import Link from "next/link"
import { getSiteContent } from "../lib/content"
import type { Problem } from "../lib/content"

export const dynamic = "force-static"

function problemsForLayer(problems: Problem[], layerId: string) {
  return problems.filter((p) => p.layers.includes(layerId))
}

export default async function HomePage() {
  const { stack, problems } = await getSiteContent()

  return (
    <div className="page">
      <div className="page-header">
        <p className="eyebrow">position paper · forall r&d</p>
        <h1>Tractable Problems in AI Security via Formal Methods</h1>
        <p>
          A minimal, sane survey of formal-methods opportunities across the ML training and
          inference stack. An instruction manual for how to spend 5–25 postdoc-years.
        </p>
        <p className="mt-2">
          <a
            href="https://calendar.app.google/9Xir9aEK9ZrdttAr8"
            target="_blank"
            rel="noopener noreferrer"
            className="prompt"
            style={{ color: "var(--green)" }}
          >
            schedule a call
          </a>
        </p>
      </div>

      <section>
        <p className="text-muted text-xs mb-3">// the stack — click to expand</p>
        {stack.map(({ id, label, html }) => {
          const related = problemsForLayer(problems, id)
          return (
            <details key={id} className="stack-layer">
              <summary>
                <span style={{ color: "var(--muted)", fontSize: "0.7rem", marginRight: "0.5rem" }}>
                  [{id}]
                </span>
                {label}
              </summary>
              <div className="layer-content">
                <div className="prose" dangerouslySetInnerHTML={{ __html: html }} />
                {related.length > 0 && (
                  <div style={{ marginTop: "1rem" }}>
                    <p style={{ color: "var(--muted)", fontSize: "0.75rem", marginBottom: "0.4rem" }}>
                      // related tractable problems
                    </p>
                    <div>
                      {related.map((p) => (
                        <Link key={p.id} href={`/problems/${p.id}`} className="tag-badge">
                          {p.tag}
                        </Link>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </details>
          )
        })}
      </section>

      <section style={{ marginTop: "2.5rem" }}>
        <p className="text-muted text-xs mb-3">// tractable problems</p>
        {problems.map((p) => (
          <div key={p.id} className="problem-card">
            <h2>
              <Link href={`/problems/${p.id}`}>{p.title}</Link>
            </h2>
            <div>
              {p.layers.map((l) => (
                <span key={l} className="tag-badge">{l}</span>
              ))}
            </div>
          </div>
        ))}
      </section>

      <footer
        style={{
          marginTop: "3rem",
          paddingTop: "1rem",
          borderTop: "1px solid var(--border)",
          color: "var(--muted)",
          fontSize: "0.75rem",
        }}
      >
        <p>
          <Link href="/about">authors</Link>
          {" · "}
          <a
            href="https://calendar.app.google/9Xir9aEK9ZrdttAr8"
            target="_blank"
            rel="noopener noreferrer"
          >
            calendly
          </a>
          {" · "}
          <Link href="/problems">problems</Link>
        </p>
      </footer>
    </div>
  )
}
