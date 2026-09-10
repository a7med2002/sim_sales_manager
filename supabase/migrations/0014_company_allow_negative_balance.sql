-- "Allow negative balance" per company (see PROGRESS.md) — an explicit
-- opt-in a seller sets per supplier so one sale can dip
-- available-to-sell below zero (a one-time credit-line style grace,
-- enforced client-side: allowed only while the balance is still above
-- zero, blocked again once it's at or below zero until a new shipment
-- tops it back up). Defaults to false so every existing company keeps
-- today's behavior (a sale is blocked once it would exceed the balance)
-- until a seller opts in.
alter table public.companies
  add column allow_negative_balance boolean not null default false;
