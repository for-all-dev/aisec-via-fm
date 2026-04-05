"use client"

import { useState } from "react"

export default function AdminPage() {
  const [password, setPassword] = useState("")
  const [status, setStatus] = useState<"idle" | "ok" | "error">("idle")

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    const res = await fetch("/api/admin-login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ password }),
    })
    if (res.ok) {
      setStatus("ok")
    } else {
      setStatus("error")
    }
  }

  return (
    <div className="page">
      <div className="page-header">
        <p className="eyebrow">admin</p>
        <h1>Admin Login</h1>
      </div>

      {status === "ok" ? (
        <p style={{ color: "var(--green)" }}>
          Authenticated. Resolve/delete buttons are now active across the site.
        </p>
      ) : (
        <form onSubmit={handleSubmit} style={{ display: "flex", gap: "0.5rem", alignItems: "center" }}>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="admin password"
            style={{
              background: "var(--bg-alt)",
              border: "1px solid var(--border)",
              color: "var(--fg)",
              padding: "0.4rem 0.6rem",
              fontFamily: "inherit",
              fontSize: "0.85rem",
            }}
          />
          <button
            type="submit"
            style={{
              background: "transparent",
              border: "1px solid var(--border)",
              color: "var(--green)",
              padding: "0.4rem 0.8rem",
              fontFamily: "inherit",
              fontSize: "0.85rem",
              cursor: "pointer",
            }}
          >
            login
          </button>
          {status === "error" && (
            <span style={{ color: "var(--red)", fontSize: "0.8rem" }}>wrong password</span>
          )}
        </form>
      )}
    </div>
  )
}
