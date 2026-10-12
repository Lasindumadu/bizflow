# BizFlow — Modernization & Feature Plan (v1.2.0)

## Goal
Elevate BizFlow into a realistic, advanced, marketplace-ready (Codester-class) POS +
inventory system for mobile and web: richer design system, modern UI components,
animated states, and meaningful missing features — without breaking the existing
clean architecture or the offline-first Drift data layer.

## Baseline (verified)
- `flutter analyze` → **No issues found** (clean).
- Architecture: `lib/core` (theme, widgets, utils) · `lib/data` (drift db, repos,
  services) · `lib/features/*` (dashboard, products, pos, sales, customers,
  inventory, expenses, reports, settings, more) · `lib/models`.
- Existing design tokens: `app_colors.dart`, `app_text_styles.dart`,
  `app_decor.dart`, `app_dimensions.dart`, `premium_ui.dart`, `mini_charts.dart`.
- Data tables: products, categories, sales, sale_items, customers, expenses,
  stock_movements, business_settings.

## Workstreams

### 1. Design system upgrades (core)
- **Colors**: extend palette with surface elevation ramp, glass tokens, overlay
  scrims, semantic soft containers, and a curated accent set; add
  `AppColors.gradientFor(...)` helpers.
- **Typography**: refine hierarchy, add `numeric`/`mono` styles, tabular figures
  intent, and consistent letter-spacing. Keep backward-compatible aliases.
- **Decor**: add `AppDecor` helpers — `aestheticShadow`, `neumorphicLight`,
  `ringDecoration`, gradient text helpers, and animated shimmer builders.
- **New component library** (`premium_ui.dart` + new `modern_widgets.dart`):
  - `GradientButton`, `SoftButton`, `IconPill`
  - `GlassCard`, `ElevatedSurface`, `HoverLiftCard`
  - `AnimatedCounter` (number roll-up)
  - `ShimmerBox`, `SkeletonList`, `AppLoadingState`
  - `AppEmptyState` (illustration + CTA), `AppErrorState`
  - `StatusBadge`, `TrendPill`, `ProgressRing`
  - `SectionDivider`, `StatTile`, `KpiRow`

### 2. Dashboard (data-viz)
- Replace single bar chart with a richer analytics block (bar + sparkline +
  distribution rows), animated counters, KPI deltas, and a "peak day" insight.
- Add quick-action grid + notifications entry point.

### 3. POS modernization
- Modern cart panel: sticky summary, per-line animations, running total.
- Redesigned checkout sheet: payment method chips, cash quick-tender buttons,
  change highlight, customer + loyalty preview.
- Category filter chips + product tile polish + hold/resume polish.

### 4. Missing features
- **Loyalty**: points per customer, earn/redeem at checkout, tier badges.
  (New table + repo + settings for earn rate.)
- **Notifications center**: in-app feed (low stock, big sales, backups) with
  unread badge in the shell.
- **Advanced reports**: date-range aware analytics, payment-method split,
  customer insights, CSV export buttons.

### 5. Screens polish
- Products, Customers, Inventory, Expenses, Sales, Settings, More — consistent
  headers, empty/loading/error states, and modern cards.

### 6. Navigation & responsive
- Refined shell: gradient sidebar with active pill, animated selection,
  responsive rail for tablet, notification badge, web-friendly content widths.

### 7. Verification
- `flutter analyze` clean.
- `flutter test` passing (update/extend tests for new repos/features).
- Manual smoke of key flows.

## Constraints
- No new heavy dependencies unless essential (keep it publisher-friendly).
- Preserve offline-first behavior and existing public APIs where possible.
- Smallest effective change set; no unrelated rewrites.

## Deliverables
- Upgraded theme + component library.
- Modern dashboard, POS, and polished feature screens.
- Loyalty, notifications, advanced reports.
- Updated tests + `CHANGELOG`/version bump to 1.2.0.
