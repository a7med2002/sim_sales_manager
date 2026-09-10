-- "SIM type" — a free-typed label for which SIM/line a package/bundle
-- runs on (e.g. "Cellcom Bundle — monthly"), shown next to the package
-- name everywhere a package appears (seller + admin). Added to both the
-- seller-owned `packages` table and the shared admin `package_catalog`,
-- plus `lines.package_sim_type` (the same frozen-snapshot pattern as
-- `lines.package_name`/`company_name` from migration 0009 — a sold
-- line keeps showing correctly even if the package is edited/removed
-- later).
alter table public.packages add column if not exists sim_type text;
alter table public.package_catalog add column if not exists sim_type text;
alter table public.lines add column if not exists package_sim_type text;
