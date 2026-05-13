# Passive Items and Drafts

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-13
> **Implements Pillar**: Power Fantasy First

## Overview

`Passive Items and Drafts` defines passive item content, item slots, 5-level progression, stat modifiers, catalyst tags, and how passive item cards appear in reward drafts. It owns passive item state and modifier application. It does not own full draft selection flow, weapon firing, evolution eligibility presentation, or save persistence.

## Player Fantasy

Items should feel like build-shaping keepsakes, not boring keys. A level 5 item should improve the run on its own and also open exciting evolution paths for compatible level 10 weapons.

Items are not hidden single-weapon upgrades. They shape builds through global stat bonuses, eligible authored stat channels, pickup rules, survivability, pets, Pagecraft behavior, or draft odds. Catalyst tags drive evolution eligibility and draft synergy; they do not limit normal passive item stat bonuses.

## Detailed Design

### Core Rules

1. MVP includes all 23 passive items as data-defined content, placeholder visuals acceptable.
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
12. Each item has an initial find rarity. That rarity affects only new-item card appearance.
13. Owned item upgrade cards grant exactly +1 item level regardless of the item's initial find rarity.
14. Normal passive items have 2 catalyst tags. Legendary `Foundational Keepsake` has all 10 catalyst tags, but only exposes evolution-enabling value at level 5.
15. MVP item find rarity split is 8 Common, 6 Uncommon, 5 Rare, 3 Epic, and 1 Legendary.
16. Normal passive item stat bonuses apply globally to player-owned sources unless the item explicitly names an eligible authored channel.
17. `effect_count`, `active_cap`, and `dash_count` apply only to authored eligible channels.
18. Chance bonuses use additive `+X% chance` wording and respect per-effect caps.
19. Luck affects draft rarity weights only. Common/basic weights stay unchanged, Uncommon-and-higher weights multiply by `1 + luck`, then the draft table is normalized.
20. Base player max HP for current item balance is 1000. Base dash recharge is 2.0s per charge and baseline dash invulnerability is 0.15s.

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

`item_find_weight = luck_adjusted_rarity_weight * tag_synergy_weight * timing_weight`

`luck_adjusted_rarity_weight = rarity_weight if rarity == Common else rarity_weight * (1.0 + luck)`

`item_upgrade_value = +1 item level`

Invalid states:

- Passive item has not exactly 5 levels.
- Item uses unknown catalyst/stat/material tag.
- New item appears when all 5 passive slots are full.
- Owned item upgrade grants anything other than exactly +1 item level.
- Level 5 item is consumed by evolution.
- Modifier applies directly by editing unrelated system internals.

## Edge Cases

- If all item slots are full and all items are level 5, normal item choices are removed from draft pools until endless overflow rules apply.
- If an item modifier references an absent downstream system, modifier is ignored with warning until that system exists in prototype builds.
- If multiple items modify the same stat, stacking rule comes from modifier metadata.
- If an item is deprecated, existing saves can load it but new drafts cannot offer it unless allowed.
- If item catalyst matches multiple weapons, all compatible level 10 weapons may become eligible.
- If an item is Legendary, it should still level through normal +1 item upgrade cards once owned.

## Dependencies

- **Resource Data Schemas**: Required item content and tags.
- **Damage and Status Model**: Required stat/status effect channels.
- **XP, Leveling, and Upgrade Drafts**: Required acquisition flow.
- **Evolution System**: Consumes catalyst tags.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `max_passive_slots` | `5` | `1-8` | Root GDD assumes 5 for MVP. |
| `minimum_passive_count_mvp` | `23` | `23+` | Content readiness requirement. |
| `item_level_cap` | `5` | fixed | Root GDD rule. |
| `default_modifier_stack_rule` | `additive` | enum | Override per modifier when needed. |
| `catalyst_unlock_level` | `5` | fixed | Root GDD rule. |
| `initial_find_rarity_weights` | `60/25/9/5/1` | tuning | Common/Uncommon/Rare/Epic/Legendary. |
| `initial_find_rarity_split` | `8/6/5/3/1` | fixed for MVP roster | Totals 23 active passives. |
| `normal_percent_item_values` | `10/20/30/40/50%` | tuning | Default in-run item percentage ladder. |
| `base_stat_boost_values` | `2/4/6/8/10%` | fixed for MVP roster | Legendary-only broad core stat boost. |
| `armor_item_values` | `10/20/30/40/50%` | tuning | Incoming damage mitigation. |
| `health_item_values` | `100/200/300/400/500 HP` | tuning | Max health ladder using 1000 base HP. |
| `health_regen_item_values` | `5/10/15/20/25 HP/s` | tuning | Passive health recovery ladder. |
| `luck_item_values` | `20/40/60/80/100% Luck` | tuning | Draft rarity raffle modifier. |
| `effect_count_item_values` | `1/2/3/4/5` | tuning | Eligible authored count channels only. |
| `active_cap_item_values` | `2/4/6/8/10` | tuning | Eligible authored active-object channels only. |

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

- Passive item system supports 5 item slots and 23 data-defined MVP passives.
- Items have exactly 5 levels and useful modifiers.
- Initial item find rarity affects new-item appearance only.
- Owned item upgrade cards grant fixed +1 item level.
- Level 5 items expose catalyst tags without being consumed.
- Item modifiers flow through typed channels.
- Draft systems can offer new items and item upgrades.

## Open Questions

- Final modifier stacking balance remains tuning-owned.
