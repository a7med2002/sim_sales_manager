-- Remembers which supplier a phone number matched last time Number
-- Update auto-tried it (Liyan -> QuickLine -> Areen -> Sky), so the next
-- update for that number tries that supplier first instead of repeating
-- the full trial-and-error order every time.
create table public.number_update_provider_cache (
  owner_id uuid not null references public.profiles (id) on delete cascade,
  phone_number text not null,
  provider text not null,
  updated_at timestamptz not null default now(),
  primary key (owner_id, phone_number)
);

alter table public.number_update_provider_cache enable row level security;

create policy "number_update_provider_cache: owner only" on public.number_update_provider_cache
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
