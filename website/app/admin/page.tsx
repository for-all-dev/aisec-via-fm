"use client"

import { useCallback, useEffect, useState } from "react"
import type { Comment } from "../../lib/supabase"

export default function AdminPage() {
  const [password, setPassword] = useState("")
  const [authed, setAuthed] = useState(false)
  const [error, setError] = useState(false)
  const [comments, setComments] = useState<Comment[] | null>(null)
  const [feedError, setFeedError] = useState<string | null>(null)

  const loadFeed = useCallback(async () => {
    setFeedError(null)
    const res = await fetch("/api/comments", { cache: "no-store" })
    if (!res.ok) {
      setFeedError("failed to load comments")
      return
    }
    const data: Comment[] = await res.json()
    data.sort((a, b) => b.created_at.localeCompare(a.created_at))
    setComments(data)
  }, [])

  useEffect(() => {
    fetch("/api/admin-check", { cache: "no-store" })
      .then((r) => r.json())
      .then((d) => {
        if (d.admin) setAuthed(true)
      })
      .catch(() => {})
  }, [])

  useEffect(() => {
    if (authed) loadFeed()
  }, [authed, loadFeed])

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    const res = await fetch("/api/admin-login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ password }),
    })
    if (res.ok) {
      setAuthed(true)
      setError(false)
    } else {
      setError(true)
    }
  }

  async function resolve(id: string) {
    const res = await fetch(`/api/comments/${id}/resolve`, { method: "POST" })
    if (res.ok) loadFeed()
  }

  async function remove(id: string) {
    if (!confirm("delete this comment?")) return
    const res = await fetch(`/api/comments/${id}`, { method: "DELETE" })
    if (res.ok) loadFeed()
  }

  return (
    <div className="page">
      <div className="page-header">
        <p className="eyebrow">admin</p>
        <h1>Admin</h1>
      </div>

      {!authed ? (
        <form
          onSubmit={handleSubmit}
          style={{ display: "flex", gap: "0.5rem", alignItems: "center" }}
        >
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
          {error && (
            <span style={{ color: "var(--red)", fontSize: "0.8rem" }}>
              wrong password
            </span>
          )}
        </form>
      ) : (
        <CommentFeed
          comments={comments}
          error={feedError}
          onResolve={resolve}
          onDelete={remove}
          onRefresh={loadFeed}
        />
      )}
    </div>
  )
}

function CommentFeed({
  comments,
  error,
  onResolve,
  onDelete,
  onRefresh,
}: {
  comments: Comment[] | null
  error: string | null
  onResolve: (id: string) => void
  onDelete: (id: string) => void
  onRefresh: () => void
}) {
  const [showResolved, setShowResolved] = useState(false)

  if (error) {
    return <p style={{ color: "var(--red)" }}>{error}</p>
  }

  if (comments === null) {
    return <p style={{ opacity: 0.6 }}>loading…</p>
  }

  const visible = showResolved ? comments : comments.filter((c) => !c.resolved)

  return (
    <div>
      <div
        style={{
          display: "flex",
          gap: "1rem",
          alignItems: "center",
          marginBottom: "1rem",
          fontSize: "0.8rem",
        }}
      >
        <span style={{ opacity: 0.7 }}>
          {visible.length} comment{visible.length === 1 ? "" : "s"}
          {showResolved ? " (including resolved)" : " open"}
        </span>
        <label
          style={{
            display: "flex",
            gap: "0.3rem",
            alignItems: "center",
            cursor: "pointer",
          }}
        >
          <input
            type="checkbox"
            checked={showResolved}
            onChange={(e) => setShowResolved(e.target.checked)}
          />
          show resolved
        </label>
        <button
          onClick={onRefresh}
          style={{
            background: "transparent",
            border: "1px solid var(--border)",
            color: "var(--fg)",
            padding: "0.2rem 0.5rem",
            fontFamily: "inherit",
            fontSize: "0.75rem",
            cursor: "pointer",
          }}
        >
          refresh
        </button>
      </div>

      {visible.length === 0 ? (
        <p style={{ opacity: 0.6 }}>no comments.</p>
      ) : (
        <ul style={{ listStyle: "none", padding: 0, margin: 0 }}>
          {visible.map((c) => (
            <li
              key={c.id}
              style={{
                border: "1px solid var(--border)",
                padding: "0.75rem",
                marginBottom: "0.5rem",
                opacity: c.resolved ? 0.55 : 1,
              }}
            >
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  gap: "1rem",
                  fontSize: "0.75rem",
                  opacity: 0.7,
                  marginBottom: "0.4rem",
                }}
              >
                <span>
                  <a
                    href={`${c.page}#${c.anchor}`}
                    style={{ color: "var(--blue)" }}
                  >
                    {c.page}#{c.anchor}
                  </a>
                  {" · "}
                  <span>{c.name || "anon"}</span>
                  {c.resolved && (
                    <span style={{ color: "var(--green)" }}> · resolved</span>
                  )}
                </span>
                <span>{new Date(c.created_at).toLocaleString()}</span>
              </div>
              <div
                style={{
                  whiteSpace: "pre-wrap",
                  fontSize: "0.9rem",
                  marginBottom: "0.5rem",
                }}
              >
                {c.body}
              </div>
              <div style={{ display: "flex", gap: "0.5rem" }}>
                {!c.resolved && (
                  <button
                    onClick={() => onResolve(c.id)}
                    style={{
                      background: "transparent",
                      border: "1px solid var(--border)",
                      color: "var(--green)",
                      padding: "0.2rem 0.5rem",
                      fontFamily: "inherit",
                      fontSize: "0.75rem",
                      cursor: "pointer",
                    }}
                  >
                    resolve
                  </button>
                )}
                <button
                  onClick={() => onDelete(c.id)}
                  style={{
                    background: "transparent",
                    border: "1px solid var(--border)",
                    color: "var(--red)",
                    padding: "0.2rem 0.5rem",
                    fontFamily: "inherit",
                    fontSize: "0.75rem",
                    cursor: "pointer",
                  }}
                >
                  delete
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
