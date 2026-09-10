-- In-app update mechanism (this app is sold directly, not distributed
-- through an app store — see PROGRESS.md "In-app update system" for the
-- full design). One row per published release; the app compares its own
-- installed `version_code` (Android's build number, read via
-- package_info_plus) against the highest row here and offers to
-- download+install `apk_path` (a path inside the public `app-releases`
-- Storage bucket) when a newer one exists.
create table public.app_releases (
  id uuid primary key default gen_random_uuid(),
  platform text not null default 'android' check (platform in ('android')),
  version_code integer not null,
  version_name text not null,
  apk_path text not null,
  release_notes text,
  mandatory boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.app_releases enable row level security;

-- Every installed app (even before sign-in — an update check shouldn't
-- require being logged in) needs to read this; only an admin publishes
-- a new release.
create policy "app_releases: everyone reads" on public.app_releases
  for select using (true);
create policy "app_releases: admin writes" on public.app_releases
  for all using (public.is_admin()) with check (public.is_admin());

-- Public bucket: an APK isn't sensitive data (same nature as a
-- publishable anon key already baked into the client) and a public URL
-- lets the app download it with a plain HTTP GET for progress tracking
-- instead of needing an authenticated Storage call.
insert into storage.buckets (id, name, public)
values ('app-releases', 'app-releases', true)
on conflict (id) do nothing;

create policy "app-releases bucket: everyone reads" on storage.objects
  for select using (bucket_id = 'app-releases');
create policy "app-releases bucket: admin writes" on storage.objects
  for all using (bucket_id = 'app-releases' and public.is_admin())
  with check (bucket_id = 'app-releases' and public.is_admin());
