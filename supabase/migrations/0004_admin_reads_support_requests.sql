-- Admin → Support & Feedback: an admin needs to read every seller's
-- submitted requests to triage/respond to them, which `support_requests`'
-- existing "owner only" policy (0001) never allowed — same shape as
-- `profiles: admin reads all`, reusing the same `is_admin()` helper.
-- Read-only: admins never write to another seller's support_requests row
-- (nothing in the app needs that — replying happens over email, outside
-- the database).
create policy "support_requests: admin reads all"
  on public.support_requests for select
  using (public.is_admin());
