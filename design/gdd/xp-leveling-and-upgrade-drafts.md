# XP, Leveling, and Upgrade Drafts

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Power Fantasy First

## Overview

`XP, Leveling, and Upgrade Drafts` defines run XP, Color Mote pickup flow, level thresholds, draft generation, exactly 3 choice presentation, draft fallback rules, and reward selection handoff. It owns temporary run progression. It does not own permanent character mastery, item/weapon behavior, Page Event objectives, or UI art/layout beyond data needs.

## Player Fantasy

Every level-up should feel like a sharp, readable power decision. The player should see three strong choices, understand build direction, and return quickly to action with more color and damage.

## Detailed Design

### Core Rules

1. Run XP resets every run.
2. Enemies, elites, Page Events, destructibles, boss phases, and objectives may drop XP called Color Motes.
3. Filling XP threshold increments run level and opens a 3-choice upgrade draft.
4. Every normal upgrade draft shows exactly 3 choices.
5. Draft categories include new weapon, new passive item, +1 weapon level, +1 passive item level, evolution card, heal, pickup magnet, temporary super attack, Pagecraft modifier, and pet-synergy reward.
6. New weapons are weighted strongly until player owns at least 3 weapons.
7. New weapon choices are blocked when 5 weapon slots are full.
8. New passive item choices are blocked when 5 passive slots are full.
9. Owned weapons below 10 and owned passives below 5 can appear as upgrade choices.
10. If normal eligibility produces fewer than 3 choices, approved fallback choices fill the draft.
11. Page Event, elite, chest, and boss reward drafts can use stronger pools but still use 3 choices unless a later GDD explicitly overrides.
12. Draft UI may pause or slow combat; this system owns draft state, not modal layout.
13. One-stat weapon range cards can appear for owned weapons and must not also change damage, count, cooldown, or weapon level.
14. Draft card rarity must be visible through simple rarity-colored borders.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `CollectingXP` | Player collects Color Motes toward next level. | `LevelReady`, `RunEnded` |
| `LevelReady` | Threshold reached; draft can be generated. | `DraftOpen` |
| `DraftOpen` | Three choices are presented. | `DraftSelected`, `DraftCancelledByRunEnd` |
| `DraftSelected` | Choice is applied to weapon/item/evolution/etc. | `CollectingXP` |
| `DraftCancelledByRunEnd` | Death/victory interrupts draft. | `RunEnded` |
| `RunEnded` | Temporary XP/progression stops. | none |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Resource Data Schemas | Upstream | Provides draft metadata, rarity, tags, unlock gates. |
| Weapons and Auto-Attacks | Downstream | Adds new weapons and upgrades owned weapons. |
| Passive Items and Drafts | Downstream | Adds new passives and upgrades owned passives. |
| Evolution System | Downstream | Provides evolution candidates. |
| Page Events and Objectives | Downstream | Opens stronger reward drafts. |
| In-Run HUD and Draft UI | Downstream | Presents draft choices and selection. |
| Runtime Event Bus | Supporting | Emits XP collected, level gained, draft opened, choice selected. |

## Formulas

`xp_after_pickup = current_xp + pickup_value * xp_gain_multiplier`

`level_ready = xp_after_pickup >= xp_threshold_for_next_level`

`draft_choice_count = 3`

`choice_weight = base_weight * rarity_weight * tag_synergy_weight * timing_weight * eligibility_multiplier`

Invalid states:

- A normal draft has not exactly 3 choices.
- Draft offers a new weapon with no weapon slot available.
- Draft offers a new passive with no passive slot available.
- Draft offers an upgrade for maxed weapon/item.
- Fewer than 3 eligible choices and no fallback pool exists.

## Edge Cases

- If XP gain crosses multiple levels, queue drafts one at a time.
- If player dies during draft, death/victory flow decides whether the draft is canceled or resolved first.
- If all weapons/items are maxed and no evolution is available, fallback rewards use heal, currency, magnet, temporary super attack, or Pagecraft modifier pools.
- If draft UI cannot open, store pending draft and log blocking error.
- If a reward source has special pool rules, it still returns exactly 3 choices unless explicitly exempted later.
- If XP pickup pool is exhausted, pickup may merge values into nearby Color Mote.

## Dependencies

- **Resource Data Schemas**: Required draft metadata.
- **Weapons and Auto-Attacks**: Required weapon acquisition/leveling.
- **Passive Items and Drafts**: Required item acquisition/leveling.
- **Evolution System**: Required evolution cards.
- **In-Run HUD and Draft UI**: Required presentation.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `draft_choice_count` | `3` | fixed | Root GDD rule. |
| `early_new_weapon_target` | `3` | `1-5` | Strongly offer new weapons until met. |
| `max_weapon_slots` | `5` | fixed for MVP | Shared with weapon system. |
| `max_passive_slots` | `5` | fixed for MVP | Shared with item system. |
| `xp_curve_base` | `10` | `1+` | Prototype tuning. |
| `xp_curve_growth` | `1.12` | `1.0-1.5` | Prototype tuning. |
| `rarity_weights` | `60/25/9/5/1` | tuning | Common/Uncommon/Rare/Epic/Legendary. |

## Visual/Audio Requirements

- Color Motes must be visible on paper and readable under VFX.
- Level-up draft should feel rewarding with clear card feedback.
- XP pickup and draft selection SFX should be short and satisfying.

## UI Requirements

- Draft modal shows exactly 3 choices with icon, title, category, level, description, rarity, rarity-colored border, and compatibility hints.
- HUD shows XP bar, run level, weapon slots, item slots, and pending draft state.
- Gamepad/keyboard navigation must work without hover.

## Acceptance Criteria

- Color Mote XP can fill a run-level bar.
- Level-up opens exactly 3 choices.
- Draft eligibility respects 5 weapon slots, 5 item slots, weapon level 10, and item level 5.
- Fallback pool prevents fewer-than-3-choice drafts.
- Selection applies one reward and returns to run state.

## Open Questions

- Exact XP curve values are prototype-tuned.
- Exact rarity names/weights are content-tuned.
