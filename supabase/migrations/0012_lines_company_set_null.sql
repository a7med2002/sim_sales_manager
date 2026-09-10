-- A permanently-deleted company used to take its customers' entire sales
-- history down with it (lines.company_id was `on delete cascade`,
-- inherited from 0002_owned_companies.sql) — a real data-loss bug found
-- in testing. A Line's own frozen `company_name`/`company_initials`/
-- `package_name` snapshot columns (see 0009's migration) already exist
-- specifically so it keeps displaying correctly without a live company
-- row, so there's no reason the row itself needs to disappear too:
-- detach it instead.
alter table public.lines alter column company_id drop not null;
alter table public.lines drop constraint lines_company_id_fkey;
alter table public.lines add constraint lines_company_id_fkey
  foreign key (company_id) references public.companies (id) on delete set null;
