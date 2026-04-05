"use client"

import { useState } from "react"
import Link from "next/link"
import type { Problem } from "../lib/types"
import tooltips from "../lib/tooltips.json"

const LAYER_TOOLTIPS = tooltips.layers as Record<string, { label: string; desc: string }>
export const CATEGORY_TOOLTIPS = tooltips.categories as Record<string, string>

const LAYERS = Object.keys(LAYER_TOOLTIPS)
const CATEGORIES = ["widget", "enabler"] as const

export function ProblemList({ problems }: { problems: Problem[] }) {
  const [activeLayers, setActiveLayers] = useState<Set<string>>(new Set())
  const [activeCategory, setActiveCategory] = useState<string | null>(null)

  const toggleLayer = (id: string) => {
    setActiveLayers((prev) => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

  const toggleCategory = (cat: string) => {
    setActiveCategory((prev) => (prev === cat ? null : cat))
  }

  const filtered = problems.filter((p) => {
    if (activeCategory && p.category !== activeCategory) return false
    if (activeLayers.size > 0 && !p.layers.some((l) => activeLayers.has(l))) return false
    return true
  })

  return (
    <>
      <div className="filter-bar">
        <div className="filter-group">
          <span className="filter-label">// layer</span>
          {LAYERS.map((id) => (
            <button
              key={id}
              className={`filter-chip layer ${activeLayers.has(id) ? "active" : ""}`}
              onClick={() => toggleLayer(id)}
              title={`${LAYER_TOOLTIPS[id].label}: ${LAYER_TOOLTIPS[id].desc}`}
            >
              {id}
            </button>
          ))}
        </div>
        <div className="filter-group">
          <span className="filter-label">// category</span>
          {CATEGORIES.map((cat) => (
            <button
              key={cat}
              className={`filter-chip ${cat} ${activeCategory === cat ? "active" : ""}`}
              onClick={() => toggleCategory(cat)}
              title={CATEGORY_TOOLTIPS[cat]}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      <div>
        {filtered.map((p) => (
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
              {p.preview.length > 180 ? "..." : ""}
            </p>
            <div>
              {p.layers.map((l) => (
                <span key={l} className="tag-badge" title={LAYER_TOOLTIPS[l]?.desc}>
                  {l}
                </span>
              ))}
            </div>
            <span className={`category-badge ${p.category}`}>{p.category}</span>
          </div>
        ))}
        {filtered.length === 0 && (
          <p style={{ color: "var(--muted)", fontSize: "0.82rem", padding: "1rem 0" }}>
            no problems match current filters.
          </p>
        )}
      </div>
    </>
  )
}
