-- A manual fallback for Number Update: `company_catalog.number_update_url`
-- has existed since 0001 (admin-only, purely informational until now),
-- but a seller's own `companies` never had an equivalent — so a company
-- with no automated `number_update_provider` (see 0006) had nothing to
-- fall back to besides a plain error message. This lets a seller store
-- the supplier's manual update page for their own companies too (typed
-- directly, or carried over from a catalog import).
alter table public.companies add column if not exists number_update_url text;
