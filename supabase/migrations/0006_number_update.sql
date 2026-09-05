-- Number Update: real automated per-company refresh against a handful
-- of suppliers' own (undocumented) endpoints — see PROGRESS.md's Number
-- Update entry for how each one was reverse-engineered and verified,
-- and lib/features/number_update/data/number_update_providers.dart for
-- the actual HTTP calls.

-- Which integration a company maps to. Nullable: most companies have
-- nothing automated. Lives on both the seller's own `companies` (a
-- seller picks this directly, e.g. for a company they typed by hand)
-- and the shared `company_catalog` (an admin can pre-configure it so it
-- carries over automatically when a seller imports that company via
-- "Import Ready-Made").
alter table public.companies add column if not exists number_update_provider text;
alter table public.company_catalog add column if not exists number_update_provider text;

-- Append-only history of update attempts, same owner-only shape as
-- every other tenant table.
create table public.number_update_log (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  phone_number text not null,
  status text not null check (status in ('success', 'not_found', 'failed')),
  message text not null,
  created_at timestamptz not null default now(),
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);
alter table public.number_update_log enable row level security;

create policy "number_update_log: owner only" on public.number_update_log
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create index on public.number_update_log (owner_id);
