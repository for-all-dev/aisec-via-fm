"use client"

import { useState, useEffect, useCallback } from "react"
import type { Comment } from "../lib/supabase"

function timeAgo(iso: string): string {
  const seconds = Math.floor((Date.now() - new Date(iso).getTime()) / 1000)
  if (seconds < 60) return "just now"
  const minutes = Math.floor(seconds / 60)
  if (minutes < 60) return `${minutes}m ago`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h ago`
  const days = Math.floor(hours / 24)
  return `${days}d ago`
}

function CommentItem({
  comment,
  isAdmin,
  onMutate,
}: {
  comment: Comment
  isAdmin: boolean
  onMutate: () => void
}) {
  async function resolve() {
    await fetch(`/api/comments/${comment.id}/resolve`, { method: "POST" })
    onMutate()
  }

  async function remove() {
    await fetch(`/api/comments/${comment.id}`, { method: "DELETE" })
    onMutate()
  }

  return (
    <div style={{
      borderBottom: "1px solid var(--border)",
      padding: "0.5rem 0",
      fontSize: "0.8rem",
    }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <span style={{ color: "var(--cyan)" }}>{comment.name || "anon"}</span>
        <span style={{ color: "var(--muted)", fontSize: "0.7rem" }}>{timeAgo(comment.created_at)}</span>
      </div>
      <p style={{ color: "var(--fg-alt)", margin: "0.25rem 0", whiteSpace: "pre-wrap" }}>
        {comment.body}
      </p>
      {isAdmin && (
        <div style={{ display: "flex", gap: "0.5rem", marginTop: "0.25rem" }}>
          <button onClick={resolve} className="comment-action">resolve</button>
          <button onClick={remove} className="comment-action comment-action-danger">delete</button>
        </div>
      )}
    </div>
  )
}

function CommentForm({ page, anchor, onPosted }: { page: string; anchor: string; onPosted: () => void }) {
  const [body, setBody] = useState("")
  const [name, setName] = useState("")
  const [submitting, setSubmitting] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!body.trim()) return
    setSubmitting(true)
    const res = await fetch("/api/comments", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ page, anchor, body: body.trim(), name: name.trim() || null }),
    })
    setSubmitting(false)
    if (res.ok) {
      setBody("")
      onPosted()
    }
  }

  return (
    <form onSubmit={handleSubmit} style={{ marginTop: "0.5rem" }}>
      <textarea
        value={body}
        onChange={(e) => setBody(e.target.value)}
        placeholder="leave a comment..."
        rows={2}
        style={{
          width: "100%",
          background: "var(--bg)",
          border: "1px solid var(--border)",
          color: "var(--fg)",
          fontFamily: "inherit",
          fontSize: "0.8rem",
          padding: "0.4rem",
          resize: "vertical",
        }}
      />
      <div style={{ display: "flex", gap: "0.5rem", marginTop: "0.3rem", alignItems: "center" }}>
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="name (optional)"
          style={{
            background: "var(--bg)",
            border: "1px solid var(--border)",
            color: "var(--fg)",
            fontFamily: "inherit",
            fontSize: "0.75rem",
            padding: "0.3rem 0.4rem",
            width: "10rem",
          }}
        />
        <button
          type="submit"
          disabled={submitting || !body.trim()}
          style={{
            background: "transparent",
            border: "1px solid var(--border)",
            color: "var(--green)",
            fontFamily: "inherit",
            fontSize: "0.75rem",
            padding: "0.3rem 0.6rem",
            cursor: "pointer",
            opacity: submitting || !body.trim() ? 0.4 : 1,
          }}
        >
          {submitting ? "..." : "post"}
        </button>
      </div>
    </form>
  )
}

export function CommentThread({ page, anchor }: { page: string; anchor: string }) {
  const [comments, setComments] = useState<Comment[]>([])
  const [open, setOpen] = useState(false)
  const [isAdmin, setIsAdmin] = useState(false)
  const [hidden, setHidden] = useState(false)

  const load = useCallback(() => {
    fetch(`/api/comments?page=${encodeURIComponent(page)}&anchor=${encodeURIComponent(anchor)}`)
      .then((r) => r.json())
      .then(setComments)
      .catch(() => {})
  }, [page, anchor])

  useEffect(() => {
    load()
  }, [load])

  useEffect(() => {
    setIsAdmin(document.cookie.includes("admin-session"))
    setHidden(localStorage.getItem("hideComments") === "true")

    const handler = () => setHidden(localStorage.getItem("hideComments") === "true")
    window.addEventListener("toggle-comments", handler)
    return () => window.removeEventListener("toggle-comments", handler)
  }, [])

  if (hidden) return null

  return (
    <div className="comment-thread">
      <button
        onClick={() => setOpen(!open)}
        className="comment-toggle"
      >
        {comments.length > 0 ? `${comments.length} comment${comments.length === 1 ? "" : "s"}` : "comment"}
        {open ? " \u25B4" : " \u25BE"}
      </button>

      {open && (
        <div className="comment-panel">
          {comments.length === 0 && (
            <p style={{ color: "var(--muted)", fontSize: "0.75rem", fontStyle: "italic" }}>
              no comments yet
            </p>
          )}
          {comments.map((c) => (
            <CommentItem key={c.id} comment={c} isAdmin={isAdmin} onMutate={load} />
          ))}
          <CommentForm page={page} anchor={anchor} onPosted={load} />
        </div>
      )}
    </div>
  )
}
