-- SIM Sales Manager — initial multi-tenant schema
--
-- Two kinds of tables (see design/APP_CONTEXT.md "Multi-Tenant & Admin
-- Architecture" for the full rationale):
--   1. Tenant-scoped: one seller's own data, isolated by RLS on owner_id.
--   2. Global catalog: company/package data + user profiles, shared read
--      access, write restricted to admins.

-- ── profiles ────────────────────────────────────────────────────────────
-- One row per auth user. role drives both RLS (is_admin() below) and the
-- app's own navigation (seller vs admin UI).
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role text not null default 'seller' check (role in ('seller', 'admin')),
  display_name text,
  email text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Auto-create a profile row whenever a new auth user signs up.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name)
  values (new.id, new.email, new.raw_user_meta_data ->> 'display_name');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Helper used by every RLS policy below instead of repeating the same
-- subquery — keeps policies short and avoids typos drifting between them.
create function public.is_admin()
returns boolean
language sql
stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin' and is_active
  );
$$;

alter table public.profiles enable row level security;

create policy "profiles: read own row" on public.profiles
  for select using (id = auth.uid());

create policy "profiles: admin reads all" on public.profiles
  for select using (public.is_admin());

create policy "profiles: admin updates any row" on public.profiles
  for update using (public.is_admin());

-- ── company_catalog / package_catalog (global, admin-managed) ─────────────
create table public.company_catalog (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text,
  notes text,
  number_update_url text,
  status text not null default 'active' check (status in ('active', 'archived')),
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.package_catalog (
  id uuid primary key default gen_random_uuid(),
  company_catalog_id uuid not null references public.company_catalog (id) on delete cascade,
  name text not null,
  wholesale_cost numeric(12, 2) not null default 0,
  suggested_retail_price numeric(12, 2) not null default 0,
  status text not null default 'active' check (status in ('active', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.company_catalog enable row level security;
alter table public.package_catalog enable row level security;

create policy "company_catalog: everyone reads" on public.company_catalog
  for select using (true);
create policy "company_catalog: admin writes" on public.company_catalog
  for all using (public.is_admin()) with check (public.is_admin());

create policy "package_catalog: everyone reads" on public.package_catalog
  for select using (true);
create policy "package_catalog: admin writes" on public.package_catalog
  for all using (public.is_admin()) with check (public.is_admin());

-- ── tenant-scoped tables ──────────────────────────────────────────────────
-- Every table below carries owner_id + the offline-first sync columns
-- (synced, updated_at) described in CLAUDE.md. RLS restricts every seller
-- to their own rows; admins get no special access here on purpose — a
-- seller's customer/sales data is never visible to anyone but them.

create table public.customers (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  contact_number text not null,
  status text not null default 'normal' check (status in ('normal', 'troubled', 'blocked')),
  tags text[] not null default '{}',
  pinned boolean not null default false,
  notes text,
  deleted boolean not null default false,
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.seller_companies (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  company_catalog_id uuid not null references public.company_catalog (id),
  status text not null default 'active' check (status in ('active', 'archived', 'deleted')),
  pinned boolean not null default false,
  notes text,
  synced boolean not null default true,
  updated_at timestamptz not null default now(),
  unique (owner_id, company_catalog_id)
);

create table public.shipments (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  company_catalog_id uuid not null references public.company_catalog (id),
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
  company_catalog_id uuid not null references public.company_catalog (id),
  package_catalog_id uuid references public.package_catalog (id),
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
  company_catalog_id uuid not null references public.company_catalog (id),
  occurred_at timestamptz not null default now(),
  sale_price numeric(12, 2) not null default 0,
  cost numeric(12, 2) not null default 0,
  profit numeric(12, 2) not null default 0,
  payment_status text not null default 'unpaid' check (payment_status in ('paid', 'partial', 'unpaid')),
  rep_name text,
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.activity_log (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  occurred_at timestamptz not null default now(),
  action_type text not null,
  details text,
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.trusted_devices (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  device_name text not null,
  browser_os text,
  ip_address text,
  first_login timestamptz not null default now(),
  last_login timestamptz not null default now(),
  last_verification timestamptz,
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.support_requests (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  type text not null check (type in ('suggestion', 'problem', 'admin_survey')),
  body text not null,
  attachment_url text,
  voice_note_url text,
  created_at timestamptz not null default now(),
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.settings (
  owner_id uuid primary key references public.profiles (id) on delete cascade,
  currency_symbol text not null default '₪',
  theme_preference text not null default 'system' check (theme_preference in ('system', 'light', 'dark')),
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.customers enable row level security;
alter table public.seller_companies enable row level security;
alter table public.shipments enable row level security;
alter table public.lines enable row level security;
alter table public.operations enable row level security;
alter table public.activity_log enable row level security;
alter table public.trusted_devices enable row level security;
alter table public.support_requests enable row level security;
alter table public.settings enable row level security;

-- Same owner-only policy shape repeated per tenant table: a seller can
-- only ever see/write their own rows, full stop — no admin override.
create policy "customers: owner only" on public.customers
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "seller_companies: owner only" on public.seller_companies
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "shipments: owner only" on public.shipments
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "lines: owner only" on public.lines
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "operations: owner only" on public.operations
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "activity_log: owner only" on public.activity_log
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "trusted_devices: owner only" on public.trusted_devices
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "support_requests: owner only" on public.support_requests
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "settings: owner only" on public.settings
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

-- Helpful indexes for the sync engine's pull-by-owner / push-pending queries.
create index on public.customers (owner_id);
create index on public.seller_companies (owner_id);
create index on public.shipments (owner_id);
create index on public.lines (owner_id, customer_id);
create index on public.operations (owner_id);
create index on public.activity_log (owner_id);
create index on public.trusted_devices (owner_id);
create index on public.support_requests (owner_id);
create index on public.package_catalog (company_catalog_id);
