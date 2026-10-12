# BizFlow — v1.4.0 Release-Readiness & Deferred Features

## Scope
Two tracks:
1. **Release-readiness** (make 1.3.0 genuinely shippable): migration tests,
   end-to-end correctness, backup integrity, packaging.
2. **Deferred high-value features** (implement end-to-end, not stub screens):
   returns/refunds, CSV import, cashier shifts, audit log, receipt branding,
   suppliers/purchase orders, customer credit, onboarding/data portability.

Every feature must integrate with inventory, payment, sales history and
reporting — not just add a button.

---

## Track A — Release readiness

### A1. Migration correctness (HIGH — audit finding)
- [ ] Add `test/migration_test.dart` proving a populated v5 DB upgrades to v6
      with lifetime points preserved and `points_balance` backfilled correctly.
- [ ] Prove v4 → v6 and v3 → v6 chains run cleanly with existing data.

### A2. Backup integrity (HIGH — CONFIRMED DEFECT)
- [ ] Backups record `databaseSchemaVersion: 4` while the schema is v6 → the
      validator rejects valid backups and the metadata lies.
- [ ] Loyalty business settings are NOT exported/restored → restoring a backup
      silently resets the loyalty program configuration.
- [ ] Fix: export/restore loyalty settings; accept a range of supported schema
      versions; add a backup round-trip test asserting loyalty values survive.

### A3. End-to-end workflow tests
- [ ] Sale → redeem points → cancel → reporting invariants.
- [ ] Edge cases: insufficient points, discount + loyalty combined, rounding,
      customer owes less than their points are worth.

### A4. Notification behaviour
- [ ] Duplicate events, read state, 50-item bound (covered), dismissal safety.

### A5. Packaging
- [ ] Version, changelog, README/backup docs, license, no stray dev files.

---

## Track B — Deferred & new features (end-to-end)

### B1. Sales returns & refunds (HIGH)
Partial/full returns with quantities, refund method, stock decision
(restock vs write-off), correct reporting (net revenue, returns impact).
- Table `sale_returns` (+ items), repository, UI on sale details, stock
  movements of type `RETURN`, and report integration.

### B2. Product CSV import (HIGH)
Column mapping, validation, duplicate detection, preview, import results.

### B3. Cashier shifts & cash reconciliation (HIGH for staffed shops)
Opening float, cash in/out movements, expected vs counted cash, close report
with discrepancy + reason.

### B4. Audit log (HIGH for accountability)
Actor, action, timestamp, affected record, before/after values. Written by
stock changes, cancellations, refunds, loyalty adjustments.

### B5. Receipt branding (MEDIUM-HIGH)
Business logo text, contact details, configurable header/footer, print layout.

### B6. Suppliers & purchase orders (strong candidate)
Supplier records, POs, received quantities, purchase costs, stock updates —
connects reorder suggestions → order → receive.

### B7. Customer credit & payments (careful financial logic)
Credit sales, outstanding balance, payments received, statement history.

### B8. Onboarding & data portability
Guided first-run, sample data option, CSV preview, export validation,
backup verification, "where is my data stored" explanation.

---

## Verification
- `flutter analyze` clean.
- Full `flutter test` green (incl. new migration, backup, refund, shift, audit,
  import tests).
- `flutter build web --release` succeeds.
- Version → 1.4.0; CHANGELOG + docs updated.

## Constraints
- Offline-first; no online sync.
- Safe migrations; never assume a fresh database.
- Reuse existing component library.
- Each new business feature gets targeted tests.
