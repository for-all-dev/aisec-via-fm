"use client"

import { useSearchParams } from "next/navigation"
import { useState, FormEvent, Suspense } from "react"

function LoginForm() {
  const searchParams = useSearchParams()
  const from = searchParams.get("from") ?? "/"
  const [pw, setPw] = useState("")
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError("")
    const res = await fetch(`/api/login?from=${encodeURIComponent(from)}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ password: pw }),
    })
    if (res.redirected) {
      window.location.href = res.url
    } else if (!res.ok) {
      setError("access denied")
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="terminal-box p-8 max-w-sm w-full">
        <p className="text-green mb-6 text-sm">
          <span className="text-muted">$ </span>authenticate --site tractable.for-all.dev
        </p>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <label className="text-muted text-xs">PASSWORD:</label>
          <input
            type="password"
            value={pw}
            onChange={(e) => setPw(e.target.value)}
            className="bg-bg-alt border border-border text-fg font-mono px-3 py-2 text-sm focus:outline-none focus:border-green"
            autoFocus
            disabled={loading}
          />
          {error && <p className="text-red text-xs">{error}</p>}
          <button
            type="submit"
            disabled={loading}
            className="border border-green text-green font-mono text-sm px-4 py-2 hover:bg-green hover:text-bg transition-colors disabled:opacity-50"
          >
            {loading ? "..." : "> enter"}
          </button>
        </form>
      </div>
    </div>
  )
}

export default function LoginPage() {
  return (
    <Suspense>
      <LoginForm />
    </Suspense>
  )
}
