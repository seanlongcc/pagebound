# XP, Leveling, and Upgrade Drafts

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-13
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
6. Run levels 5, 10, 20, and 35 are weapon-only acquisition drafts when legal, showing only new weapon cards.
7. New weapon choices are blocked when 5 weapon slots are full.
8. New passive item choices are blocked when 5 passive slots are full.
9. Owned weapons below 10 and owned passives below 5 can appear as upgrade choices.
10. If normal eligibility produces fewer than 3 choices, approved fallback choices fill the draft.
11. Non-weapon-only normal drafts use 1 weapon-side card, 1 item-side card, and 1 flex card when legal choices exist.
12. Page Event reward drafts use build-completion bias for item upgrades, catalyst fixes, evolutions, and high-rarity upgrades.
13. Page Event, elite, chest, and boss reward drafts can use stronger pools but still use 3 choices unless a later GDD explicitly overrides.
14. Strong normal runs should reach run level 50 by the 30:00 boss/finale start.
15. Overleveling past 50 is allowed. Normal weapon, item, and evolution upgrades continue while available.
16. Once no normal weapon, item, or evolution upgrades remain, endless drafts switch to overflow rewards.
17. Draft UI may pause or slow combat; this system owns draft state, not modal layout.
18. One-stat weapon range cards can appear for owned weapons and must not also change damage, count, cooldown, or weapon level.
19. Draft card rarity must be visible through simple rarity-colored borders.
20. Luck modifies draft rarity weights only. It does not change draft categories, legal pools, XP, currency, or drop rates.

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

`choice_weight = base_weight * luck_adjusted_rarity_weight * tag_synergy_weight * timing_weight * eligibility_multiplier`

`luck_adjusted_rarity_weight = rarity_weight if rarity == Common else rarity_weight * (1.0 + luck)`

`weapon_only_draft_level = run_level in [5, 10, 20, 35] and owned_weapon_count < 5`

`normal_draft_shape = weapon_side_slot + item_side_slot + flex_slot`

`overflow_draft_allowed = run_level > 50 and no_normal_weapon_item_or_evolution_choices_exist`

Invalid states:

- A normal draft has not exactly 3 choices.
- A weapon-only acquisition draft includes non-weapon cards while legal new weapons exist.
- Draft offers a new weapon with no weapon slot available.
- Draft offers a new passive with no passive slot available.
- Draft offers an upgrade for maxed weapon/item.
- An owned item upgrade grants more or less than +1 item level.
- Fewer than 3 eligible choices and no fallback pool exists.

## Edge Cases

- If XP gain crosses multiple levels, queue drafts one at a time.
- If player dies during draft, death/victory flow decides whether the draft is canceled or resolved first.
- If all weapons/items are maxed and no evolution is available before endless overflow is active, fallback rewards use heal, currency, magnet, temporary super attack, or Pagecraft modifier pools.
- If all weapons/items/evolutions are exhausted during endless, overflow drafts offer small repeatable stats, utility, heals/shields, currency, or risk/reward modifiers.
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
| `weapon_only_draft_levels` | `5/10/20/35` | tuning | New-weapon-only acquisition drafts. |
| `normal_draft_composition` | `weapon/item/flex` | enum | One weapon-side, one item-side, one flex card when legal. |
| `max_weapon_slots` | `5` | fixed for MVP | Shared with weapon system. |
| `max_passive_slots` | `5` | fixed for MVP | Shared with item system. |
| `strong_run_level_at_boss` | `50` | tuning | Target by 30:00 boss start. |
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
- Run levels 5, 10, 20, and 35 produce weapon-only acquisition drafts when legal new weapons exist.
- Non-weapon-only normal drafts follow weapon-side/item-side/flex composition when legal choices exist.
- Draft eligibility respects 5 weapon slots, 5 item slots, weapon level 10, and item level 5.
- Owned item upgrade choices grant fixed +1 item level.
- Overlevel drafts continue normal progression while normal choices exist, then switch to overflow rewards.
- Fallback pool prevents fewer-than-3-choice drafts.
- Selection applies one reward and returns to run state.

## Open Questions

- Exact XP curve values are prototype-tuned.
- Exact rarity names/weights are content-tuned.
