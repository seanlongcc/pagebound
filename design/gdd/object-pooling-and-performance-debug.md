# Object Pooling and Performance Debug

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Power Fantasy First

## Overview

`Object Pooling and Performance Debug` defines reusable runtime pools and developer metrics for high-volume Pagebound objects: projectiles, pickups, VFX, damage numbers, enemies, pet attacks, decals, and boss telegraphs. It owns pooling policy, caps, reuse lifecycle, and debug visibility. It does not own combat rules, enemy AI, Pagecraft simulation, or visual design.

## Player Fantasy

The player should see joyful chaos without stutter. Projectiles, pets, damage numbers, pickups, and Pagecraft marks should flood the page while the game still feels smooth and responsive.

## Detailed Design

### Core Rules

1. MVP pools all high-volume transient objects before scaling combat density.
2. Pool ownership lives outside individual weapon/enemy scripts.
3. Pooled objects implement reset/activate/deactivate lifecycle hooks.
4. Pools have soft warning caps and hard safety caps per object category.
5. Pool exhaustion must degrade presentation before breaking gameplay-critical behavior.
6. Active pool roots mount under shell roots: `Projectiles`, `Pickups`, `VFX`, `DamageNumbers`, `Pagecraft`, and actor subroots.
7. Debug overlay reports active counts, inactive counts, spawned/reused counts, cap hits, and FPS.
8. Pooling must not hide resource leaks; objects returned to pool must clear signals/timers/owner refs.
9. Stress tests target 300+ active enemies and 500+ pooled damage number visuals later in MVP.
10. Performance debug is developer-facing only and hidden by default.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `PoolUnregistered` | Pool definition exists but runtime pool has not spawned. | `PoolReady` |
| `PoolReady` | Inactive instances are available. | `ObjectActive`, `PoolExhausted`, `Shutdown` |
| `ObjectActive` | Instance is in scene and visible/active. | `ObjectReturning`, `Shutdown` |
| `ObjectReturning` | Instance runs cleanup before reuse. | `PoolReady` |
| `PoolExhausted` | Request exceeds available instances/cap. | `PoolReady`, `DroppedPresentation` |
| `DroppedPresentation` | Optional visual request is skipped or merged. | `PoolReady` |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Godot Project Shell | Upstream | Provides mount roots for active pooled objects. |
| Runtime Event Bus | Supporting | Publishes cap warnings and performance events. |
| Weapons and Auto-Attacks | Consumer | Requests projectile/attack/VFX instances. |
| Enemies and AI Movement | Consumer | Requests enemy instances from enemy pools. |
| Damage Numbers and Combat Feedback | Consumer | Requests pooled number visuals. |
| Pagecraft Materials and Grid | Consumer | Requests decals/ribbons/overlay visuals. |
| Pets and Companion Combat | Consumer | Requests pet attack effects. |

## Formulas

`reuse_rate = reused_count / max(1, spawned_count + reused_count)`

`pool_pressure = active_count / hard_cap`

`pool_request_allowed = active_count < hard_cap or request_is_gameplay_critical`

Invalid states:

- Pooled object remains connected to old owner after return.
- Active count exceeds hard cap without explicit critical override.
- Pool creates unbounded instances during combat.
- Debug overlay allocates enough data per frame to harm performance.

## Edge Cases

- If pool is exhausted for optional VFX, skip or merge effect.
- If pool is exhausted for gameplay-critical projectile, use emergency spawn only if capped and logged.
- If a pooled object frees itself, pool must detect and repair count on next validation.
- If scene reload occurs, pools clear all active/inactive instances.
- If an object changes parent during activation, return must reparent to the correct pool/root.

## Dependencies

- **Godot Project Shell**: Required mount roots and debug overlay slot.
- **Runtime Event Bus**: Optional event reporting.
- **Damage Numbers and Combat Feedback**: High-volume consumer.
- **Weapons, Enemies, Pagecraft, Pets**: High-volume producers/consumers.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `projectile_hard_cap` | `800` | `100-3000` | Prototype cap; tune by profiling. |
| `damage_number_hard_cap` | `500` | `100-1500` | Root GDD stress target. |
| `enemy_hard_cap` | `350` | `50-800` | MVP target 300+ stress. |
| `vfx_hard_cap` | `400` | `50-1200` | Optional visuals degrade first. |
| `pool_debug_update_hz` | `4` | `1-30` | Avoid per-frame UI churn. |
| `emergency_spawn_enabled` | `false` | bool | Enable only for debugging critical caps. |

## Visual/Audio Requirements

- Pooled visuals must reset color, scale, animation, material state, and visibility on reuse.
- Damage numbers and Pagecraft overlays must avoid popping from stale transforms.
- Pool cap degradation should be visually graceful: merge numbers, reduce optional particles, suppress offscreen effects.
- Audio one-shots are not pooled here unless later profiling proves a need.

## UI Requirements

- Debug overlay shows FPS, pool counts, cap warnings, active enemies, active damage numbers, active Pagecraft visuals, and recent drops.
- Debug overlay must be hidden by default and never block gameplay input unless explicitly focused.

## Acceptance Criteria

- Pool design covers projectiles, pickups, VFX, damage numbers, enemies, pet attacks, decals, and boss telegraphs.
- Every pooled object has clear activate/deactivate/reset lifecycle.
- Pool exhaustion rules prioritize gameplay over optional presentation.
- Debug overlay has defined metrics and low update frequency.
- Downstream systems can request pooled instances without owning storage policy.

## Open Questions

- Exact pool API names belong to implementation.
- Final caps remain profiling-driven after first playable stress tests.

