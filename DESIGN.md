<!-- SEED - re-run $impeccable document once there is code to capture the actual tokens and components. -->
---
name: Pagebound
description: A tactile storybook roguelite UI for readable chaos on a living magical page.
---

# Design System: Pagebound

## 1. Overview

**Creative North Star: "The Living Storybook Page"**

Pagebound's interface should feel like useful annotations on a magical page, not like a separate fantasy overlay pasted on top. HUD, draft cards, Page Event prompts, and victory summaries should carry the warmth and tactility of storybook materials while staying compact, fast, and trustworthy during combat.

The design system uses a full palette because Pagecraft has named material identities: Waxlight, Color Bloom, Moonlight, Dreamsap, Clean Page, and Blankness all need distinct roles. The palette must stay disciplined. Color carries gameplay meaning first, atmosphere second, decoration last.

The system rejects school-supply UI, generic fantasy parchment, beige paper clutter, unreadable late-game soup, and card grids that look produced without a design point of view.

**Key Characteristics:**

- Tactile storybook surfaces without parchment clutter.
- Material color as gameplay language.
- Compact HUD hierarchy for fast combat decisions.
- Strong reward clarity in drafts and Page Events.
- Responsive feedback, never decorative choreography.

## 2. Colors

Pagebound uses a full storybook material palette. Exact OKLCH/hex tokens are unresolved until visual implementation.

### Primary

- **Waxlight Gold** ([to be resolved during implementation]): Primary combat accent for Waxlight Comet, warm active states, major pickup/action confirmation, and early Chapter 1 identity.

### Secondary

- **Color Bloom Rose** ([to be resolved during implementation]): Bloom, growth, reward flourish, and celebratory accent. Use for positive burst feedback, not generic button decoration.
- **Moonlight Blue** ([to be resolved during implementation]): Cool guidance, route markers, safe objective indicators, and nighttime/magic states.

### Tertiary

- **Dreamsap Amber** ([to be resolved during implementation]): Sticky/control effects, slowed states, and support feedback.
- **Clean Page Glow** ([to be resolved during implementation]): Cleansing, restored page zones, healing, and clarity cues.
- **Blankness Violet-Black** ([to be resolved during implementation]): Hostile corruption, boss pressure, failed objective consequences, and danger contrast.

### Neutral

- **Warm Paper Surface** ([to be resolved during implementation]): Main readable surface for HUD panels and draft cards.
- **Ink Line** ([to be resolved during implementation]): Primary text, icon strokes, fine borders, and silhouette accents.
- **Soft Fiber Edge** ([to be resolved during implementation]): Dividers, disabled states, and low-emphasis labels.

### Named Rules

**The Material-First Rule.** A color must mean a material, state, reward, or threat before it acts as decoration.

**The No Beige Fog Rule.** Paper warmth is allowed; tan-on-tan UI that lowers contrast is prohibited.

**The Blankness Contrast Rule.** Hostile corruption must remain visually distinct from friendly dark UI surfaces.

## 3. Typography

**Display Font:** Serif display direction ([font family to be chosen at implementation])

**Body Font:** Clean sans direction ([font family to be chosen at implementation])

**Label/Mono Font:** Optional compact label or tabular number face ([font family to be chosen at implementation])

**Character:** Chapter names, victory headings, and rare celebratory text can use a storybook serif voice. Combat HUD, draft descriptions, numbers, timers, and settings need a clean sans with fast legibility.

### Hierarchy

- **Display** ([weight/size to be chosen]): Chapter title, victory heading, and major storybook moment only.
- **Headline** ([weight/size to be chosen]): Draft modal title, Page Event banner, and boss/finale warning.
- **Title** ([weight/size to be chosen]): Draft card name, reward name, loadout label, and panel title.
- **Body** ([weight/size to be chosen]): Draft effect text, objective descriptions, and concise help text. Cap prose at 65-75 characters per line.
- **Label** ([weight/size to be chosen]): Timers, counters, slots, tags, rarity, and compact HUD labels.

### Named Rules

**The HUD Is Not A Storybook Rule.** Use storybook typography for moments, not for dense combat labels.

**The Number Clarity Rule.** Timers, XP, health, damage, and objective counts must win over decorative type.

## 4. Elevation

Seed direction: flat and layered by default, lifted only when interaction state or modal focus needs it. In-game UI should feel like ink, paper, stickers, and raised cutouts, not floating glass.

### Named Rules

**The Tactile Layer Rule.** Depth comes from paper edges, small shadows, ink strokes, and state changes, not from generic card stacks.

**The No Glass Rule.** Glassmorphism is prohibited unless a future screen has a specific magical lens concept and a readability test proves it works.

## 5. Components

No final component tokens exist yet. These component directions guide the first implementation pass.

### HUD

- **Shape:** Compact bands, badges, and anchored strips with restrained corners.
- **Priority:** Player health, XP/level, active Page Event objective, boss warning/health, and offscreen markers must outrank decorative detail.
- **Feedback:** Dog fetch, pickup gains, Candle Spark damage help, and Page Event progress need short, readable confirmation.

### Draft Cards

- **Shape:** Tactile cards, not ornate parchment.
- **Content:** Icon, name, category, current/next level, material/catalyst tags, concise effect text, rarity, and compatibility hints.
- **State:** Focused card must be unmistakable for keyboard/gamepad. Hover-only behavior is forbidden.

### Page Event Prompts

- **Shape:** Objective-first banner or anchored tracker.
- **Content:** Objective name, progress count, timer, distance/edge marker, and reward promise.
- **State:** Failure and success messages must be short and action-focused.

### Damage Numbers

- **Shape:** Pooled, legible, expressive number styles.
- **Priority:** Boss chunks, crits, Page Event objective hits, and major pet/support feedback outrank low-value tick spam.
- **Accessibility:** Full, reduced, boss/crit only, off, scale, and high-contrast modes must remain possible.

### Victory Summary

- **Shape:** Celebratory but scannable. Avoid hero-metric layout.
- **Content:** Time, boss defeated, Page Events completed, favorite weapon/support contribution, highest damage number, and rewards.

## 6. Do's and Don'ts

### Do:

- **Do** keep Page Event progress and timers readable during combat.
- **Do** use material color names consistently: Waxlight, Color Bloom, Moonlight, Dreamsap, Clean Page, Blankness.
- **Do** make reward cards explain gameplay value in one quick read.
- **Do** reserve storybook typography for chapter, victory, and special moment text.
- **Do** design pet/support feedback so the player can tell when the pet helped.
- **Do** use responsive state feedback: short transitions, quick pulses, and clear selection changes.

### Don't:

- **Don't** make the interface look like school supplies, classrooms, homework, pencil cases, rulers, scissors, or lunch trays.
- **Don't** use generic fantasy parchment HUD, ornate frames, scrollwork, or beige paper clutter.
- **Don't** bury critical text in busy paper textures.
- **Don't** use gradient text, glassmorphism as default, side-stripe card accents, or the hero-metric template.
- **Don't** let damage numbers, VFX, pets, event markers, and boss telegraphs compete without priority.
- **Don't** make UI choreography delay the return to play.
