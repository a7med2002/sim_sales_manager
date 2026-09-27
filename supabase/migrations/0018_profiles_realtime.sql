-- Lets a signed-in seller's own device get notified the instant an admin
-- deactivates (or reactivates) their account, instead of only finding out
-- on the next periodic/connectivity-triggered sync tick (up to a few
-- minutes later) — see SyncBloc's account-status Realtime subscription.
-- RLS ("profiles: read own row", from 0001_init.sql) already limits what
-- a subscriber can see through this to their own row.
alter publication supabase_realtime add table public.profiles;
