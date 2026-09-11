-- Lets the admin app subscribe to new `support_requests` rows in real
-- time (see `SupportRequestRealtimeGate`) so an admin gets a live
-- in-app notification the instant a seller submits a request, without
-- needing to reopen/refresh the Support & Feedback page. Realtime still
-- respects RLS — an admin's subscription only receives rows their own
-- "support_requests: admin reads all" SELECT policy (0004) already
-- allows them to see.
alter publication supabase_realtime add table public.support_requests;
