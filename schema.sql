-- Ledger database schema for Supabase (Postgres).
-- Run this once: Supabase dashboard -> SQL Editor -> New query -> paste -> Run.

-- One row per user: salary, currency, categories, recurring items, PIN hash.
create table if not exists public.profiles (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- One row per user per month: the list of expenses logged in that month.
create table if not exists public.months (
  user_id    uuid not null references auth.users(id) on delete cascade,
  month      text not null check (month ~ '^\d{4}-\d{2}$'),
  items      jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, month)
);

-- Row level security: a signed-in user can only touch their own rows.
alter table public.profiles enable row level security;
alter table public.months   enable row level security;

drop policy if exists "own profile" on public.profiles;
create policy "own profile" on public.profiles
  for all to authenticated
  using      (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "own months" on public.months;
create policy "own months" on public.months
  for all to authenticated
  using      (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- Signed-out visitors get no access at all.
revoke all on public.profiles from anon;
revoke all on public.months   from anon;
