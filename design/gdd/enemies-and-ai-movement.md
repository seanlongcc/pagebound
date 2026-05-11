# Enemies and AI Movement

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Power Fantasy First

## Overview

`Enemies and AI Movement` defines enemy actor data, movement behaviors, targeting, contact damage handoff, death/reward handoff, Pagecraft interaction tags, and finite-map movement constraints. It owns enemy movement and simple AI. It does not own spawn scheduling, boss behavior, damage math, loot/drop tables, or Page Event objective logic.

## Player Fantasy

Enemies should pressure the player without becoming sponges. The horde makes the player's build feel powerful, forces routing/dash decisions, and shows clear enemy roles in the finite page space.

## Detailed Design

### Core Rules

1. MVP enemies use `CharacterBody3D` or simple 3D movement actors on X/Z plane unless profiling requires a lighter custom controller.
2. Enemies target the player or objective by behavior profile.
3. Enemy behavior profiles include chaser, swarmer, ranged, elite, corrupter, objective hunter, and boss add.
4. Contact damage routes through Damage and Status Model.
5. Enemy health/death routes through Damage and Status Model and Runtime Event Bus.
6. Enemies can read Pagecraft movement modifiers and may deposit hostile marks if their profile allows.
7. Spawn Director owns when and where enemies appear; enemy system owns what they do after spawn.
8. Enemy actors use pools for high-volume waves.
9. MVP chapter needs at least 2 unique enemy families.
10. Enemy visuals must support top-down readability and distinct silhouettes/roles.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `Pooled` | Enemy inactive and reusable. | `Spawning` |
| `Spawning` | Enemy enters map with spawn cue/brief setup. | `Active` |
| `Active` | Enemy moves/attacks/receives damage. | `Stunned`, `Dying`, `Despawning` |
| `Stunned` | Temporary movement/action interruption. | `Active`, `Dying` |
| `Dying` | Death event/reward handoff occurs. | `Pooled` |
| `Despawning` | Removed by director/run cleanup without normal death reward. | `Pooled` |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Resource Data Schemas | Upstream | Provides enemy stat, movement, reward, and tag profiles. |
| Player Controller and Dash | Upstream | Provides player target position and collision. |
| Damage and Status Model | Bidirectional | Handles enemy health, contact damage, statuses, death. |
| Pagecraft Materials and Grid | Consumer/producer | Reads movement effects and can deposit hostile marks. |
| Run Director and Finite Spawning | Upstream | Spawns/despawns enemies and sets budgets. |
| Object Pooling and Performance Debug | Supporting | Pools enemy instances and reports counts. |
| Damage Numbers and Combat Feedback | Downstream | Displays damage/death feedback from damage facts. |

## Formulas

`desired_direction = normalize(target_position - enemy_position)`

`enemy_velocity = desired_direction * enemy_speed * pagecraft_speed_multiplier * status_speed_multiplier`

`contact_damage_allowed = contact_cooldown_remaining <= 0`

`death_reward_allowed = death_reason == killed_by_player_or_pet_or_pagecraft`

Invalid states:

- Enemy damages player directly outside Damage Model.
- Enemy spawns outside finite chapter bounds unless explicitly in spawn buffer.
- Enemy remains active after death event.
- Pooled enemy keeps old target/status/signal state.
- Enemy count scales without director budget.

## Edge Cases

- If player target is missing, enemies idle or move toward fallback anchor until run cleanup.
- If Pagecraft root/snare stops enemy, movement state remains active but velocity clamps.
- If enemy reaches map edge, behavior profile decides slide, turn, or despawn.
- If objective hunter target disappears, retarget to player or despawn by profile.
- If pathing is too expensive, MVP uses steering and simple avoidance before navigation meshes.
- If enemy dies offscreen, feedback can be reduced but rewards still spawn by rules.

## Dependencies

- **Resource Data Schemas**: Required enemy data.
- **Damage and Status Model**: Required health/damage/death.
- **Player Controller and Dash**: Required target.
- **Object Pooling and Performance Debug**: Required for volume.
- **Run Director and Finite Spawning**: Required for wave timing.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `base_enemy_speed` | `3.5 m/s` | `1.0-8.0` | Per enemy override. |
| `contact_damage_cooldown` | `0.5 s` | `0.1-2.0` | Shared with Damage Model. |
| `separation_radius` | `0.6 m` | `0.0-2.0` | Horde readability/perf tradeoff. |
| `elite_health_multiplier` | `4.0` | `2.0-20.0` | Tune by role. |
| `enemy_pool_initial_size` | `128` | `16-512` | Per family/profile. |

## Visual/Audio Requirements

- Enemy role silhouettes must be distinct at gameplay camera distance.
- Spawn cues should not obscure player danger.
- Enemy hurt/death feedback must support large damage-number spectacle.
- Corrupter/hostile Pagecraft enemies need clear hostile mark language.

## UI Requirements

- HUD does not list normal enemies.
- Boss/objective markers may distinguish elites or objective hunters.
- Debug overlay shows active enemies by type, target state, pooled count, and contact damage events.

## Acceptance Criteria

- Enemy actors can spawn from pools, target player/objectives, move on X/Z, and despawn/return cleanly.
- Contact damage and death route through Damage Model.
- At least two unique MVP chapter enemy profiles are supported.
- Enemy movement can query Pagecraft movement modifiers.
- Spawn timing/location remains owned by Run Director.

## Open Questions

- Exact first chapter enemy families belong to content implementation.
- Navigation mesh use remains optional until steering prototype proves insufficient.

