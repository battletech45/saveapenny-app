# Design System — SaveAPenny Mobile

The visual contract for the app. Like `API_CONTRACT.md` pins the backend, this
pins the UI: every screen pulls from these tokens, nothing is improvised. Tokens
live in code at `lib/core/theme/tokens.dart`; the theme is assembled in
`lib/core/theme/app_theme.dart`. **Never inline a raw color, padding, radius, or
font size in a widget** — reference a token.

## Principles

1. **Calm and precise.** A finance app earns trust by being quiet. Neutral
   surfaces, generous space, one confident accent. No gradients-as-decoration,
   no busy color.
2. **The brand accent is not a money color.** Indigo-blue is for interaction
   (buttons, links, focus, selected states). Green and red mean *only* gain and
   loss. Never tint a button with the income color or vice versa.
3. **Money is never color alone.** Positive/negative amounts always carry a sign
   (`+`/`−`) and consistent right-alignment, so meaning survives for color-blind
   users and in greyscale.
4. **Tabular numerals everywhere money appears.** Figures must align in columns.
5. **Borders before shadows.** Prefer a 1px hairline to separate surfaces; use
   soft elevation only for things that genuinely float (sheets, dialogs, FAB).
6. **Dark mode is first-class**, generated from the same semantic tokens.

## Color

Semantic roles, not raw swatches. Use the role; the theme resolves light/dark.

### Brand / interaction

| Role | Light | Dark | Use |
|---|---|---|---|
| `primary` | `#3B5BC0` | `#9FB1F5` | Primary buttons, links, focus, active nav |
| `onPrimary` | `#FFFFFF` | `#11205C` | Text/icon on primary |
| `primaryContainer` | `#DDE3FB` | `#26346F` | Tonal buttons, selected chips |
| `onPrimaryContainer` | `#0C1A52` | `#DDE3FB` | Text on container |

### Neutrals

| Role | Light | Dark | Use |
|---|---|---|---|
| `background` | `#FBFBFC` | `#0E1013` | App canvas (slightly off-pure for less glare) |
| `surface` | `#FFFFFF` | `#16191D` | Cards, sheets, list backgrounds |
| `surfaceSubtle` | `#F1F3F5` | `#1E2228` | Inset fills, skeletons, pressed states |
| `border` | `#E4E7EB` | `#2A2F36` | Hairlines, dividers, input outlines |
| `textPrimary` | `#1A1D21` | `#F2F4F6` | Headlines, amounts (near-black, not pure) |
| `textSecondary` | `#5B6470` | `#A8B0BA` | Supporting copy, labels |
| `textTertiary` | `#8A929E` | `#6E7782` | Meta, timestamps, disabled hints |

### Financial semantics (the important set)

| Role | Light | Dark | Use |
|---|---|---|---|
| `income` | `#1F8A5B` | `#4FC78E` | Positive amounts, gains, credits |
| `incomeSurface` | `#E5F4EC` | `#142A20` | Subtle income background (chips, badges) |
| `expense` | `#C04A3F` | `#EC8278` | Negative amounts, losses, debits |
| `expenseSurface` | `#FAE8E5` | `#33211F` | Subtle expense background |
| `warning` | `#B07A12` | `#E0B65C` | Over-budget, approaching limit |
| `warningSurface` | `#FBF1D8` | `#302813` | Caution backgrounds |
| `info` | `#2E73A8` | `#7FB6DD` | Neutral notices, tips |

**Pairing rule:** income/expense text on its own `*Surface` meets WCAG AA. On a
white card, the base color meets AA for ≥16px medium text. Don't put `income`
text smaller than 13px without bumping to bold.

## Typography

Default to the platform UI font (SF Pro on iOS, Roboto on Android) — fast, free,
native-feeling. Inter is an approved optional upgrade (add `google_fonts` and
swap the `fontFamily` in `app_theme.dart` only). The scale is fixed regardless of
font.

| Token | Size/Line | Weight | Use |
|---|---|---|---|
| `displayMoney` | 34 / 40 | 600, **tabular** | Hero balance, big totals |
| `headline` | 24 / 30 | 600 | Screen titles |
| `title` | 18 / 24 | 600 | Section headers, card titles |
| `bodyLarge` | 16 / 24 | 400 | Primary reading text |
| `body` | 14 / 20 | 400 | Default UI text |
| `label` | 12 / 16 | 500 | Captions, meta, chips |
| `money` | inherits | 600, **tabular** | Any inline amount in a row |

`money` and `displayMoney` enable `FontFeature.tabularFigures()`. Always
right-align amounts in lists.

## Spacing — 4pt grid

`xs 4 · sm 8 · md 12 · lg 16 · xl 20 · xxl 24 · xxxl 32 · huge 40 · giant 48`

Screen edge padding: `lg (16)`. Card padding: `lg (16)`. Gap between list rows:
`0` (use a hairline divider). Section spacing: `xxl (24)`.

## Radius

`sm 8 · md 12 · lg 16 · xl 24 · pill 999`

Buttons & inputs: `md`. Cards & sheets: `lg`. Chips & avatars: `pill`.

## Elevation

| Level | Use | Treatment |
|---|---|---|
| 0 | Cards, list surfaces | **No shadow** — 1px `border` hairline |
| 1 | Raised card, menu | Soft shadow, y2 blur8 @ 6% |
| 2 | Sheets, dialogs, FAB | Soft shadow, y8 blur24 @ 10% |

## Motion

`fast 150ms · base 200ms · slow 300ms`, standard easing
(`Curves.easeInOutCubic`). Money value changes may count up over `slow`;
everything else is `fast`/`base`. No bouncy/playful curves — this is a finance
app.

## Component conventions

- **Buttons:** primary = filled `primary`; secondary = tonal `primaryContainer`;
  tertiary = text. Height 48, radius `md`, `title`-weight label. Full-width on
  forms.
- **Transaction row:** leading category icon in a `pill` tinted surface · title
  (`body`, `textPrimary`) + subtitle (`label`, `textSecondary`) · trailing amount
  (`money`, `income`/`expense`, signed, right-aligned). Row height ≥ 56, hairline
  divider between rows.
- **Inputs:** outlined, `border` at rest, `primary` 1.5px on focus, `expense` on
  error with a `label` message beneath. Radius `md`.
- **Cards:** `surface`, radius `lg`, 1px `border`, padding `lg`, no shadow.
- **Amount display:** always format via `intl` `NumberFormat.currency` with the
  account's ISO-4217 code; sign prefix `+`/`−`; color by semantic role.
- **States:** every list/async view defines loading (skeleton on `surfaceSubtle`),
  empty (icon + one line + optional action), and error (maps `Failure` →
  localized copy). No blank screens.
- **Touch targets ≥ 48×48.**

## Accessibility checklist (enforced in review)

- [ ] Amount meaning works without color (sign + alignment)
- [ ] Text contrast ≥ AA on its background
- [ ] Hit targets ≥ 48
- [ ] Supports text scaling to 1.3× without clipping
- [ ] Dark mode verified, not just light

## Do / Don't

- ✅ `Theme.of(context).extension<FinanceColors>()!.income` for an amount color
- ✅ `AppSpacing.lg`, `AppRadius.md`, `context.textTheme.money`
- ❌ `Color(0xFF1F8A5B)` inline · ❌ `EdgeInsets.all(16)` with a magic number
- ❌ brand `primary` on a money amount · ❌ red/green with no sign
- ❌ heavy `BoxShadow` on a plain card