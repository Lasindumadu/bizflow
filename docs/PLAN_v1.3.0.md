# BizFlow — Business Correctness & Value Plan (v1.3.0)

## Context
This plan follows the recommended 5-phase roadmap. It is driven by an **audit of
the actual source**, not assumptions. Each phase is completed and verified before
the next.

---

## Phase 1 — Source & feature audit (COMPLETE)

### Verified as already implemented
- Barcode: lookup, duplicate validation (add + edit), scan-to-add, feedback.
- POS: hold/resume sale, discount (amount/percent), partial payment, change due,
  customer selection, stock validation.
- Sales: cancellation with stock restoration + `REFUND` stock movement, history
  retained, duplicate-cancel guards, validation errors.
- Inventory: stock adjustments with notes, stock movement history.
- Loyalty: tiers computed from points; earn on checkout.
- Tests: **31 passing** — 8 loyalty, 7 sale-cancel, product/barcode, theme.

### Verified defects / risks
1. **Loyalty lifetime vs redeemable confusion (CONFIRMED BUG).**
   `customers.loyalty_points` is the single source for both *tier* and
   *redeemable balance*. `LoyaltyRepository.adjustPoints` can subtract, so a
   future redemption would **demote the customer's tier**. Must split into
   `lifetime_points` (monotonic, drives tier) and `points_balance` (spendable).
2. **Notification behavior has no tests.** Stated coverage does not cover it.
3. **No loyalty redemption flow** — points can only be earned, never spent.
4. **Reports** lack date-range comparison, margin by product/category, and
   returns/cancellation impact.
5. **Shell is 2-mode only** (`maxWidth < 700` → mobile, else fixed 248px sidebar).
   No tablet rail; the 5 mobile destinations waste tablet/desktop space.

### Verified gaps (not implemented at all)
- Inventory intelligence: reorder suggestions, dead stock, stock valuation report.
- Sales returns/refunds as a first-class flow (distinct from full cancel).
- Cashier shift management (opening/closing cash, discrepancy).
- Supplier & purchase-order management.
- Product CSV import.
- Audit log for important actions.
- Receipt branding settings.

---

## Phase 2 — Business correctness (HIGH priority)
1. Split loyalty points: add `lifetime_points` + `points_balance` (schema v6,
   migration backfills lifetime = existing points, balance = existing points).
   Tier derives from `lifetime_points` only. Add regression tests proving
   redemption does not demote tier.
2. Add notification store tests (unread count, mark read, mark-all, bounded).
3. Add loyalty redemption tests (cannot redeem more than balance).
4. Validate sale totals invariants with tests.

## Phase 3 — High-value workflows (HIGH priority)
1. **Loyalty redemption at checkout** — redeem points up to a limit; creates a
   negative-points adjustment that reduces `points_balance` only.
2. **Inventory intelligence** — reorder suggestions (sales velocity vs stock),
   dead stock list, stock valuation report; surfaced on Inventory + Reports.
3. **Sales returns/refunds** — partial refund flow touching sale, payment,
   stock (+`RETURN` movement) and reporting.
4. **Analytics** — date-range comparison (today/7d/30d/custom), margin by
   product & category, payment reconciliation (cash vs other), returns impact.
5. **Product CSV import** — onboarding accelerator with validation + preview.
6. **Cashier shift** — open/close shift, opening/closing cash, discrepancy.
7. **Audit log** — record stock changes, cancellations, refunds, loyalty
   adjustments; viewable list.
8. **Receipt branding** — receipt footer/header + business logo text settings.

## Phase 4 — Visual consistency & responsive navigation (POLISH + REQUESTED)
1. **Responsive shell (explicit user request):**
   - Phone (<600): bottom `NavigationBar` (Home, Products, POS, Sales, More).
   - Tablet (600–1024): `NavigationRail` with **expanded** destinations
     (Dashboard, Products, POS, Sales, Customers, Inventory, Expenses, Reports,
     More/Notifications) — uses the extra space.
   - Desktop (>1024): full sidebar with all destinations + section grouping.
2. Apply existing `modern_widgets.dart` / `premium_ui.dart` for consistent
   headers, empty/loading/error states, and status badges.
3. Dark-mode audit of badges, borders, charts, dialogs, disabled controls.

## Phase 5 — Release verification
- `flutter analyze` clean.
- Full `flutter test` suite green (loyalty correctness, notifications, refunds).
- Update CHANGELOG + version to 1.3.0.

---

## Constraints
- Offline-first; no online sync (separate project).
- Reuse existing component library; no new libraries.
- Smallest correct change set; migrations must be safe and reversible in spirit.
- Every new business feature gets a targeted test.
