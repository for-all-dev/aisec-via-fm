"use client"

import { useMemo } from "react"
import { CommentThread } from "./comment-thread"

/**
 * Split HTML at heading boundaries (h1-h4 with id attributes) and
 * interleave CommentThread components after each section's content.
 */
export function CommentableProse({
  html,
  page,
  className,
  style,
}: {
  html: string
  page: string
  className?: string
  style?: React.CSSProperties
}) {
  const sections = useMemo(() => {
    // Split HTML at <hN id="..."> boundaries
    const re = /<h([1-4])\s[^>]*id="([^"]+)"[^>]*>/g
    const parts: { html: string; anchor: string | null }[] = []
    let lastIndex = 0
    let match

    while ((match = re.exec(html)) !== null) {
      // Content before this heading
      if (match.index > lastIndex) {
        const prev = parts[parts.length - 1]
        if (prev) {
          prev.html += html.slice(lastIndex, match.index)
        } else {
          parts.push({ html: html.slice(lastIndex, match.index), anchor: null })
        }
      }
      const anchor = match[2].replace(/^sec:/, "")
      parts.push({ html: "", anchor })
      lastIndex = match.index
    }

    // Remaining content after last heading
    if (lastIndex < html.length) {
      const prev = parts[parts.length - 1]
      if (prev) {
        prev.html += html.slice(lastIndex)
      } else {
        parts.push({ html: html.slice(lastIndex), anchor: null })
      }
    }

    // If no headings found, return the whole thing
    if (parts.length === 0) {
      parts.push({ html, anchor: null })
    }

    return parts
  }, [html])

  return (
    <div className={className} style={style}>
      {sections.map((section, i) => (
        <div key={section.anchor ?? i}>
          <div dangerouslySetInnerHTML={{ __html: section.html }} />
          {section.anchor && (
            <CommentThread page={page} anchor={section.anchor} />
          )}
        </div>
      ))}
    </div>
  )
}
