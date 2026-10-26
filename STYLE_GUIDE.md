# BizFlow "Aurora 2.0" UI Style Guide

This guide governs the visual redesign of every BizFlow screen. The goal:
**premium, branded, modern, warm, and effortless** — a POS that feels like a
flagship product, not an admin tool.

## 0. Absolute rules

1. **Presentation only.** Never change business logic, state management,
   data flow, providers, navigation arguments, or public widget APIs other
   files depend on.
2. **Both themes.** Every change must look right in light AND dark mode.
   Test with `Theme.of(context).brightness`. Never hard-code near-white or
   near-black without checking the other theme.
3. **Nothing blocks the operator.** Never add animation that delays a tap,
   hides data the user needs, or slows the POS. Entrance animations are
   ≤ 400ms and always fire on build, not per-frame after animate.
4. **Zero new dependencies.** Use only what exists: `flutter_animate`,
   Material, the core kit (`lib/core/widgets/brand_ui.dart`,
   `modern_widgets.dart`, `premium_ui.dart`, `mini_charts.dart`,
   `responsive_grid.dart`) and tokens (`AppColors`, `AppDecor`,
   `AppTextStyles`, `AppDimensions`).
5. **Compile clean.** Run `flutter analyze` on your files; fix every error
   and warning you introduced.

## 1. Brand palette mapping

Anchor: royal violet `royalStart #8460FF → royalMid #5B5BF7 → royalEnd #4338CA`
(`AppColors.royal*`, `AppDecor.royalGradient`). Money-success is always
mint/teal — never blue. Attention is amber. Destructive is coral/red.

| Section | Tint pair (`AppColors.*Tint`) | Meaning |
|---|---|---|
| Sales / revenue / POS | `posTint` (indigo) | Deep violet = brand power, checkout |
| Money inflow, payouts, profit | `moneyTint` (mint) | Money ≥ 0, success |
| Stock, inventory movement, POs | `stockTint` (blue) | Stock |
| Growth, targets, promos, streaks | `growthTint` (amber) | Attention, goals |
| Customers, loyalty, care | `careTint` (rose-pink) | People |

Use `AppDecor.flowGradient` (teal→blue) for "live money flow" chrome,
`AppDecor.sunsetGradient` for celebration moments (target reached, sale
completed), `AppDecor.auroraBar` for progress bars and active rails.

Semantic colors: `success/warning/error/info` unchanged. Status pills use
`completed/pending/cancelled/refunded/processing` with `BrandPill`.

## 2. Photography system

`AppImages` ships free Unsplash photos. Pair each surface with its image
under a brand wash — never show a raw photo. Wash = gradient-overlay (`AppDecor.photoWash`) or
`AppDecor.photoHero(image: ...)`. Text over photos: `AppColors.onPhoto`,
`onPhotoMuted` (90%), `onPhotoSoft` (70%).

| Image | Use on |
|---|---|
| `AppImages.storeHero` | Dashboard hero band, target cards |
| `AppImages.posPayment` | POS hero, checkout/header moments, sale success |
| `AppImages.analyticsHero` | Reports/analytics hero |
| `AppImages.warehouse` | Inventory, receive stock, PO hero |
| `AppImages.auroraGlow` | Abstract aurora wash (generic hero) |
| `AppImages.purpleAbstract` | Login/lock/splash chrome |
| `AppImages.shoppingCustomers` | Customers, loyalty, credit |
| `AppImages.accounting` | Expenses, money tasks |
| `AppImages.teamStaff` | Staff management, shifts |
| `AppImages.retailShelves` | Products lists/extras |

Rules: photos sit behind ≥75% brand wash (`photoWash()` / dark gradient),
image opacity ≤ 0.5 visible, rounded 24–28 corners, `ClipRRect`.
`BrandEmptyState(image: ...)` supports photo empty states — pair
iconically (products list → retailShelves, customers → shoppingCustomers).

## 3. Layout rhythm

- Page max-width: `AppDimensions.contentMaxWidth` via `PageBody`.
- Splash padding: `20–24` horizontal.
- Cards: radius `22–26` (`BrandCard`, radius param). Sticky bars & auth
  surfaces: radius `14–18`. Chips/pills: `999`.
- Spacing scale: 4 / 8 / 12 / 16 / 20 / 28.
- Section order top→bottom on every tab page:
  1. **PageHero** (or branded header) — image-backed, one eyebrow, title ≤ 2 lines, ≤ 2 actions.
  2. **Row of ≤ 3 KPI/stat cards** (`MetricCard`) — premium numbers only.
  3. **Primary work area** (list/grid/board).
  4. **Supporting cards** (insights, activity).
- Sub-pages (forms, details): `BrandPageHeader` + `BrandSubPageBody` +
  `BrandFormSection` + `BrandStickyBar`.

## 4. Motion language (flutter_animate)

One protocol, reuse everywhere:

- **Entrance:** content children stagger —
  `delay: 60ms * i, duration: 350–420ms, curve: Curves.easeOutCubic` with
  `fadeIn()` + `.moveY(begin: 14, end: 0, curve: Curves.easeOutCubic)`.
  Lists animate only the first screenful (~12 items); heavy grids skip moves.
- **Counters:** `CountUpText` (keeps existing semantics) for hero numbers.
- **Hover (desktop):** lift −2..−3px + border bloom + accent glow, 200ms,
  `Curves.easeOutCubic` — like `BrandCard` already does.
- **Press:** scale 0.97 on primary buttons, 120ms.
- **State change:** `AnimatedSwitcher` 250ms for list ↔ empty swaps,
  `AnimatedContainer` 220ms for chips/secrets.
- **Celebration (sale success / target hit):** scale-bounce
  `Curves.elasticOut` ×1 entry + `sunsetGradient` glow, once only.
- Forbidden: spinning loaders on primary work surfaces, looping pulsing on
  dashboard KPIs (one-time pulse only), delays > 500ms, parallax in lists.

## 5. Component conventions

- Buttons: FilledButton for THE single primary action (gradient
  `AppDecor.royalGradient` allowed via Container+ InkWell); outlined for
  secondary; ghost icon-button for tertiary. One primary per view.
- Search: `BrandSearchField` + ⌘K hint when available; debounce untouched.
- KPI numbers: `AppTextStyles.priceHero/numericLarge` (Sora, tabular).
  Labels: `kpiLabel/badge` uppercase-tracked.
- Statuses: `BrandPill` with mapped color; never raw `Text`.
- Money: mint family; revenue hero numbers get `flowGradient` text? No —
  keep text solid; reserve gradients for shapes (icons chips, bars, orbs).
- Icon tiles: 40–44px squircle, `BrandIconBadge`/gradient tile with soft
  `AppDecor.glow(color)` shadow matching the section tint.
- Top bars/heroes stay ≤ 200px tall on mobile; hero shows photo on ≥ 720px
  width, gradient-only wash on narrow screens if layout is tight.

## 6. UX micro-gestures to add

- Tab pages: keep existing data; add hero footer strips of context
  ("Today vs yesterday" delta chips, last-sync pill).
- Lists: sticky group headers where grouped; first-tile shortcut chips
  (e.g., 'Filter: Low stock') rendered as horizontal chip row if absent.
- Forms: field-level success checkmark when valid; sticky bar with total
  context (e.g., "Items: 3 · Total: $120") and the primary save CTA.
- Details pages: hero stat row + timeline of events where timeline exists.

## 7. Do / Don't

- Do add breathing room, consistent tint usage, staggering, photo heroes.
- Do keep contrast ≥ 4.5:1 for body text on washes.
- Don't invent new colors; extend through existing tint pairs only.
- Don't replace Sora/Manrope fonts or uppercase EVERYTHING; eyebrows and
  badges only.
- Don't remove any existing feature, dialog, keyboard shortcut, or snippet.

## 8. Verify

After edits: `flutter analyze <your folders>`; then `flutter analyze lib` once.
Fix anything you caused. Report what you changed per file.
