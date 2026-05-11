# Evolution System

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Power Fantasy First

## Overview

`Evolution System` defines tag-based weapon evolution eligibility, candidate generation, evolved weapon replacement, and evolution card contracts. It owns eligibility and replacement rules. It does not own base weapon firing, passive item modifier application, draft UI layout, or Pagecraft gating.

## Player Fantasy

Evolutions should feel like the build blooming into something bigger. The player should understand: level 10 weapon plus level 5 compatible catalyst item can become a spectacular evolved weapon.

## Detailed Design

### Core Rules

1. Evolutions are tag-based, not fixed 1:1 recipes.
2. A weapon becomes evolution-eligible when it is level 10 and the player owns at least one level 5 passive item with a compatible catalyst tag.
3. Evolutions do not require extra Pagecraft conditions.
4. Passive items are not consumed by evolution.
5. An evolved weapon replaces the base weapon behavior in the same slot and remains level 10.
6. A base weapon can evolve only once per run.
7. If multiple evolution paths are eligible for one weapon, draft pools may offer one or more over time; selecting one locks that weapon.
8. Evolution cards may appear in level-up drafts, Page Event rewards, elite chests, and boss rewards.
9. Evolved weapons inherit base weapon material identity plus catalyst identity.
10. Evolution data comes from Resource Data Schemas.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `NotEligible` | Weapon lacks level 10 or matching level 5 item catalyst. | `Eligible` |
| `Eligible` | At least one evolution path can be offered. | `Offered`, `NotEligible` |
| `Offered` | Evolution appears in a draft/reward choice. | `Selected`, `Eligible` |
| `Selected` | Player chose evolution card. | `Evolved` |
| `Evolved` | Base weapon is replaced and locked. | none |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Resource Data Schemas | Upstream | Provides evolution resources, base weapon IDs, catalyst tags, evolved weapon IDs. |
| Weapons and Auto-Attacks | Downstream | Replaces base weapon runtime with evolved weapon runtime. |
| Passive Items and Drafts | Upstream | Provides level 5 catalyst tags. |
| XP, Leveling, and Upgrade Drafts | Downstream | Requests evolution candidates for draft pools. |
| Page Events and Objectives | Downstream | Can offer evolution cards as stronger reward drafts. |
| In-Run HUD and Draft UI | Downstream | Shows eligibility and evolution previews. |

## Formulas

`weapon_ready = weapon_level == 10 and weapon_not_evolved`

`catalyst_ready = any(item.level == 5 and item.catalyst_tags intersects evolution.required_catalyst_tags)`

`evolution_eligible = weapon_ready and catalyst_ready`

`evolution_choice_weight = base_weight * reward_source_multiplier * build_synergy_multiplier`

Invalid states:

- Evolution requires Pagecraft condition.
- Passive item is consumed by evolution.
- Evolved weapon appears without base weapon level 10.
- Base weapon evolves more than once per run.
- Evolution path references missing evolved weapon ID.

## Edge Cases

- If two level 5 items satisfy the same evolution, either item can support eligibility; neither is consumed.
- If base weapon is deprecated mid-development, migration rules must map old IDs before save compatibility matters.
- If evolved weapon resource is missing, validation blocks it before runtime.
- If a draft offers an evolution and the player changes eligibility before selection, the choice revalidates on selection.
- If multiple weapons become eligible together, draft weighting decides which cards appear first.

## Dependencies

- **Resource Data Schemas**: Required evolution data.
- **Weapons and Auto-Attacks**: Required base/evolved weapon runtime.
- **Passive Items and Drafts**: Required catalyst tags.
- **XP, Leveling, and Upgrade Drafts**: Required card offering.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `required_weapon_level` | `10` | fixed | Root GDD rule. |
| `required_item_level` | `5` | fixed | Root GDD rule. |
| `max_evolutions_per_weapon_per_run` | `1` | fixed | Root GDD rule. |
| `evolution_card_base_weight` | `1.0` | `0.0-10.0` | Draft tuning. |
| `page_event_evolution_weight_multiplier` | `1.5` | `0.0-5.0` | Stronger event rewards. |

## Visual/Audio Requirements

- Evolution card presentation should be more celebratory than normal upgrades.
- Evolved weapon activation needs clear transformation VFX/SFX.
- Evolved weapons must remain readable during late-game chaos.

## UI Requirements

- Draft card shows base weapon, catalyst tag/item, evolved weapon name, and replacement effect.
- HUD/loadout can mark eligible weapons and evolved weapons.
- Debug overlay lists eligible evolution paths and blocked reasons.

## Acceptance Criteria

- Level 10 weapon plus level 5 compatible item tag creates eligibility.
- Evolution does not consume passive item.
- Evolved weapon replaces base weapon in same slot.
- No Pagecraft condition gates evolution.
- Multiple eligible paths are supported but one selection locks the base weapon.

## Open Questions

- Exact evolved weapon list can be smaller than 20 for early prototype but MVP content plan targets at least 8 implemented evolutions from root GDD milestone guidance.

