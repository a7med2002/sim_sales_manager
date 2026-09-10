-- Company logos — the `logo_url` column has existed on both `companies`
-- and `company_catalog` since the very first migration, but nothing
-- ever wrote to it: no upload UI existed. This adds the Storage bucket
-- + RLS so one can actually be built.
--
-- Public bucket (logos aren't sensitive — unlike support attachments,
-- there's no reason to gate reads behind a signed URL): anyone with the
-- object's public URL can view it, but only the owning seller can write
-- to their own folder, and only an admin can write to the shared
-- `catalog/` folder used by `company_catalog` entries.
--
-- Path convention: `{owner_id}/{company_id}.<ext>` for a seller's own
-- company, `catalog/{catalog_company_id}.<ext>` for a shared catalog
-- entry.
insert into storage.buckets (id, name, public)
values ('company-logos', 'company-logos', true)
on conflict (id) do nothing;

create policy "company-logos: owner can upload own files"
  on storage.objects for insert
  with check (
    bucket_id = 'company-logos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "company-logos: owner can update own files"
  on storage.objects for update
  using (
    bucket_id = 'company-logos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "company-logos: owner can delete own files"
  on storage.objects for delete
  using (
    bucket_id = 'company-logos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "company-logos: admin manages catalog files"
  on storage.objects for all
  using (
    bucket_id = 'company-logos'
    and (storage.foldername(name))[1] = 'catalog'
    and public.is_admin()
  )
  with check (
    bucket_id = 'company-logos'
    and (storage.foldername(name))[1] = 'catalog'
    and public.is_admin()
  );
