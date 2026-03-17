# Comment Platform: Sizing & Design Spec

_Written 2026-03-17. Decisions locked in from Quinn's answers._

---

## TL;DR

Medium-sized feature. Decisions are all made. This is now a build spec.

Rough sizing: **1–2 days** to a working MVP with Supabase + Vercel, **+0.5 days** for polish.

---

## Decisions (locked)

| Question | Answer |
|---|---|
| Storage | Supabase (Postgres) |
| Deployment | Vercel |
| Admin auth | `PASSWORD` (normal users) + `ADMIN_PASSWORD` (Quinn only), separate cookies |
| Anchor granularity | Section-level (heading slugs) |
| Anchor stability | Section slugs must survive `.typ` content edits — only heading text renames break them |
| Resolve semantics | Hidden from public by default; admin can also hard-delete |
| Notifications | None |
| Threading | Flat |

---

## Supabase Schema

```sql
create table comments (
  id          uuid primary key default gen_random_uuid(),
  page        text not null,        -- e.g. "/problems/sel4-gpu-drivers"
  anchor      text not null,        -- section slug, e.g. "background"
  body        text not null,
  name        text,                 -- optional signature, null if blank
  created_at  timestamptz not null default now(),
  resolved    boolean not null default false
);

-- Index for the common read path
create index on comments (page, anchor, resolved);
```

Row-level security: table is publicly readable (filtered to `resolved = false`) and publicly insertable. Resolve/delete require service role key (server-side only, never in client bundle).

---

## Auth Model

Two tiers, two cookies:

| Tier | Env var | Cookie | Capability |
|---|---|---|---|
| Reader | `PASSWORD` | `pw-session` | View site, post comments |
| Admin | `ADMIN_PASSWORD` | `admin-session` | All of above + resolve + delete |

`proxy.ts` already handles `pw-session`. Add a `/api/admin-login` route that checks `ADMIN_PASSWORD` and sets `admin-session` (httpOnly, sameSite). The resolve/delete API routes check for `admin-session`.

The `/admin` page is just a one-field password form that hits `/api/admin-login`. No separate login UI needed beyond that.

---

## Anchor Stability Contract

Section slugs are derived from heading text in `.typ` files:

```
= Introduction           → "introduction"
== Background on AI      → "background-on-ai"
=== Firmware Layer       → "firmware-layer"
```

Rule: **slugify = lowercase + replace non-alphanumeric runs with `-` + trim**.

Stability guarantee: comments survive any `.typ` edit that doesn't rename a heading. If a heading is renamed, comments for that anchor become "orphaned" — they still exist in Supabase but no section claims them. The admin UI should have a view of orphaned comments (page + anchor with zero matching headings in current content) so they can be cleaned up.

This is a one-time risk when content is being finalized. Low priority for MVP.

---

## API Surface

```
POST /api/comments
  body: { page, anchor, body, name? }
  auth: pw-session (any logged-in user)
  → 201 { id }

GET  /api/comments?page=&anchor=
  auth: none (public)
  → Comment[] (resolved=false only)

POST /api/comments/[id]/resolve
  auth: admin-session required
  → 200

DELETE /api/comments/[id]
  auth: admin-session required
  → 204
```

Four routes, ~30–50 lines each. All use Supabase JS client with service role key server-side.

---

## TypeScript Types

```ts
type Comment = {
  id: string;
  page: string;
  anchor: string;
  body: string;
  name: string | null;
  created_at: string;
  resolved: boolean;
};
```

---

## Component Sketch

```
<CommentThread page="/problems/sel4" anchor="background">
  ├── comment count badge (collapsed by default, expands on click)
  ├── <CommentList>
  │     ├── <CommentItem> × n
  │     │     ├── body + name + timestamp
  │     │     └── [admin only] Resolve button | Delete button
  │     └── (empty state: "No comments yet")
  └── <CommentForm>
        ├── textarea (body, required)
        ├── input (name, optional, placeholder "Anonymous")
        └── Submit button
```

Global nav: "Hide comments" toggle → sets `localStorage.hideComments = true` → all `<CommentThread>` components render null.

Admin panel at `/admin`:
- Password form → sets `admin-session` cookie
- Once authenticated, the resolve/delete buttons appear inline on every `<CommentThread>` across the site (same session cookie, same page)

~150–200 lines of TSX total for the component tree.

---

## Static Export Compatibility

Current pages use `export const dynamic = "force-static"`. Comments are dynamic — they must be fetched client-side. **Do not SSR comments.** Pattern:

```ts
const [comments, setComments] = useState<Comment[]>([]);
useEffect(() => {
  fetch(`/api/comments?page=${page}&anchor=${anchor}`)
    .then(r => r.json())
    .then(setComments);
}, [page, anchor]);
```

Pages can keep `force-static` for their HTML shell. Only the comment thread hydrates dynamically. No change needed to the build pipeline.

---

## Risk Register

| Risk | Severity | Mitigation |
|---|---|---|
| Spam / abuse | Low-Medium | Low-traffic academic site; honeypot field; Supabase rate limits |
| Orphaned anchors on heading rename | Low | Admin "orphans" view (post-MVP) |
| `ADMIN_PASSWORD` leaks | Low | httpOnly cookie, never in client bundle, env var only |
| Supabase free tier limits | Negligible | 500MB DB, 2GB bandwidth — way above what a position paper needs |

---

## Implementation Order (suggested)

1. Supabase project + schema + env vars
2. `/api/comments` GET + POST routes
3. `<CommentThread>` component (read-only first, then form)
4. `/api/admin-login` + `/admin` page
5. `/api/comments/[id]/resolve` + `/api/comments/[id]` DELETE
6. Resolve/delete buttons in `<CommentThread>` (admin-session gated)
7. "Hide all comments" toggle in nav
8. Wire `<CommentThread>` into section headings in existing pages
