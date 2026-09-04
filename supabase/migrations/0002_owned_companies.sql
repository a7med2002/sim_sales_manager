-- Correction to 0001_init.sql's company model, based on user feedback:
-- a seller's companies are fully their own to add/edit/delete freely
-- (name, logo, packages) — NOT a shared, admin-only-editable catalog
-- entry. `company_catalog`/`package_catalog` stay, but change role: from
-- "the live company record every seller reads" to "an admin-curated
-- template library used only to prefill '+ Add Company' via Import" —
-- a one-time copy, not a live link. See design/APP_CONTEXT.md.
--
-- Safe to drop-and-recreate rather than ALTER: at the time of writing,
-- these tables hold no real seller data yet (Companies was the first
-- feature migrated off mock data, and nobody has used it against this
-- live project yet) — see PROGRESS.md.

drop table if exists public.operations;
drop table if exists public.lines;
drop table if exists public.shipments;
drop table if exists public.seller_companies;

-- ── companies / packages (tenant-owned, fully editable by their seller) ──
create table public.companies (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  logo_url text,
  notes text,
  status text not null default 'active' check (status in ('active', 'archived', 'deleted')),
  pinned boolean not null default false,
  -- Set when this company was created via "Import Ready-Made" — used to
  -- look up `company_catalog.number_update_url` for the Numbers-update
  -- feature, and to detect "already imported" in the import sheet. Not a
  -- live link: editing this company never touches the catalog row, and
  -- editing the catalog row never touches companies imported from it.
  catalog_company_id uuid references public.company_catalog (id),
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.packages (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  company_id uuid not null references public.companies (id) on delete cascade,
  name text not null,
  wholesale_cost numeric(12, 2) not null default 0,
  retail_price numeric(12, 2) not null default 0,
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.companies enable row level security;
alter table public.packages enable row level security;

create policy "companies: owner only" on public.companies
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "packages: owner only" on public.packages
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create index on public.companies (owner_id);
create index on public.packages (owner_id, company_id);

-- ── shipments / lines / operations: re-created referencing `companies`/
--    `packages` (the seller's own rows) instead of the catalog ──────────
create table public.shipments (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  company_id uuid not null references public.companies (id) on delete cascade,
  type text not null check (type in ('prepaid', 'credit_limit')),
  total_amount numeric(12, 2) not null default 0,
  amount_paid numeric(12, 2) not null default 0,
  amount_remaining numeric(12, 2) not null default 0,
  payment_method text,
  reference_number text,
  shipment_date timestamptz not null default now(),
  notes text,
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.lines (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  company_id uuid not null references public.companies (id) on delete cascade,
  package_id uuid references public.packages (id),
  sim_number text not null,
  purchase_date timestamptz not null default now(),
  expiry_date timestamptz not null,
  wholesale_cost numeric(12, 2) not null default 0,
  retail_price numeric(12, 2) not null default 0,
  profit numeric(12, 2) not null default 0,
  payment_status text not null default 'unpaid' check (payment_status in ('paid', 'partial', 'unpaid')),
  amount_paid numeric(12, 2) not null default 0,
  amount_remaining numeric(12, 2) not null default 0,
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.operations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  line_id uuid references public.lines (id) on delete cascade,
  company_id uuid not null references public.companies (id) on delete cascade,
  occurred_at timestamptz not null default now(),
  sale_price numeric(12, 2) not null default 0,
  cost numeric(12, 2) not null default 0,
  profit numeric(12, 2) not null default 0,
  payment_status text not null default 'unpaid' check (payment_status in ('paid', 'partial', 'unpaid')),
  rep_name text,
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.shipments enable row level security;
alter table public.lines enable row level security;
alter table public.operations enable row level security;

create policy "shipments: owner only" on public.shipments
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "lines: owner only" on public.lines
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "operations: owner only" on public.operations
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create index on public.shipments (owner_id);
create index on public.lines (owner_id, customer_id);
create index on public.operations (owner_id);
