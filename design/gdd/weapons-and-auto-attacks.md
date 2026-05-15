# Weapons and Auto-Attacks

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Power Fantasy First, The Page Is Alive

## Overview

`Weapons and Auto-Attacks` defines Pagebound's automatic weapon runtime: weapon slots, fire timing, targeting, projectile/area behavior handoff, level effects, Pagecraft mark emission, dash interaction metadata, and evolution replacement hooks. It owns weapon execution. It does not own damage math, item drafts, evolution eligibility, enemy AI, or Pagecraft simulation internals.

## Player Fantasy

Weapons should make the page feel conquered by the player's build. The player moves and dashes while comets, stickers, moons, sap, blooms, threads, pets, and page marks escalate into readable power.

## Detailed Design

### Core Rules

1. MVP includes all 20 shared weapons as data-defined content, placeholder visuals acceptable.
2. Every weapon has exactly 10 upgrade-count levels.
3. Every weapon defines type, material tags, page alteration, dash interaction, one editable base stat set, attack behavior reference, and 2 evolution catalyst tags.
4. Every weapon has a base maximum range used for targeting or effect placement before selected range modifiers.
5. Weapons auto-fire without aim input.
6. Player can own up to 5 weapon slots in normal MVP runs.
7. Selecting a weapon upgrade increases exactly one progress level at a time unless a reward explicitly grants multiple levels.
8. Separate one-stat range upgrade cards may increase weapon range without changing damage, count, cooldown, or weapon level.
9. Weapon levels do not grant hidden baseline stat growth; only selected upgrades, items, evolutions, or explicit effects change runtime stats.
10. Weapon runtime asks Damage Model to resolve damage; it does not directly subtract health.
11. Weapon runtime asks Pagecraft to deposit/activate marks; it does not own grid state.
12. Weapon visuals/projectiles use object pools.
13. Evolved weapons replace base behavior while keeping the weapon slot and level 10 state.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `Locked` | Weapon is not available to the profile/run. | `DraftEligible` |
| `DraftEligible` | Weapon can appear as new weapon draft. | `Owned` |
| `Owned` | Weapon is in a player slot at level 1-9. | `MaxLevel`, `Inactive` |
| `MaxLevel` | Weapon is level 10 and can be checked for evolution. | `EvolutionEligible`, `Inactive` |
| `EvolutionEligible` | Evolution system can offer eligible evolved forms. | `Evolved` |
| `Evolved` | Evolved behavior replaces base behavior. | `Inactive` |
| `Inactive` | Runtime ended or weapon removed by test/debug flow. | none |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Resource Data Schemas | Upstream | Provides weapon resources, base stat fields, tags, paths, and behavior IDs. |
| Damage and Status Model | Downstream | Resolves weapon damage/status payloads. |
| Object Pooling and Performance Debug | Supporting | Supplies projectiles, VFX, decals, and debug counters. |
| Pagecraft Materials and Grid | Downstream | Receives deposit/activation requests and material tags. |
| XP, Leveling, and Upgrade Drafts | Downstream | Offers new weapons and +1 weapon levels. |
| Evolution System | Downstream | Checks level 10 weapons and replaces with evolved weapon. |
| Damage Numbers and Combat Feedback | Downstream | Consumes resolved damage events from weapon hits. |

## Formulas

`fire_ready = cooldown_remaining <= 0 and weapon_state in [Owned, MaxLevel, EvolutionEligible, Evolved]`

`attack_interval = base_interval / max(0.1, attack_speed_multiplier)`

`weapon_damage = base_damage * player_damage_multiplier * weapon_specific_multiplier`

`weapon_can_target = distance_to_target <= current_weapon_range`

`weapon_slot_available = owned_weapon_count < 5`

Invalid states:

- Weapon is missing a valid base stat set.
- Weapon runtime subtracts target health directly.
- Weapon deposits unknown Pagecraft material tag.
- Weapon is offered as new draft when all 5 weapon slots are full.
- Evolved and base behavior both fire from the same slot unless explicitly designed.

## Edge Cases

- If no enemy target exists, weapon may hold fire, fire at nearest valid point, or create self-centered effect by behavior data.
- If projectile pool is exhausted, gameplay-critical projectiles may use fallback while optional VFX is skipped.
- If owner dies, weapon stops firing and returns pooled objects.
- If target dies before projectile impact, projectile retargets or resolves at last target position by behavior data.
- If time is paused for draft UI, weapon cooldowns pause.
- If a weapon reaches level 10 with no matching catalyst, it remains max level but not evolution eligible.

## Dependencies

- **Resource Data Schemas**: Required weapon content.
- **Damage and Status Model**: Required damage resolution.
- **Object Pooling and Performance Debug**: Required before large projectile/VFX volume.
- **Pagecraft Materials and Grid**: Required for page-altering identity.
- **XP, Leveling, and Upgrade Drafts**: Required for acquisition/leveling.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `max_weapon_slots` | `5` | `1-8` | Root GDD assumes 5 for MVP. |
| `minimum_weapon_count_mvp` | `20` | `20+` | Content readiness requirement. |
| `new_weapon_weight_until_count` | `3` | `1-5` | Draft system consumes this. |
| `cooldown_multiplier_min` | `0.15` | `0.05-1.0` | Prevents zero-interval attacks. |
| `pagecraft_deposit_scale` | `1.0` | `0.1-5.0` | Passed to Pagecraft, not owned here. |
| `weapon_range_step` | `1.0m` | `0.25-5.0m` | Separate one-stat draft card upgrade. |

## Visual/Audio Requirements

- Every weapon must have visible attack feedback and visible page alteration.
- Weapon mark colors/materials must remain readable on paper ground and against enemy telegraphs.
- Late-game escalation should increase visual richness without hiding danger.
- Each weapon has SFX metadata, but playback/mix is owned by Audio.

## UI Requirements

- Draft cards need weapon name, icon, current/new level, description, material tags, and evolution catalyst hints.
- HUD may show owned weapon slots and levels.
- Debug overlay needs weapon cooldowns, owned levels, hit counts, and top damage by weapon.

## Acceptance Criteria

- Weapon system supports 5 normal weapon slots and 20 data-defined MVP weapons.
- A weapon can auto-fire without aim input.
- Weapon level 1-10 progression changes behavior through selected upgrades and milestones, not hidden baseline stat growth.
- Weapon maximum range gates targeting/effect placement and can be upgraded by separate range cards.
- Weapon hits flow through Damage Model and Event Bus.
- Weapon Pagecraft deposits flow through Pagecraft system.
- Level 10 weapon can be handed to Evolution System for eligibility.

## Open Questions

- Exact behavior implementation for all 20 weapons can ship incrementally, but data slots must exist for MVP readiness.
- Final weapon balance belongs to content tuning.
