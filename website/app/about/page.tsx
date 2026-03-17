import { getSiteContent } from "../../lib/content"

export const dynamic = "force-static"

const AUTHORS = [
  {
    name: "Quinn Dougherty",
    role: "Principal",
    org: "Forall R&D",
    location: "Washington DC",
    email: "quinn@for-all.dev",
  },
  {
    name: "Max von Hippel",
    role: "Job Title",
    org: "Anduril",
    location: "Boulder",
    email: "maxvh@hey.com",
  },
]

export default async function AboutPage() {
  const { problems } = await getSiteContent()

  return (
    <div className="page">
      <div className="page-header">
        <p className="eyebrow">authorship</p>
        <h1>Authors</h1>
        <p>Partial authorship is tracked per-problem via tags in the source files.</p>
      </div>

      <section style={{ marginBottom: "2rem" }}>
        {AUTHORS.map((a) => {
          const contributed = problems.filter(
            (p) => p.authors.length === 0 || p.authors.some((n) => n === a.name)
          )
          return (
            <div key={a.name} className="author-card">
              <p className="name">{a.name}</p>
              <p className="meta">
                {a.role} · {a.org} · {a.location}
              </p>
              <p>
                <a href={`mailto:${a.email}`}>{a.email}</a>
              </p>
              {contributed.length > 0 && (
                <div style={{ marginTop: "0.75rem" }}>
                  <p
                    style={{
                      color: "var(--muted)",
                      fontSize: "0.75rem",
                      marginBottom: "0.25rem",
                    }}
                  >
                    // contributions
                  </p>
                  <div>
                    {contributed.map((p) => (
                      <a key={p.id} href={`/problems/${p.id}`} className="tag-badge">
                        {p.tag}
                      </a>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )
        })}
      </section>

      <section>
        <p className="text-muted text-xs mb-3">
          // to claim partial authorship, add{" "}
          <code style={{ fontSize: "0.75rem" }}>// Authors: Your Name</code> to the relevant{" "}
          <code style={{ fontSize: "0.75rem" }}>paper/problems/*.typ</code> file
        </p>
      </section>
    </div>
  )
}
