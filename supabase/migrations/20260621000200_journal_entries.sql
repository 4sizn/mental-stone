-- public.journal_entries: a recorded emotion / diary moment, owner-scoped.
create table if not exists public.journal_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  mood text,
  body text,
  created_at timestamptz not null default now()
);

comment on table public.journal_entries is 'User journal / emotion entries.';

create index if not exists journal_entries_user_created_idx
  on public.journal_entries (user_id, created_at desc);

alter table public.journal_entries enable row level security;

drop policy if exists "Entries are selectable by owner" on public.journal_entries;
create policy "Entries are selectable by owner"
  on public.journal_entries for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Entries are insertable by owner" on public.journal_entries;
create policy "Entries are insertable by owner"
  on public.journal_entries for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Entries are updatable by owner" on public.journal_entries;
create policy "Entries are updatable by owner"
  on public.journal_entries for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Entries are deletable by owner" on public.journal_entries;
create policy "Entries are deletable by owner"
  on public.journal_entries for delete
  to authenticated
  using (auth.uid() = user_id);
