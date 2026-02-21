# Minimal Elegant UI Style (POS Final)

## 1. Design Intent
Use a minimal + elegant visual language: clean layouts, soft depth, restrained color accents, and strong readability.

## 2. Core Tokens
- bg: #F8FAFC
- bgSoft: #F1F5F9
- surface: #FFFFFF
- primaryText: #0F172A
- mutedText: #6B7280
- accent: #0F4C81
- outline: #E5E7EB

## 3. Spacing and Shape
- Screen horizontal padding: 20
- Card padding: 24
- Section gaps: 8 / 12 / 16
- Button height: 50-52
- Radius scale: 12 (small), 14 (buttons), 20-22 (cards)

## 4. Elevation
Use one subtle shadow level for cards only:
- color: #00000014
- blur: 28
- offsetY: 10

Avoid stacked or heavy shadows.

## 5. Typography Rules
- Headline: high-contrast, medium/semibold (prefer 500, max 600)
- Body/supporting text: muted color, regular weight (400)
- Keep line lengths short; prioritize scanability
- Avoid forcing heavy `FontWeight.w700+` in screen widgets; rely on `AppTheme` text styles first

## 6. Button System
- Primary button:
  - Fill: accent
  - Text/icon: white
  - Radius: 14
- Secondary button:
  - Outline: outline
  - Background: very light tinted neutral
  - Text/icon: primaryText
- Text button:
  - Color: accent
  - No visual clutter

## 7. Layout Pattern (Apply to Other Screens)
- Use a light gradient or flat neutral background (bgSoft -> bg)
- Center content in a max-width container (440-560 depending on screen)
- Place major actions at bottom of content stack
- Keep each screen to one clear primary action

## 8. Motion and Interaction
- Motion should be subtle and functional
- Durations: 200-300ms
- Use loading state in buttons during async actions
- Provide error feedback with floating snackbars

## 9. Accessibility Baseline
- Keep text/background contrast >= WCAG AA
- Ensure touch targets >= 44x44
- Preserve semantic labels for interactive controls
- Maintain visible focus and pressed states

## 10. Implementation Checklist for Each Screen
- Replace noisy backgrounds with neutral/surface layers
- Normalize paddings/radii to token values
- Limit palette usage to neutrals + single accent
- Ensure one visual hierarchy: title -> support text -> content -> actions
- Add empty/loading/error states where async data exists
