# Damage Numbers and Combat Feedback

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-14
> **Implements Pillar**: Power Fantasy First

## Overview

`Damage Numbers and Combat Feedback` defines pooled damage number visuals, hit feedback, crit/boss/status presentation, aggregation, priority, offscreen suppression, and readability rules. It owns combat presentation after damage is resolved. It does not own damage math, weapon targeting, enemy death, or audio mix policy.

## Player Fantasy

Pagebound should celebrate damage. By late game, the page should erupt with readable cascades of numbers, crits, boss chunks, and Pagecraft ticks without hiding danger. Pet support feedback should read clearly without implying Dog deals damage in the first polished exemplar.

## Detailed Design

### Core Rules

1. Damage numbers are default-on.
2. Damage numbers consume resolved damage facts from Damage and Status Model.
3. Damage numbers are pooled.
4. Normal damage, crits, boss chunks, Pagecraft ticks, blocked hits, healing, status ticks, and pet support pips have distinct profiles.
5. Tick damage can aggregate per enemy per 0.25s when number spam becomes too high.
6. Offscreen damage numbers can be suppressed or summarized.
7. Boss/critical numbers have higher priority and larger presentation.
8. Accessibility option can disable or reduce damage numbers later.
9. Feedback must not hide boss telegraphs, player danger, or Page Event markers.
10. This system emits presentation-only state and never changes gameplay damage.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `IdlePooled` | Number visual waits in pool. | `Spawning` |
| `Spawning` | Visual receives payload, style, and world/screen position. | `Animating` |
| `Animating` | Number floats/fades/scales. | `Returning`, `Aggregating` |
| `Aggregating` | Tick events merge into one visible value. | `Animating`, `Returning` |
| `Returning` | Visual resets and returns to pool. | `IdlePooled` |
| `Suppressed` | Optional number is skipped due to settings/cap/offscreen. | `IdlePooled` |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Damage and Status Model | Upstream | Provides resolved damage/heal/status facts. |
| Runtime Event Bus | Upstream | Delivers damage/status/death events. |
| Object Pooling and Performance Debug | Supporting | Supplies pooled number visuals and cap metrics. |
| Camera and 2.5D Lighting | Supporting | Provides projection/framing context if using viewport UI. |
| Boss and Victory Flow | Upstream | Provides boss priority/profile context. |
| In-Run HUD and Draft UI | Downstream | Coordinates visibility so modals can pause/reduce feedback. |

## Formulas

`number_priority = base_profile_priority + crit_bonus + boss_bonus + player_damage_bonus`

`aggregate_window_seconds = 0.25`

`spawn_allowed = active_number_count < damage_number_hard_cap or number_priority >= critical_priority`

`display_amount = aggregated_amount if aggregation_active else resolved_damage_amount`

Invalid states:

- Damage number calculates gameplay damage.
- Number pool creates unbounded instances.
- Offscreen/tick spam hides boss telegraphs.
- Suppressed critical boss/player damage has no alternate feedback.
- Accessibility disabled numbers still spawn visuals.

## Edge Cases

- If number pool is exhausted, lower-priority tick numbers aggregate or suppress first.
- If target dies before number spawns, use last known hit position.
- If camera projection fails, use world-space fallback or skip optional number.
- If damage amount is zero due to block/invulnerability, show blocked profile only when useful.
- If player disables numbers later, keep non-number hit flashes/SFX where appropriate.

## Dependencies

- **Damage and Status Model**: Required damage facts.
- **Object Pooling and Performance Debug**: Required pooling.
- **Runtime Event Bus**: Required event delivery.
- **Camera and 2.5D Lighting**: Required projection/framing support.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `damage_number_hard_cap` | `500` | `100-1500` | Root GDD stress target. |
| `boss_critical_cap` | `50` | `10-200` | Root GDD boss/crit cap. |
| `tick_aggregation_seconds` | `0.25` | `0.05-1.0` | Root GDD guidance. |
| `number_lifetime_seconds` | `0.75` | `0.2-2.0` | Readability tuning. |
| `offscreen_suppression_enabled` | `true` | bool | Performance/readability. |

## Visual/Audio Requirements

- Numbers should use readable type, color, size, and motion profiles.
- Boss chunks and crits should feel oversized but not obscure telegraphs.
- Pet support feedback may use accent/icon styling. The first polished exemplar Dog has no damage numbers.
- Pagecraft tick numbers should aggregate when dense.
- Audio hooks exist for crits/boss chunks but mix belongs to Audio.

## UI Requirements

- Numbers may be 3D camera-facing text/quads or screen-space projected UI, chosen by performance/readability.
- Settings later need default-on, reduced, and off modes.
- Debug overlay shows active number count, suppressed count, aggregation count, and pool pressure.

## Acceptance Criteria

- Resolved damage facts spawn pooled damage numbers.
- Crit, boss, Pagecraft, healing, blocked, status, and pet support profiles are supported.
- Tick aggregation prevents unreadable spam.
- Offscreen/low-priority suppression degrades presentation without changing damage.
- Debug metrics expose pool pressure and suppressed counts.

## Open Questions

- Final font choice waits for UI/art direction and asset provenance.
- World-space vs screen-space implementation is performance-tested.
