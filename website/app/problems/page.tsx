import Link from "next/link"
import { getSiteContent } from "../../lib/content"

export const dynamic = "force-static"

const LAYER_LABELS: Record<string, string> = {
  "execution-harness": "Execution Harness",
  "software-framework": "Software & ML Framework",
  "orchestration-cloud": "Orchestration & Cloud",
  "firmware-lowlevel": "Firmware & Low-Level",
  "hardware-supply-chain": "Hardware & Supply Chain",
}

export default async function ProblemsPage() {
  const { problems } = await getSiteContent()

  return (
    <div className="page">
      <div className="page-header">
        <p className="eyebrow">tractable problems</p>
        <h1>Shovel-Ready Project Specs</h1>
      </div>

      <div>
        {problems.map((p) => (
          <div key={p.id} className="problem-card">
            <h2>
              <Link href={`/problems/${p.id}`}>{p.title}</Link>
            </h2>
            <p
              style={{
                color: "var(--fg-alt)",
                fontSize: "0.82rem",
                margin: "0.4rem 0 0.5rem",
                maxWidth: "64ch",
              }}
            >
              {p.preview.slice(0, 180)}
              {p.preview.length > 180 ? "…" : ""}
            </p>
            <div>
              {p.layers.map((l) => (
                <span key={l} className="tag-badge" title={LAYER_LABELS[l]}>
                  {l}
                </span>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
