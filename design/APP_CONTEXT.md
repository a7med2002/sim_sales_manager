# Build: SIM/eSIM Sales Manager (Single-User Mobile-First Web App)

## Overview
Build a mobile-first web app for a **single independent seller** who buys eSIM/SIM packages in bulk from telecom supplier companies (wholesale price) and resells them individually to customers (retail price), tracking profit margins, customer balances, and expiry dates.

This is a **single-user app** — no roles, no team management, no multi-tenant logic. Just one login for the owner/seller.

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
- No signup flow needed (single pre-provisioned account) — but include a basic signup for setup purposes.
- After login, land on Home dashboard.

## Data Model (core entities)

**Company** (supplier)
- name, logo (optional upload), notes
- status: active / archived / deleted (soft delete, recoverable)
- has many: Shipments, Packages/Bundles

**Shipment** (balance top-up from a company)
- company (ref), type: "prepaid" or "credit limit"
- total amount, amount paid, amount remaining
- payment method, reference number, date, notes
- Each shipment adds to that company's available balance. Selling a line consumes from the balance at wholesale price. Selling stops when balance is exhausted or credit limit reached.

**Package/Bundle** (optional simple sub-entity of Company)
- name (e.g. "Weekly 500MB"), wholesale cost, suggested retail price

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
- date/time, sale price, cost, profit, payment status, sales rep name (default to the single user)

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
- List (tabs: Active / Archived / Deleted)
- Each company card: logo, name, package count, operations count, total profit generated, balance usage progress bar, amount consumed / available / owed
- "+ Add Company" (name, logo upload, notes) and "Import Ready-Made Company" (pick from a preset list of common telecom brands with their default packages — allow re-importing archived ones)
- Actions per card: archive, delete (soft), pin/favorite

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
