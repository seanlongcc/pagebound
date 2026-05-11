# Damage and Status Model

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Power Fantasy First

## Overview

`Damage and Status Model` defines how hits, health, damage types, status effects, resistances, invulnerability, healing, death, and damage events are represented. It owns resolution rules and combat facts. It does not own weapon firing patterns, enemy AI, damage number visuals, draft choices, or balance tuning beyond formula contracts.

## Player Fantasy

Every hit should feel legible and rewarding. The player sees enemies melt under a coherent build, understands when they are hurt, and trusts that pets, weapons, Pagecraft, and bosses all use the same combat rules.

## Detailed Design

### Core Rules

1. All damage enters a single resolution path before health changes.
2. Damage payloads include source ID, target ID, amount, damage tags, material tags, crit state, status applications, and damage number profile.
3. Health-bearing entities expose current health, max health, alive/dead state, and damageable team/faction.
4. Status effects are data-driven and tick/update through clear ownership.
5. Damage types and status tags come from Resource Data Schemas.
6. Invulnerability windows can block damage but should still support optional feedback events.
7. Death emits a fact event once and only once per entity life.
8. Damage resolution must be deterministic for the same inputs where practical.
9. Damage numbers consume resolved damage facts; they do not calculate damage.
10. Bosses may have phase gates but should not invalidate the power fantasy by hiding all damage.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `Alive` | Entity can receive damage/healing/status. | `Invulnerable`, `Dying`, `Dead` |
| `Invulnerable` | Entity blocks or reduces incoming damage by rule. | `Alive`, `Dying` |
| `Dying` | Death event is being emitted and rewards may spawn. | `Dead` |
| `Dead` | Entity no longer receives normal damage/status. | none |
| `StatusActive` | One or more timed statuses affect entity. | `Alive`, `Dying`, `Dead` |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Resource Data Schemas | Upstream | Provides stat profiles, tags, damage types, status definitions. |
| Runtime Event Bus | Supporting | Publishes damage dealt, healing, status applied/expired, death. |
| Weapons and Auto-Attacks | Producer | Sends damage requests and status applications. |
| Pagecraft Materials and Grid | Producer/consumer | Applies damage/status from marks and receives material tags. |
| Enemies and AI Movement | Consumer | Uses health/death and contact damage rules. |
| Boss and Victory Flow | Consumer | Uses boss health, phases, death, victory trigger. |
| Damage Numbers and Combat Feedback | Consumer | Displays resolved damage facts. |

## Formulas

`final_damage = max(0, base_damage * source_multiplier * tag_multiplier * crit_multiplier * resistance_multiplier + flat_bonus)`

`health_after_damage = clamp(current_health - final_damage, 0, max_health)`

`status_tick_damage = status_base_damage * status_stack_multiplier * tick_delta`

`death_triggered = current_health > 0 and health_after_damage <= 0`

Invalid states:

- Negative final damage unless explicitly modeled as healing.
- Death event emitted more than once for one entity life.
- Status stack count below zero.
- Damage number produced before damage resolution.
- Unknown damage or status tag on active content.

## Edge Cases

- If target is already dead, damage request is ignored or logged at debug level.
- If target is invulnerable, emit blocked/zero damage feedback only if useful.
- If damage is very small but nonzero, preserve gameplay math and let feedback aggregate.
- If simultaneous hits kill target, first resolver owns death; later hits see dead state.
- If status expires during death, death cleanup wins.
- If boss phase gate blocks lethal damage, boss flow owns the clamp and must still emit readable feedback.

## Dependencies

- **Resource Data Schemas**: Required tags and stat profiles.
- **Runtime Event Bus**: Required for cross-system feedback once implemented.
- **Object Pooling and Performance Debug**: Needed for high-volume feedback consumers.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `minimum_visible_damage` | `1` | `0-10` | Display clamp, not math clamp. |
| `crit_multiplier_default` | `2.0` | `1.25-4.0` | Tuned by weapon/item stats later. |
| `status_tick_interval` | `0.25 s` | `0.1-1.0` | Also affects number aggregation. |
| `contact_damage_cooldown` | `0.5 s` | `0.1-2.0` | Prevents repeated enemy body hits. |
| `player_grace_after_hit` | `0.4 s` | `0.0-1.5` | MVP feel tuning. |

## Visual/Audio Requirements

- Damage events must include enough metadata for color, size, priority, and SFX routing.
- Player damage feedback must be more urgent than enemy damage feedback.
- Boss chunk damage must support larger feedback.
- Status effects need visible application/active/expiration cues in later feedback systems.

## UI Requirements

- HUD needs player health changes and status icons.
- Boss UI needs boss health/phase events.
- Debug overlay needs recent damage events, DPS totals, status counts, and death counts.

## Acceptance Criteria

- One resolution path handles weapon, pet, Pagecraft, enemy contact, boss, and status damage.
- Damage facts include source, target, tags, amount, crit/block state, and feedback profile.
- Health/death state cannot double-fire death events.
- Status effect lifecycle is data-driven and tag-aware.
- Damage numbers and audio can consume facts without recomputing damage.

## Open Questions

- Exact damage type taxonomy is finalized in Resource implementation.
- Fine balance belongs to weapon/enemy/boss tuning passes.

