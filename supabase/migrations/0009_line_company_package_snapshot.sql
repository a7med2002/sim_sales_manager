-- A Line only ever stored company_id/package_id (FKs) — the display
-- name/initials/package name were re-derived live from whichever
-- companies were currently loaded on the device. That join is fragile:
-- Lines and Companies sync independently, so a just-added company's own
-- pull can still be in flight when a Line referencing it loads on
-- another device, and the join has no way to notice once it later
-- finishes — showing a permanently blank company on that Line until the
-- app restarts. Storing a frozen snapshot at sale time (like a real
-- receipt would) fixes this for good and also means a later company
-- rename/archive doesn't retroactively change historical Lines.
alter table public.lines add column if not exists company_name text;
alter table public.lines add column if not exists company_initials text;
alter table public.lines add column if not exists package_name text;
