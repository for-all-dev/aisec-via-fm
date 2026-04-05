"use client"

import { useRef, useEffect, useState } from "react"
import { createPortal } from "react-dom"
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
  const [anchors, setAnchors] = useState<{ id: string; container: HTMLDivElement }[]>([])

  useEffect(() => {
    if (!ref.current) return
    const headings = ref.current.querySelectorAll("h1[id], h2[id], h3[id], h4[id]")
    const result: { id: string; container: HTMLDivElement }[] = []

    headings.forEach((heading) => {
      const id = heading.getAttribute("id")
      if (!id) return
      // Slugify the id to get a clean anchor
      const anchor = id.replace(/^sec:/, "")
      const container = document.createElement("div")
      heading.after(container)
      result.push({ id: anchor, container })
    })

    setAnchors(result)

    return () => {
      result.forEach(({ container }) => container.remove())
    }
  }, [html])

  return (
    <>
      <div
        ref={ref}
        className={className}
        style={style}
        dangerouslySetInnerHTML={{ __html: html }}
      />
      {anchors.map(({ id, container }) =>
        createPortal(
          <CommentThread key={id} page={page} anchor={id} />,
          container,
        ),
      )}
    </>
  )
}
