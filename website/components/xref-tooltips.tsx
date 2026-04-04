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
      tooltip.style.maxWidth = "50ch"
      tooltip.style.whiteSpace = "normal"
      tooltip.style.wordWrap = "break-word"
      document.body.appendChild(tooltip)
      return tooltip
    }

    function showXref(anchor: HTMLAnchorElement) {
      const title = anchor.getAttribute("data-label-title")
      const kind = anchor.getAttribute("data-label-kind")
      const preview = anchor.getAttribute("data-label-preview")
      if (!title) return

      const el = getTooltip()
      const prefix =
        kind === "fig" ? "Figure: " : kind === "tab" ? "Table: " : ""
      el.innerHTML = ""
      const titleEl = document.createElement("strong")
      titleEl.textContent = prefix + title
      el.appendChild(titleEl)
      if (preview) {
        const previewEl = document.createElement("p")
        previewEl.textContent = preview
        previewEl.style.margin = "0.3rem 0 0"
        previewEl.style.fontWeight = "normal"
        previewEl.style.opacity = "0.8"
        previewEl.style.fontSize = "0.7rem"
        previewEl.style.lineHeight = "1.4"
        el.appendChild(previewEl)
      }
      positionAbove(el, anchor)
    }

    function showBibRef(anchor: HTMLAnchorElement) {
      const href = anchor.getAttribute("href")
      if (!href) return
      const targetId = href.replace("#", "")
      const entry = document.getElementById(targetId)
      if (!entry) return

      const el = getTooltip()
      el.innerHTML = ""
      // Get the citation text, stripping the backlink prefix like "[1]"
      const clone = entry.cloneNode(true) as HTMLElement
      const backlinks = clone.querySelectorAll('[role="doc-backlink"]')
      backlinks.forEach((bl) => bl.parentElement?.remove())
      const text = clone.textContent?.trim() ?? ""
      if (!text) return

      const citEl = document.createElement("span")
      citEl.textContent = text.slice(0, 400) + (text.length > 400 ? "…" : "")
      citEl.style.fontSize = "0.7rem"
      citEl.style.lineHeight = "1.4"
      el.appendChild(citEl)
      positionAbove(el, anchor)
    }

    function positionAbove(el: HTMLDivElement, anchor: HTMLElement) {
      el.style.display = "block"
      const rect = anchor.getBoundingClientRect()
      el.style.left = `${rect.left + window.scrollX}px`
      el.style.top = `${rect.top + window.scrollY - el.offsetHeight - 6}px`
    }

    function hide() {
      if (tooltip) tooltip.style.display = "none"
    }

    function getTooltipAnchor(target: EventTarget | null): HTMLAnchorElement | null {
      if (!(target instanceof HTMLElement)) return null
      const xref = target.closest("a.xref[data-label-title]")
      if (xref) return xref as HTMLAnchorElement
      const bibref = target.closest('a[role="doc-biblioref"]')
      if (bibref) return bibref as HTMLAnchorElement
      return null
    }

    function onOver(e: MouseEvent) {
      const anchor = getTooltipAnchor(e.target)
      if (!anchor) return
      if (anchor.matches("a.xref[data-label-title]")) { showXref(anchor); return }
      if (anchor.matches('a[role="doc-biblioref"]')) { showBibRef(anchor); return }
    }

    function onOut(e: MouseEvent) {
      if (getTooltipAnchor(e.target)) hide()
    }

    function onFocusIn(e: FocusEvent) {
      const anchor = getTooltipAnchor(e.target)
      if (!anchor) return
      if (anchor.matches("a.xref[data-label-title]")) { showXref(anchor); return }
      if (anchor.matches('a[role="doc-biblioref"]')) { showBibRef(anchor); return }
    }

    function onFocusOut(e: FocusEvent) {
      if (getTooltipAnchor(e.target)) hide()
    }

    document.body.addEventListener("mouseover", onOver)
    document.body.addEventListener("mouseout", onOut)
    document.body.addEventListener("focusin", onFocusIn)
    document.body.addEventListener("focusout", onFocusOut)

    return () => {
      document.body.removeEventListener("mouseover", onOver)
      document.body.removeEventListener("mouseout", onOut)
      document.body.removeEventListener("focusin", onFocusIn)
      document.body.removeEventListener("focusout", onFocusOut)
      if (tooltip && document.body.contains(tooltip)) {
        document.body.removeChild(tooltip)
      }
    }
  }, [])

  return null
}
