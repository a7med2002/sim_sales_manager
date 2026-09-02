# Build: SIM/eSIM Sales Manager (Multi-Tenant Mobile-First + Desktop App)

## Overview
Build a mobile-first app for independent sellers who buy eSIM/SIM packages in bulk from telecom supplier companies (wholesale price) and resell them individually to customers (retail price), tracking profit margins, customer balances, and expiry dates.

**This is now a multi-tenant app** (evolved from an original single-user design — see
"Multi-Tenant & Admin Architecture" below for the full rationale and schema). Each seller
who signs up gets their own fully isolated set of customers, lines, sales, and company
balances — a new seller starts empty and builds up their own data, same as before, but
many sellers now share one deployment instead of there being one hardcoded account.
On top of that, an **admin role** manages a small set of data shared by every seller
(the company/package catalog, per-company number-update URLs, and user accounts) from
admin-only screens inside the same app.

Build the UI in **English first**. Structure all text/labels so they can be swapped for Arabic (RTL) later — i.e., avoid hardcoding layout assumptions that break under RTL, keep strings centralized.

## Design Direction
- **Minimalist black & white** aesthetic: white/very light gray backgrounds, black/near-black text, thin gray borders, generous white space, clean sans-serif typography.
- **One accent color for positive states** (green) — profit, paid, active, success.
- **One accent color for negative/alert states** (red) — debt, unpaid, expired, warnings.
- **One neutral accent for informational states** (amber/yellow) — near-expiry, pending, partial payment.
- No heavy gradients or busy colors elsewhere. Cards should feel like a clean financial/banking app (think Stripe dashboard or Linear, but simpler).
- Rounded corners (medium radius), soft subtle shadows, no clutter.
- Mobile-first responsive design; primary target is phone screens, but should scale cleanly to tablet/desktop.

## Navigation
Bottom navigation bar (fixed, mobile-first) with 5 items:
1. **Home** (dashboard icon)
2. **New Sale** (+ icon, prominent/highlighted — opens the quick-sale flow as a modal/sheet from anywhere)
3. **Companies** (building icon)
4. **Customers** (person icon)
5. **More** (menu icon) — opens a sheet/page listing: Shipments & Operations, Numbers, Profits, Reports, Support & Feedback, Trusted Devices, Activity Log, Settings, Logout

## Authentication
- Simple login screen: username/email + password, "remember me" checkbox, "forgot password" link.
- Real signup flow: a new seller creates their own account (Supabase Auth) and lands on an
  empty dashboard — no customers/companies/lines yet, but the shared company/package
  catalog is visible immediately since it's admin-managed, not per-seller.
- Every authenticated user has a `role` — `seller` (default) or `admin`. After login, a
  `seller` lands on the normal Home dashboard; an `admin` lands on the same app but with an
  additional Admin section available (see below). Admin accounts are created by another
  admin (never via public signup) through the Admin → Users screen.

## Data Model (core entities)

> **Multi-tenant note**: `Company` and `Package/Bundle` are now split into a **shared
> catalog** (one global row per company/package, admin-managed, every seller reads it) and
> **per-seller state** (each seller's own archive/pin status and shipment/balance history
> against that company). See "Multi-Tenant & Admin Architecture" below for the full schema,
> ownership columns, and RLS rules — this section keeps describing the entities at the
> business-logic level only.

**Company** (supplier catalog entry — shared across all sellers)
- name, logo (optional upload), notes, number-update URL (used by the Numbers-update
  feature — see More → Numbers), status: active / archived (admin-managed)
- has many: Packages/Bundles (catalog-level)
- Each seller additionally has their own **per-seller status** for a company (active /
  archived / deleted / pinned in *their* Companies list) and their own **Shipments**
  against it — the catalog entry itself is shared, but a given seller's balance/usage with
  that company is entirely their own.

**Shipment** (balance top-up from a company — belongs to one seller)
- company (ref into the shared catalog), type: "prepaid" or "credit limit"
- total amount, amount paid, amount remaining
- payment method, reference number, date, notes
- Each shipment adds to *that seller's own* available balance with the company. Selling a
  line consumes from the balance at wholesale price. Selling stops when balance is
  exhausted or credit limit reached. Never visible to or shared with other sellers.

**Package/Bundle** (catalog entry, sub-entity of Company — shared across all sellers)
- name (e.g. "Weekly 500MB"), wholesale cost, suggested retail price
- Admin can add/edit packages for any company; changes appear for every seller
  immediately (this is the "import ready-made company/package" flow — a seller picks
  from the existing catalog instead of typing company/package details from scratch).
  A seller can still type a custom price when selling (the catalog's wholesale/retail
  values are defaults/suggestions, not hard limits).

**Customer**
- name, contact number (unique identifier — accepts formats like 05x, +970, 970)
- status: normal / troubled / blocked
- tags (free text, multi)
- pinned (boolean, pin to top of list)
- notes
- has many: Lines (SIMs)

**Line (SIM/eSIM sold to a customer)** — belongs to a Customer
- SIM/phone number
- company (ref), package/bundle name
- purchase date, expiry date
- wholesale cost, retail sale price, profit (auto-calculated = sale price − wholesale cost)
- payment status: paid in full / partially paid / unpaid
- amount paid, amount remaining owed

**Operation** (the sale transaction record — auto-created when a Line is sold, but viewable/editable in its own list)
- links Customer + Line + Company
- date/time, sale price, cost, profit, payment status, sales rep name (defaults to the
  logged-in seller's own name — no team/multi-rep concept, just one rep per seller account)

## Multi-Tenant & Admin Architecture

Evolved from the original single-user design once it became clear multiple independent
sellers need to use the same deployment, each with fully private data, while sharing one
admin-curated company/package catalog and one set of per-company number-update URLs.

### Two kinds of tables

**1. Tenant-scoped** (private to one seller; RLS: `owner_id = auth.uid()`)
- `customers`, `lines`, `operations`, `shipments`, `seller_companies` (a seller's own
  archive/pin/delete state against a catalog company — see below), `activity_log`,
  `trusted_devices`, `support_requests`, `settings`
- Every row carries `owner_id` (the seller's `auth.uid()`), plus the existing offline-first
  `synced` / `updated_at` columns from CLAUDE.md's sync design. A seller can only ever
  read/write their own rows — enforced server-side by RLS, not just hidden in the UI.

**2. Global catalog** (shared; every seller reads, only admins write)
- `company_catalog` — id, name, logo_url, notes, `number_update_url`, status
  (active/archived), created_by, created_at, updated_at
- `package_catalog` — id, `company_catalog_id` (ref), name, wholesale_cost,
  suggested_retail_price, status, created_at, updated_at
- `profiles` — id (= `auth.uid()`), role (`seller` | `admin`), display_name, email,
  is_active (admin can disable a seller's account without deleting their data),
  created_at
- RLS: `SELECT` allowed for any authenticated user; `INSERT`/`UPDATE`/`DELETE` restricted
  to rows where the caller's `profiles.role = 'admin'`.

A seller's "Companies" page is therefore a **join**: `company_catalog` (shared name, logo,
packages) joined with that seller's own `seller_companies` row (their archive/pin/delete
status) and their own `shipments`/balance totals against that `company_catalog_id`. Two
different sellers can both be "using" the same catalog company at once with completely
different balances, shipment histories, and archive states — the catalog row itself never
changes because of what one seller does with it.

### Admin-only account management

Creating or disabling a seller's login can't safely happen from the client with just the
anon key — it needs the Supabase service role. This goes through a small **Supabase Edge
Function** (`admin-manage-user`) that: verifies the caller's JWT has `role = 'admin'` via
`profiles`, then uses the service role to create/disable the `auth.users` row and its
matching `profiles` row. The client never holds a service-role key.

### Admin Panel (screens, inside the same Flutter app)

Gated by `profiles.role == 'admin'` after login — same codebase, same build, runs on
mobile and desktop (Windows/macOS/Linux targets already exist in this project) with no
extra platform work. An admin sees an additional section (e.g. a 6th bottom-nav-equivalent
entry, or a dedicated admin home) with:
- **Company Catalog** — list/add/edit/archive companies; per company, manage its packages
  (add/edit/remove) and its number-update URL. This replaces today's "Import Ready-Made
  Company" preset list with a real, admin-curated, always-current catalog every seller's
  "+ Add Company" reads from.
- **Number Update URLs** — either folded into the Company Catalog screen (one field per
  company) or its own screen if the mapping grows more complex than one URL per company;
  start with the simpler one-field-per-company version.
- **Users** — list all sellers (+ admins), see basic account info, activate/deactivate an
  account, promote/demote role, trigger password reset — all through the
  `admin-manage-user` edge function above, never direct table writes to `auth.users`.

Admin screens are **not** built mock-first like the rest of the app was — their entire
purpose is managing real shared data, so they get built directly against Supabase once the
schema below exists, skipping the throwaway mock-UI phase used for the seller-facing pages
earlier in this project.

### Local (Drift) + sync implications

Each installed app instance is logged into exactly one account, so the on-device Drift
database never needs its own multi-tenant filtering — it's already scoped to "whoever is
logged in on this device." What changes:
- **Pull**: tenant tables pull only the logged-in user's own rows (RLS enforces this even
  without an explicit filter, but the sync engine should still filter by `owner_id`
  client-side to avoid ever depending on RLS alone for correctness); catalog tables
  (`company_catalog`, `package_catalog`) pull in full as a **read-only local mirror** —
  every seller's device holds the whole catalog, not just what they've used.
- **Push**: only tenant-scoped rows with `synced = false` get pushed, same last-write-wins
  `updated_at` rule as before. A seller's device never pushes to `company_catalog` /
  `package_catalog` — those are read-only for the `seller` role both server-side (RLS) and
  client-side (the seller UI never offers to edit them).
- An admin's device additionally syncs catalog-table writes (create/edit/archive a
  company or package) through the normal push/pull cycle like any other write — the only
  difference from a seller's sync is *which* tables that account is allowed to write to,
  which RLS already enforces.

## Screens & Flows

### 1. Home (Dashboard)
- Period filter tabs: All / Today / This Week / This Month / 3 Months / 6 Months / This Year / Custom Range
- Stat cards (grid, 2 columns on mobile): Operations count, Companies count, Total Sales (currency), New Lines sold, Uncollected amount (red if > 0), Total Profit (green)
- "Your Balance with Supplier Companies" section: card per company showing % of balance used (progress bar), amount consumed, amount available to sell, amount owed to company if over credit limit (red text)
- Sales & Profit summary chart (simple line/bar chart, no complexity)

### 2. New Sale (Quick Sell Flow) — accessible from anywhere via the + button
Multi-step modal/sheet:
1. **Select or create customer** — searchable list of existing customers by name/number; "+ New Customer" inline option (name + contact number minimum)
2. **Select company → package/bundle → price** — choose supplier, choose bundle, wholesale cost auto-fills, enter retail sale price (profit shown live as sale price − cost)
3. **Payment details** — amount paid now, remaining balance auto-calculated, payment method, date, optional reference number, optional notes
4. **Confirm & Save** — this creates a Line under the selected customer, creates an Operation record, and deducts from the company's shipment balance

### 3. Companies
- List (tabs: Active / Archived / Deleted) — scoped to this seller's own use of each
  company (their own shipments/balance/archive state); the company/package data itself
  (name, logo, packages) comes from the shared admin-curated catalog described in
  "Multi-Tenant & Admin Architecture" above
- Each company card: logo, name, package count, operations count, total profit generated, balance usage progress bar, amount consumed / available / owed
- "+ Add Company" now means **picking from the shared catalog** (search/browse
  `company_catalog`, pick one, it appears in this seller's own list with a zero balance to
  start) rather than typing a brand new company from scratch — a seller never creates a
  `company_catalog` row directly, only an admin does (Admin → Company Catalog). If a
  seller needs a company that genuinely isn't in the catalog yet, that's an admin request,
  not a self-service action.
- Actions per card: archive, delete (soft), pin/favorite — all seller-local state, never
  affects the shared catalog or other sellers

### 4. Customers
- List (tabs: Active / Deleted), search by name/number, filter by status and tags
- Each row: name (pinned customers show a star, shown first), total lines owned, total purchases amount, total amount owed (red if > 0), last purchase date
- Tap a customer → **Customer Detail Page**:
  - Header: name, contact, status badge, tags, notes
  - Summary: total lines, total spent, total owed
  - **List of all their Lines/SIMs**: each shows company logo, package name, purchase date, expiry date (color-coded: green = active, amber = expiring soon, red = expired), payment status, amount remaining owed
  - "+ Add Line" button on this page — opens the same package/price/payment flow as New Sale but customer is pre-selected
  - Edit/delete customer
- "+ New Customer" button and modal (name*, contact number, tags, status: normal/troubled/blocked, pin to top toggle, notes)

### 5. More → Shipments & Operations (combined page with 2 tabs)
**Tab: Shipments**
- Explanation banner: each company has one balance pool; top-ups add to it, sales consume from it at wholesale price
- "+ New Shipment" (select company, type: prepaid/credit limit, total amount, amount paid, date, payment method, reference number, notes)
- Balance summary per company (same style as Home)
- Totals: total shipments, total paid, total remaining owed
- Transaction history table (company, type, amount, date)

**Tab: Operations**
- Filter cards: Partially Paid, Unpaid, Needs Follow-up, Amount to Collect
- Filters: date range, status, search
- Table: SIM number, company, customer, contact, duration/package, payment status
- "+ Add Operation" (manual entry, same as new sale but without forcing customer creation flow if editing)
- Export to Excel, Import

### 6. More → Numbers
- List of all sold numbers with company, package, status (active/expiring soon/expired), added date, expiry date
- Filters: All / Active / Expiring Soon / Expired
- Export PDF/CSV/Excel

### 7. More → Profits
- Period filters (same as Home)
- Cards: Year profit, Month profit, Week profit, Today profit
- Operations count, Net profit, Total sales for selected period
- Profit trend chart over time
- "Best companies by profit" horizontal bar chart

### 8. More → Reports
- Period + company filters
- Summary cards: Total profit, Total sales, Lines sold, Operations count, Amount to collect, Partially paid, Unpaid
- Full detailed operations table with export to PDF/Excel

### 9. More → Support & Feedback
- Tabs: Suggestion/Idea, Problem/Bug (with optional photo attachment or short voice note), Admin Surveys
- Simple textarea + submit, daily submission limit shown, history of past submissions

### 10. More → Trusted Devices
- List of devices/browsers that have logged in: device name, browser/OS, IP, first login, last login, last verification — "this device" badge, delete/revoke action

### 11. More → Activity Log
- Full audit trail table: timestamp, user, action type (login, shipment added, operation added, customer added, etc.), details — searchable

### 12. More → Settings
- Basic profile info, dark/light mode toggle, logout, app version

## Key Simplifications vs. the reference product
- No multi-role/rep system — single user only
- Shipments & Operations merged into one page with tabs
- Customer is the central hub: all their purchased lines/SIMs live under their profile with individual expiry/payment tracking, instead of being flat unlinked transactions
- One unified "New Sale" flow reachable from anywhere, which creates/selects the customer as its first step
- Persistent bottom navigation instead of only a hamburger menu

## Technical Notes
- Use realistic-looking mock/local data to populate all screens on first load so the app looks alive immediately (2-3 sample companies, 3-5 sample customers with lines, a handful of operations)
- Currency: ₪ (ILS) — but keep it as a configurable symbol/variable, not hardcoded everywhere
- All monetary values should support decimals
- Dark mode toggle should work across all screens (icon already implied in the design)
- Keep component structure clean and modular so pages can be easily localized (Arabic/RTL) later


# Spec: "More" Sub-Pages (Flutter)

## Context
The app's core navigation (Home, New Sale, Companies, Customers, More) is already built.
The "More" page itself is already built and shows a list of 8 rows, each navigating to a
sub-page that still needs to be built. This document specs out each of those 8 sub-pages.

**Design system already established (match it exactly):**
- Background: white / very light gray
- Cards: white, rounded corners (~12-16px), subtle border or soft shadow, generous padding
- Text: black/near-black for primary, gray for secondary/meta text
- Icons: thin line-style icons, black, consistent stroke weight (same family as the ones on
  the More page: truck, hash, trending-up, file, headset, phone, activity, gear)
- Accent colors: green = positive/paid/active, red = negative/unpaid/expired/alerts,
  amber/yellow = pending/partial/expiring soon
- Top bar: page title (bold, large) on the left, dark/light mode toggle circle button on the right
- Bottom nav stays visible/consistent across all these pages (Home, New Sale, Companies,
  Customers, More — with "More" highlighted as active)
- Filter chips/tabs: pill-shaped, active one filled black with white text, inactive ones
  outlined gray with black text
- Buttons: primary = solid black with white text; secondary = outlined black/gray

Each spec below references what the equivalent page looked like in the reference web app
(functionality only) — **rebuild the content/logic, not the visual style**. Visual style
must follow the design system above.

---

## 1. Shipments & Operations
Combined page with 2 tabs at the top: **Shipments** | **Operations**

### Tab: Shipments
- Info banner (light gray card, small text): explains that each company has one balance
  pool — top-ups add to it, sales consume from it at wholesale price, selling stops when
  balance runs out or credit limit is reached
- "+ New Shipment" button (opens a form/sheet):
  - Select company (dropdown, required)
  - Type: two selectable cards — "Prepaid" (money paid to company in advance) or
    "Credit Limit" (a credit ceiling with the company, selling stops if exceeded)
  - Total amount (number input)
  - Amount paid (number input)
  - Remaining (auto-calculated, read-only, shown in a highlighted box)
  - Payment method (text input: cash / transfer / wallet...)
  - Shipment date (date picker, defaults to today)
  - Reference number (optional text input)
  - Notes (optional textarea)
  - Save button
- Balance section: one card per company, same style as Home dashboard's balance cards —
  usage % badge, progress bar, "consumed X", "available to sell X", "owed to company X"
  (red text) if over limit
- Totals card (highlighted border): Total Shipments amount, Paid amount, Remaining amount
- Filter row: company dropdown ("All Companies" default), period pills (All/Today/Week/
  Month/Custom), page size selector
- Transaction history table: Company | Type | Date | Total Amount — scrollable list, each
  row tappable to view/edit details

### Tab: Operations
- 4 small stat cards (2x2 grid): Partially Paid (count), Unpaid (count, red icon),
  Needs Follow-up (count, broken down by overdue/today/expiring-soon), Amount to
  Collect (currency, red)
- Filters row: Duration dropdown, Status dropdown, search bar (search by SIM number or
  operation ID)
- "+ Add Operation" button (manual entry form: customer select/search, company, package,
  sale price, cost, payment status, date, notes)
- Export to Excel button, Import button
- Table (horizontally scrollable on mobile): checkbox | SIM Number | Company | Customer |
  Contact | Duration — tappable row opens operation detail

---

## 2. Numbers
- Page title: "Number Management", subtitle explaining it's a log of every number added,
  each with its own status and expiry
- Export buttons row: PDF, CSV, Excel, plus a refresh icon
- Filter row: period pills (All/Today/Week/Month/3mo/Custom), company dropdown, search by
  phone number
- Status filter pills: All / Active (green dot) / Expiring Soon (amber dot) / Expired (red dot)
- Page size selector (50/100/200/All)
- Table: Number | Company (with logo) | Package/Bundle | Status badge | Date Added |
  Expiry Date (color-coded text: green if far off, amber if within ~7 days, red if past)
- Empty state if no numbers yet: icon + "No numbers yet" message

---

## 3. Profits
- Period filter pills (All/Today/Week/Month/3mo/6mo/This Year/Custom) at top
- 4 stat cards in a row (stack 2x2 on mobile): Year Profit, Month Profit, Week Profit,
  Today Profit — each shows amount (green) + operation count + "tap to filter" hint
- 3 more stat cards: Operations Count (selected period), Net Profit (selected period, green),
  Total Sales (selected period)
- Line/area chart: "Profit Over Time" — simple, clean, single green line, x-axis = dates
- Horizontal bar chart: "Best Companies by Profit" — company name + logo on y-axis, bar
  length = profit amount, sorted descending

---

## 4. Reports
- Period filter pills + company dropdown filter, same style as other pages
- Export buttons: "Print/Save PDF" and "Export Excel"
- Stat cards grid (2 rows x 3-4 cols, stack on mobile): Total Profit, Total Sales, Lines
  Sold, Operations Count, Amount to Collect, Partially Paid count, Unpaid count
- Detailed operations table (below stats): Date | SIM Number | Customer | Company | Package |
  Sale Price | Profit | Payment Status badge | Rep name — full width, scrollable

---

## 5. Support & Feedback
- Subtitle: friendly message inviting bug reports and feature ideas
- 3 tab/pill options at top: "Admin Surveys" | "Suggestion/Idea" | "Problem" (Problem tab
  styled with red outline to stand out, matches urgency)
- Large textarea (placeholder guides the user what to describe), character counter (0/4000)
- Attachments row: "Attach Photo" button and "Record Voice Note" button (up to 1:30), both
  optional
- Submit button + "X of 5 requests left today" counter text
- "My Previous Requests" section below: empty state (icon + "No requests yet, submit your
  first one above") or a list of past submissions with type badge and date if any exist

---

## 6. Trusted Devices
- Subtitle explaining these are devices that skip the verification code until the
  session expires; deleting one will require a code again next login
- Grid of device cards (1 col mobile, 2 col tablet+): device type icon, device name
  (e.g. "Android - Chrome"), "This Device" badge if it's the current one (green), IP
  address, first login date/time, last login date/time, last verification date/time,
  delete/revoke icon button (red trash icon)

---

## 7. Activity Log
- Subtitle: full audit trail of every action taken in the app
- Count badge next to title: "N events"
- Search bar (search within log)
- Page size selector
- Table: Timestamp | Action Type (colored pill badge per type — e.g. blue for
  login/create, amber for edit, green for full-collection, red for delete) | Details
  (free text description of what happened, e.g. "Added new shipment to company X for
  amount Y")
- Since this is single-user, there's no "User" column needed (unlike the reference app)

---

## 8. Settings
- Profile section: avatar/initials circle, name, email (editable fields)
- App preferences: dark/light mode toggle (also mirrors the one in the top bar),
  currency symbol setting (default ₪, editable)
- Change password option
- App version display (e.g. "v1.0.0")
- Logout button (red, with confirmation dialog before logging out — the More page
  already has a Logout row too, so this can either duplicate it or Settings can be
  where the *real* logout with confirmation lives, and More's Logout row opens the
  same confirmation)

---

## Notes for implementation
- Reuse the same stat-card widget, filter-pill widget, and table/list-row widget
  across all these pages rather than rebuilding per page — keep it DRY
- All monetary values use the ₪ symbol as a variable/constant, not hardcoded
- Empty states matter: don't leave any list looking broken when there's no data — always
  show a friendly icon + message + relevant CTA
- Keep all pages consistent with the bottom nav and top bar already established on
  Home/Companies/Customers
