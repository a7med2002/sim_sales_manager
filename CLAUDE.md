# CLAUDE.md — Project Instructions

## Project
SIM/eSIM Sales Manager — a Flutter app for a single seller who buys eSIM bundles
wholesale from supplier companies and resells them to customers, tracking profit,
customer debts, and expiry dates.

**Always read these files at the start of a session, before doing anything else:**
1. `design/APP_CONTEXT.md` — full business logic, entities, and page-by-page spec
2. `design/DESIGN_SYSTEM.md` — colors, typography, spacing, shared widget rules
3. `PROGRESS.md` — what's been built so far, what's next

## Stack
- Flutter (latest stable)
- State management: **Cubit by default** (flutter_bloc package). Only use full
  **Bloc** (event-based) for genuinely event-driven logic — e.g. the offline sync
  engine and connectivity listener. Don't default to Bloc for simple CRUD screens.
- Backend: Supabase (Postgres + Auth + Storage)
- Local database (offline-first source of truth): **Drift** (SQLite-based) — chosen
  because the data is relational (Customer → many Lines, Company → many Shipments)
- Connectivity detection: `connectivity_plus`
- Dependency injection: `get_it`
- Immutable state/models: `equatable` (or freezed if introduced later — confirm
  before adding new codegen dependencies)

## Offline-First Architecture (critical — do not skip)
- The **local Drift database is the source of truth** for all reads/writes in the UI.
  The UI never waits on a network call to show or save data.
- Every write (create/update/delete) happens to the local DB **immediately**, tagged
  with a `synced = false` flag and an `updated_at` timestamp.
- A background **SyncCubit/SyncBloc** listens to connectivity changes. When online:
  it pushes all `synced = false` records to Supabase, then pulls remote changes down
  into the local DB, then marks pushed records `synced = true`.
- The UI shows a subtle sync-status indicator (e.g. small icon in the app bar) —
  never a blocking spinner for sync itself.
- Conflict resolution: last-write-wins based on `updated_at` (keep it simple — do not
  over-engineer conflict resolution unless explicitly asked to).

## Folder Structure (Clean Architecture)
```
lib/
  core/
    theme/            → colors.dart, text_styles.dart, spacing.dart, radii.dart
    widgets/           → shared widgets used across features (stat_card, filter_pill,
                          app_bar, bottom_nav, empty_state, etc.)
    constants/          → currency symbol, enums, app-wide constants
    database/           → Drift database setup, tables, DAOs
    sync/                → connectivity listener + sync engine (Bloc)
    di/                   → get_it service locator setup
  features/
    <feature_name>/
      data/               → repositories (local Drift + remote Supabase), models
      domain/             → entities, use cases (if needed — keep thin, don't over-abstract)
      presentation/
        cubit/ (or bloc/)
        pages/
        widgets/
```

## Rules
- **No hardcoded colors, font sizes, or spacing values inside feature pages** — always
  reference `lib/core/theme/`. If a value is missing from the theme, add it there first.
- Reuse shared widgets from `lib/core/widgets/` (stat cards, filter pills, list rows,
  empty states) instead of rebuilding similar UI per page.
- Currency symbol (₪) is a constant in `lib/core/constants/`, never a hardcoded string.
- Before building any page, check `design/screenshots/` for the matching reference
  image if one exists, and match its layout/spacing closely — but always follow
  `design/DESIGN_SYSTEM.md` for exact color/type values, not pixel-guessing from the image.
- Keep each feature self-contained (data/domain/presentation) — don't create cross-feature
  imports except through core/.
- After completing any page or meaningful chunk of work, **update `PROGRESS.md`**
  with what was done and what's next. Do this without being asked.
- Never run `flutter pub add` or edit pubspec.yaml to add ANY new package (chart
  library, animation package, image picker, etc.) without stopping first and telling
  the user exactly which package and why it's needed, and waiting for confirmation
  before installing it — even for small/common packages.
- Prefer small, focused commits/changes over large sweeping rewrites.

## Definition of Done (per page)
A page/feature is only "done" when:
1. UI matches the design system and reference screenshot (if any)
2. Cubit/Bloc wired to local Drift DB (works fully offline)
3. Empty states handled (no broken UI when data is empty)
4. Sync marking (`synced = false` on write) implemented for any new data written
5. `PROGRESS.md` updated
