# DESIGN_SYSTEM.md

Reference: `design/screenshots/` (exported from the Lovable prototype). This file is
the source of truth for exact values — the screenshots are for layout/composition
reference only.

## Colors
```
Background:        #FAFAFA (light) / #121212 (dark)
Surface (cards):    #FFFFFF (light) / #1E1E1E (dark)
Primary text:        #0A0A0A (light) / #F5F5F5 (dark)
Secondary text:       #6B6B6B (light) / #A0A0A0 (dark)
Border/divider:        #E5E5E5 (light) / #2A2A2A (dark)

Accent — Success/Positive/Paid/Active:   #16A34A (green)
Accent — Danger/Debt/Unpaid/Expired:      #DC2626 (red)
Accent — Warning/Pending/Expiring soon:    #D97706 (amber)

Primary action (buttons, active nav item): #0A0A0A (black), text/icon #FFFFFF
```
No other colors. Do not introduce blue, purple, or gradients anywhere.

## Typography
- Font: system default (or a single clean sans-serif like Inter if adding a font package)
- Page title: 24sp, bold
- Section header: 18sp, semi-bold
- Card title / list item title: 15sp, semi-bold
- Body / secondary text: 13sp, regular, secondary text color
- Stat card big number: 22-26sp, bold

## Spacing (8pt grid)
```
xs = 4, sm = 8, md = 16, lg = 24, xl = 32
```
- Card padding: 16
- Space between cards: 12
- Page horizontal padding: 16

## Radii
- Cards: 16
- Buttons: 12
- Pills/badges/chips: 999 (fully rounded)
- Bottom nav: top corners 20 (if floating style) or 0 (if edge-to-edge)

## Shared Widgets (build once in core/widgets, reuse everywhere)

### StatCard
Icon in a soft circular background (tinted with the relevant accent color at ~10%
opacity), title (secondary text), big number (primary text, bold), optional small
caption below (e.g. "0 renewals").

### FilterPill / SegmentedControl
Row of pill buttons. Active = solid black background, white text. Inactive =
transparent/outlined gray border, black text. Used for period filters (Today/Week/
Month...) and status filters.

### BalanceProgressCard
Company logo (circular, 40x40) + name, a % badge (green pill), a horizontal progress
bar (green fill), then two/three data rows: consumed / available to sell / owed (red
if > 0).

### ListRow (for More menu, settings-style navigation)
Leading icon (thin line style, 22x22, primary text color), title text, trailing
chevron-right icon (secondary text color). Divider between rows. Full-width tap target.

### StatusBadge
Small pill: green bg/text for paid/active, amber for partial/pending/expiring, red
for unpaid/expired/blocked. Text 11sp, medium weight.

### EmptyState
Centered: light gray circular icon background, icon, bold short title, secondary
text description, optional CTA button below.

### AppTopBar
Page title (large, bold) on the leading side, dark/light mode toggle (circular icon
button) on the trailing side. No back arrow on main nav pages; sub-pages inside
"More" get a leading back-arrow instead of nothing.

### BottomNavBar
5 items: Home, New Sale (center, visually distinct — filled black circle/pill with a
+ icon, elevated above the bar line), Companies, Customers, More. Active item: black
icon + label. Inactive: gray icon + label.

## Dark Mode
Every color above has a light/dark pair. Toggle is global (stored in local
preferences/Drift), affects the whole app instantly, persists across app restarts.

## Do / Don't
- Do: keep every screen visually consistent with this file, even before all pages exist.
- Do: use the same StatCard/FilterPill/StatusBadge everywhere they logically apply.
- Don't: introduce a new color, shadow style, or corner radius without adding it here first.
- Don't: use default Material blue/purple theme colors anywhere.
