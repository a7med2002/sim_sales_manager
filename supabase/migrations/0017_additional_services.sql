-- Backs up the local `additional_services` table (see
-- lib/core/database/tables/additional_services_table.dart) — one row
-- per "Additional Service" data top-up applied to a line (extra GB
-- activated when the customer's data runs out before month's end).
-- Kept separate from `lines` on purpose: amount_deducted/amount_charged
-- are independent of a line's own retail_price/amount_remaining, and
-- this gives a real per-line history (one row per top-up) instead of a
-- mutated running total on the line itself.
create table public.additional_services (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  line_id uuid not null references public.lines (id) on delete cascade,
  customer_id uuid not null,
  company_id uuid,
  amount_deducted numeric not null,
  amount_charged numeric not null default 0,
  gb_added numeric not null default 30,
  collected boolean not null default false,
  created_at timestamptz not null,
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

create index on public.additional_services (owner_id, line_id);
create index on public.additional_services (owner_id, customer_id);

alter table public.additional_services enable row level security;

create policy "additional_services: owner only" on public.additional_services
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
