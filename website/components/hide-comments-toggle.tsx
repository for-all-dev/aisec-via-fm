"use client"

import { useState, useEffect } from "react"

export function HideCommentsToggle() {
  const [hidden, setHidden] = useState(false)

  useEffect(() => {
    setHidden(localStorage.getItem("hideComments") === "true")
  }, [])

  function toggle() {
    const next = !hidden
    setHidden(next)
    localStorage.setItem("hideComments", String(next))
    window.dispatchEvent(new Event("toggle-comments"))
  }

  return (
    <button onClick={toggle} className={`nav-toggle${hidden ? "" : " active"}`}>
      {hidden ? "show comments" : "comments on"}
    </button>
  )
}
