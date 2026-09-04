-- Admin → Support & Feedback needs to actually view a seller's attached
-- photo/voice note (see AdminSupportRequestDetailSheet), but
-- 0003_support_attachments_storage.sql's policies only ever let the
-- owning seller read their own folder in the `support-attachments`
-- bucket — that migration's own comment said "no admin override
-- (nothing here needs one)", written before the admin-side viewer
-- existed. `createSignedUrl` is itself subject to `storage.objects`'
-- RLS (it can only sign a URL for an object the caller may select), so
-- without this, every signed-URL request from an admin account was
-- silently rejected — surfacing in the app as "Couldn't open this
-- attachment" for every photo/voice note, always.
create policy "support-attachments: admin reads all"
  on storage.objects for select
  using (
    bucket_id = 'support-attachments'
    and public.is_admin()
  );
