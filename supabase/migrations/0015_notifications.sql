-- Backs up the local `notifications` table (see
-- lib/core/database/tables/notifications_table.dart) so a scheduled
-- reminder survives clearing the app's local storage or reinstalling —
-- on the next sign-in, `NotificationsCubit` pulls this table back and
-- re-arms every still-future row with the OS scheduler again.
-- `os_notification_id` is a pure function of `id` (a hash), so it comes
-- back identical after a reinstall — re-scheduling by it is safe.
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  os_notification_id bigint not null,
  type text not null,
  title text not null,
  body text not null,
  related_entity_id text,
  fire_at timestamptz not null,
  read boolean not null default false,
  synced boolean not null default true,
  updated_at timestamptz not null default now()
);

create index on public.notifications (owner_id, fire_at);

alter table public.notifications enable row level security;

create policy "notifications: owner only" on public.notifications
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
