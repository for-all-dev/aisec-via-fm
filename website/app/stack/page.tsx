import Link from "next/link"
import { getSiteContent } from "../../lib/content"
import type { Problem } from "../../lib/content"

export const dynamic = "force-static"

function problemsForLayer(problems: Problem[], layerId: string) {
  return problems.filter((p) => p.layers.includes(layerId))
}

export default async function StackPage() {
  const { stack, problems } = await getSiteContent()

  return (
    <div className="page">
      <div className="page-header">
        <p className="eyebrow">the stack</p>
        <h1>ML Training & Inference Stack</h1>
      </div>

      <section>
        <p className="text-muted text-xs mb-3">// click to expand</p>
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
    </div>
  )
}
