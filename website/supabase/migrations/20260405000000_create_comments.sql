-- Comments table for section-anchored commenting system
create table comments (
  id          uuid primary key default gen_random_uuid(),
  page        text not null,
  anchor      text not null,
  body        text not null,
  name        text,
  created_at  timestamptz not null default now(),
  resolved    boolean not null default false
);

-- Index for the common read path
create index idx_comments_page_anchor_resolved on comments (page, anchor, resolved);

-- Enable RLS
alter table comments enable row level security;

-- Anyone can read unresolved comments
create policy "public read" on comments
  for select using (resolved = false);

-- Anyone can insert
create policy "public insert" on comments
  for insert with check (true);

-- Service role bypasses RLS automatically for resolve/delete
