# Passive Items and Drafts

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Power Fantasy First

## Overview

`Passive Items and Drafts` defines passive item content, item slots, 5-level progression, stat modifiers, catalyst tags, and how passive item cards appear in reward drafts. It owns passive item state and modifier application. It does not own full draft selection flow, weapon firing, evolution eligibility presentation, or save persistence.

## Player Fantasy

Items should feel like build-shaping keepsakes, not boring keys. A level 5 item should improve the run on its own and also open exciting evolution paths for compatible level 10 weapons.

Items are not hidden single-weapon upgrades. They shape builds through stat families, material/tag families, pickup rules, survivability, pets, Pagecraft behavior, or draft odds. A tag-family item such as Candle Spark modifies Firelight/Waxlight-tagged damage through a typed modifier channel, not a hardcoded weapon ID.

## Detailed Design

### Core Rules

1. MVP includes all 20 passive items as data-defined content, placeholder visuals acceptable.
2. Every passive item has exactly 5 levels.
3. Player can own up to 5 passive item slots in normal MVP runs.
4. Passive items modify stats, behavior tags, pickup rules, pet power, Pagecraft behavior, survivability, or draft odds through explicit modifier definitions.
5. Level 5 passive items expose catalyst tags that can enable compatible weapon evolutions.
6. Items are not consumed by evolution.
7. Items must remain useful even when no owned weapon uses their catalyst tags.
8. Passive item cards can appear in normal level-up drafts, Page Event rewards, elite chests, and boss rewards through draft system rules.
9. Item modifiers apply through typed stat/modifier channels, not ad hoc script branches in unrelated systems.
10. Item data references tags from Resource Data Schemas.
11. Passive item effects should describe the stat or tag family they affect on draft cards.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `Locked` | Item not available to profile/run. | `DraftEligible` |
| `DraftEligible` | Item can appear as new passive draft. | `Owned` |
| `Owned` | Item is in a slot at level 1-4. | `MaxLevel`, `Inactive` |
| `MaxLevel` | Item is level 5 and its catalyst tags are active. | `Inactive` |
| `Inactive` | Run ended or debug removed item. | none |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Resource Data Schemas | Upstream | Provides item resources, levels, modifiers, catalyst tags. |
| Damage and Status Model | Downstream | Receives stat/status modifier effects. |
| Weapons and Auto-Attacks | Downstream | Receives weapon stat modifiers and behavior modifiers. |
| XP, Leveling, and Upgrade Drafts | Downstream | Offers new item and +1 item level choices. |
| Evolution System | Downstream | Reads level 5 catalyst tags for eligibility. |
| Pets and Companion Combat | Downstream | Receives pet power/frequency modifiers. |
| Pagecraft Materials and Grid | Downstream | Receives Pagecraft duration/area/material modifier channels. |

## Formulas

`item_slot_available = owned_passive_count < 5`

`modifier_value = base_modifier_value + level_modifier_delta`

`catalyst_active = item_level >= 5`

`item_draft_allowed = item_slot_available or owned_item_below_max_exists`

Invalid states:

- Passive item has not exactly 5 levels.
- Item uses unknown catalyst/stat/material tag.
- New item appears when all 5 passive slots are full.
- Level 5 item is consumed by evolution.
- Modifier applies directly by editing unrelated system internals.

## Edge Cases

- If all item slots are full and all items are level 5, normal item choices are removed from draft pools.
- If an item modifier references an absent downstream system, modifier is ignored with warning until that system exists in prototype builds.
- If multiple items modify the same stat, stacking rule comes from modifier metadata.
- If an item is deprecated, existing saves can load it but new drafts cannot offer it unless allowed.
- If item catalyst matches multiple weapons, all compatible level 10 weapons may become eligible.

## Dependencies

- **Resource Data Schemas**: Required item content and tags.
- **Damage and Status Model**: Required stat/status effect channels.
- **XP, Leveling, and Upgrade Drafts**: Required acquisition flow.
- **Evolution System**: Consumes catalyst tags.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `max_passive_slots` | `5` | `1-8` | Root GDD assumes 5 for MVP. |
| `minimum_passive_count_mvp` | `20` | `20+` | Content readiness requirement. |
| `item_level_cap` | `5` | fixed | Root GDD rule. |
| `default_modifier_stack_rule` | `additive` | enum | Override per modifier when needed. |
| `catalyst_unlock_level` | `5` | fixed | Root GDD rule. |
| `candle_spark_level_values` | `15/30/45/60/75%` | tuning | Firelight/Waxlight-tagged glow/burn damage. |

## Visual/Audio Requirements

- Each item needs icon/card art and short visual identity.
- Item acquisition and level-up should produce readable card/UI feedback.
- Item-triggered effects may request VFX/SFX through downstream systems.

## UI Requirements

- Draft cards show item name, level, current effect, next effect, catalyst tags at level 5, and compatible owned weapons when known.
- Draft cards state the affected stat or tag family, not only a weapon name.
- HUD/loadout view can show 5 item slots and levels.
- Debug overlay shows active modifiers and catalyst tags.

## Acceptance Criteria

- Passive item system supports 5 item slots and 20 data-defined MVP passives.
- Items have exactly 5 levels and useful modifiers.
- Level 5 items expose catalyst tags without being consumed.
- Item modifiers flow through typed channels.
- Draft systems can offer new items and item upgrades.

## Open Questions

- Exact item list and names can follow root GDD/content tables during implementation.
- Final modifier stacking balance remains tuning-owned.
