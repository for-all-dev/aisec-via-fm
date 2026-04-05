"use client"

import { useRef, useEffect, useState } from "react"
import { CommentThread } from "./comment-thread"

/**
 * Wraps a prose block rendered via dangerouslySetInnerHTML and injects
 * CommentThread components after each heading that has an id attribute.
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
  const ref = useRef<HTMLDivElement>(null)
  const [anchors, setAnchors] = useState<string[]>([])

  useEffect(() => {
    if (!ref.current) return
    const headings = ref.current.querySelectorAll("h1[id], h2[id], h3[id], h4[id]")
    const ids: string[] = []
    headings.forEach((heading) => {
      const id = heading.getAttribute("id")
      if (id) ids.push(id.replace(/^sec:/, ""))
    })
    setAnchors(ids)
  }, [html])

  return (
    <>
      <div
        ref={ref}
        className={className}
        style={style}
        dangerouslySetInnerHTML={{ __html: html }}
      />
      {anchors.map((anchor) => (
        <CommentThread key={anchor} page={page} anchor={anchor} />
      ))}
    </>
  )
}
