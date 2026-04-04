"use client"

import { useEffect } from "react"

/**
 * Attaches hover-preview tooltips to cross-reference links.
 * Links are identified by the `data-label` attribute set during
 * typst HTML post-processing. The tooltip shows the section title
 * (for sec: refs) or caption (for fig:/tab: refs).
 *
 * Mounts a single event-delegated listener on the document body
 * rather than per-link listeners.
 */
export function XrefTooltips() {
  useEffect(() => {
    let tooltip: HTMLDivElement | null = null

    function getTooltip(): HTMLDivElement {
      if (tooltip && document.body.contains(tooltip)) return tooltip
      tooltip = document.createElement("div")
      tooltip.className = "xref-tooltip"
      tooltip.setAttribute("role", "tooltip")
      document.body.appendChild(tooltip)
      return tooltip
    }

    function show(anchor: HTMLAnchorElement) {
      const title = anchor.getAttribute("data-label-title")
      const kind = anchor.getAttribute("data-label-kind")
      if (!title) return

      const el = getTooltip()
      const prefix =
        kind === "fig" ? "Figure: " : kind === "tab" ? "Table: " : ""
      el.textContent = prefix + title
      el.style.display = "block"

      // Position above the anchor
      const rect = anchor.getBoundingClientRect()
      el.style.left = `${rect.left + window.scrollX}px`
      el.style.top = `${rect.top + window.scrollY - el.offsetHeight - 6}px`
    }

    function hide() {
      if (tooltip) tooltip.style.display = "none"
    }

    function onOver(e: MouseEvent) {
      const anchor = (e.target as HTMLElement).closest("a.xref[data-label-title]")
      if (anchor) show(anchor as HTMLAnchorElement)
    }

    function onOut(e: MouseEvent) {
      const anchor = (e.target as HTMLElement).closest("a.xref[data-label-title]")
      if (anchor) hide()
    }

    document.body.addEventListener("mouseover", onOver)
    document.body.addEventListener("mouseout", onOut)

    return () => {
      document.body.removeEventListener("mouseover", onOver)
      document.body.removeEventListener("mouseout", onOut)
      if (tooltip && document.body.contains(tooltip)) {
        document.body.removeChild(tooltip)
      }
    }
  }, [])

  return null
}
