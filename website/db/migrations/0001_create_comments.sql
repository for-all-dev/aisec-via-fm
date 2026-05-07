-- Initial schema for the self-hosted Postgres on the DigitalOcean droplet.
-- See website/CLAUDE.md for the provisioning playbook this aligns with.
create extension if not exists pgcrypto;

create table comments (
  id          uuid primary key default gen_random_uuid(),
  page        text not null,
  anchor      text not null,
  body        text not null,
  name        text,
  created_at  timestamptz not null default now(),
  resolved    boolean not null default false
);

create index idx_comments_page_anchor_resolved on comments (page, anchor, resolved);
