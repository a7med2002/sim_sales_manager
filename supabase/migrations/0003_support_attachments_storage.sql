-- Storage for Support & Feedback attachments (photo + voice note), the
-- one remaining real gap flagged throughout PROGRESS.md: the text
-- submission has persisted for real since the Support & Feedback pass,
-- but photo/voice-note files stayed local-file-only because no Storage
-- bucket existed yet. This creates it.
--
-- Private bucket, one folder per owner: objects live at
-- `{owner_id}/{request_id}/photo.<ext>` and `{owner_id}/{request_id}/voice.m4a`.
-- RLS checks the first path segment against `auth.uid()`, same owner-only
-- shape every other table already uses — a seller can only read/write
-- their own files. An admin-read policy was added later, once the admin
-- side actually needed to view these — see
-- 0005_admin_reads_support_attachments.sql.
insert into storage.buckets (id, name, public)
values ('support-attachments', 'support-attachments', false)
on conflict (id) do nothing;

create policy "support-attachments: owner can upload own files"
  on storage.objects for insert
  with check (
    bucket_id = 'support-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "support-attachments: owner can read own files"
  on storage.objects for select
  using (
    bucket_id = 'support-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "support-attachments: owner can update own files"
  on storage.objects for update
  using (
    bucket_id = 'support-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "support-attachments: owner can delete own files"
  on storage.objects for delete
  using (
    bucket_id = 'support-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
