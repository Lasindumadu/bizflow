# BizFlow Modernization — TODO

Status legend: [ ] todo · [~] in progress · [x] done

## Foundation
- [x] Extend color palette (surface ramp, glass, accents, semantic containers)
- [x] Refine typography system + numeric/mono styles
- [x] Extend `AppDecor` (shadows, ring, gradient text, shimmer helper)
- [x] Add modern component library (`modern_widgets.dart`)
- [x] Extend `premium_ui.dart` (GradientPageHeader, PremiumKpiTile, PremiumListTile)

## Features
- [x] Loyalty points (table + repo + settings + checkout integration)
- [x] Notifications center (model + service + UI + shell badge)
- [x] Advanced reports (payment split, customer insights)

## Screens
- [x] Dashboard: gradient KPI cards, trend pills, quick-actions grid
- [x] POS: customer loyalty display + checkout loyalty preview
- [x] Products / Customers / Inventory / Expenses / Sales deeper polish (optional)
- [x] Settings: loyalty config section
- [x] More: notifications entry with unread badge

## Navigation & Responsive
- [x] Shell: notification bell (sidebar + mobile floating bell)

## Verification
- [x] `flutter analyze` clean (0 issues)
- [x] `flutter test` passing (31 tests)
- [x] Version bump (1.2.0+2) + changelog

## Notes / Follow-ups
- Products/Customers/Inventory/Expenses/Sales already had modern headers and
  cards; deeper per-screen polish (advanced filters, bulk actions) is optional.
- Loyalty redemption at checkout could become a full "spend points" flow
  (currently points are earned and displayed).

---

# v1.3.0 — Business Correctness & Value

Plan: `docs/PLAN_v1.3.0.md`

## Phase 1 — Audit
- [x] Audit barcode, POS, sales, inventory, loyalty, tests against real source
- [x] Identify gaps (redemption, inventory intelligence, refunds, analytics,
      import, shift, audit log, receipt branding, responsive shell)

## Phase 2 — Business correctness
- [x] Split loyalty points: `lifetime_points` (tier) + `points_balance` (spendable), schema v6
- [x] Loyalty redemption does not demote tier (9 regression tests)
- [x] Notification store tests (unread, mark read, mark-all, bounded)
- [x] Redemption validation tests (cannot exceed balance)

## Phase 3 — High-value workflows
- [x] Loyalty redemption at checkout (with limit)
- [x] Inventory intelligence: reorder suggestions, dead stock, stock valuation
- [x] Sales returns/refunds flow (stock + payment + reporting)
- [x] Analytics: date-range comparison, margin by product/category, payment reconciliation
- [x] Product CSV import
- [x] Cashier shift management (open/close, discrepancy)
- [x] Audit log (stock, cancel, refund, loyalty)
- [x] Receipt branding settings

## Phase 4 — Visual consistency & responsive navigation
- [x] Responsive shell: phone bottom nav / tablet NavigationRail (expanded) / desktop sidebar
- [x] Dark-mode fix for report chart progress backgrounds
- [ ] Deeper per-screen polish (optional)

## Phase 5 — Release verification
- [x] `flutter analyze` clean (0 issues)
- [x] Full `flutter test` green — 60 tests
- [x] `flutter build web --release` succeeds
- [x] CHANGELOG + version bump to 1.3.0

---

# v1.4.0 — Release-Readiness & Deferred Features

Plan: `docs/PLAN_v1.4.0.md`

## Track A — Release readiness
- [x] A1. Migration test: populated v5 → v9 preserves lifetime, backfills balance
- [x] A1. Migration chains with existing data (products/settings survive)
- [x] A2. Fix backup schema-version metadata + accept supported range
- [x] A2. Export/restore loyalty + receipt settings
- [x] A2. Backup round-trip test (loyalty values survive)
- [x] A2. Fixed restore dropping customer tier (real bug)
- [x] A3. Edge cases: insufficient points, discount+loyalty, rounding
- [x] A4. Notification: duplicates, read state, dismissal safety
- [x] A5. Packaging: removed stray dev files; docs updated

## Track B — Deferred & new features
- [x] B1. Sales returns & refunds (table + repo + UI + stock + reports) + 11 tests
- [x] B2. Product CSV import (mapping, validation, dedupe, preview, results) + 11 tests
- [x] B3. Cashier shifts & cash reconciliation (float, movements, close report) + 10 tests
- [x] B4. Audit log (actor, action, time, record) wired into cancel/refund/shift
- [x] B5. Receipt branding (header/footer, contact, note)
- [x] B6. Suppliers & purchase orders
- [x] B7. Customer credit & payments
- [x] B8. Onboarding & data portability (docs + CSV preview + backup verify)

## Verification
- [x] `flutter analyze` clean
- [x] Full `flutter test` green — 115 tests
- [x] `flutter build web --release` succeeds
- [x] Version 1.4.0 + CHANGELOG


---

# v1.5.0 — Polish, Reliability & Low-Stock Alerts

## Completed
- [x] Code-quality sweep: all 21 `flutter analyze` findings resolved (0 issues)
- [x] Low-stock alerts: sale crossing the threshold pushes an in-app
      notification ("Low stock" / "Out of stock") — fires once per crossing
- [x] `SaleRepository(onLowStock:)` callback + POS wiring
- [x] Tests: alert crossing/above/once-only/no-callback + sale→cancel
      stock-restore invariant (5 new tests)
- [x] `flutter analyze` 0 issues · `flutter test` 120 green ·
      `flutter build web --release` succeeds
- [x] Version 1.5.0+5 + CHANGELOG entry
