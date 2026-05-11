# Boss and Victory Flow

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Power Fantasy First

## Overview

`Boss and Victory Flow` defines 25:00 boss/finale start, boss actor lifecycle, phase handoff, victory trigger, post-boss reward flow, failure/death handoff, and run-complete events. It owns the run climax and resolution. It does not own normal enemy spawning, base damage math, player controller, or permanent meta progression spending.

## Player Fantasy

The boss is the proof that the run has become powerful. A strong build should be allowed to shred the boss early; a weak build should face escalating pressure but still understand what happened.

## Detailed Design

### Core Rules

1. Boss/finale starts at 25:00 in normal MVP runs.
2. Standard victory target is about 30:00, but strong builds can defeat the boss before then.
3. Boss spawns from chapter-specific dramatic anchor.
4. Normal Page Events stop at boss start.
5. Boss uses Damage and Status Model for health/damage.
6. Boss phases can change attacks, adds, telegraphs, and pressure but must preserve damage readability.
7. Boss defeat triggers victory immediately unless special endless mode is chosen later.
8. If boss remains alive after 30:00, pressure escalates but victory remains possible.
9. Victory flow records run summary events for rewards/meta later.
10. Boss telegraphs must remain readable over Pagecraft marks and damage numbers.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `WaitingForFinale` | Run is before 25:00. | `BossWarning`, `RunFailed` |
| `BossWarning` | Pre-boss warning and pressure wave. | `BossActive`, `RunFailed` |
| `BossActive` | Boss exists and fight is active. | `BossEnraged`, `BossDefeated`, `RunFailed` |
| `BossEnraged` | Post-30:00 escalation while boss remains alive. | `BossDefeated`, `RunFailed` |
| `BossDefeated` | Boss death has triggered victory transition. | `VictoryFlow` |
| `VictoryFlow` | Rewards/summary/return flow is active. | `RunComplete` |
| `RunFailed` | Player death or abort before victory. | `RunComplete` |
| `RunComplete` | Run cleanup/return handoff finished. | none |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Resource Data Schemas | Upstream | Provides boss resource, phases, rewards, telegraph refs, chapter link. |
| Run Director and Finite Spawning | Upstream | Starts boss at 25:00 and stops normal event cadence. |
| Damage and Status Model | Bidirectional | Handles boss health, damage intake, damage dealt, death. |
| Enemies and AI Movement | Downstream | Requests boss adds if phase data requires. |
| Camera and 2.5D Lighting | Downstream | Requests boss framing/warning/victory camera states. |
| In-Run HUD and Draft UI | Downstream | Shows boss health, warnings, victory UI, rewards. |
| Runtime Event Bus | Supporting | Emits boss spawned, phase changed, boss defeated, victory started. |

## Formulas

`boss_start_ready = run_time_seconds >= 1500`

`boss_enrage_ready = run_time_seconds >= 1800 and boss_alive`

`boss_health_after_damage = clamp(boss_health - resolved_damage, 0, max_boss_health)`

`victory_triggered = boss_health_after_damage <= 0 and victory_not_started`

Invalid states:

- Boss spawns later than 25:00 in normal MVP timeline.
- Boss death does not trigger victory/reward handoff.
- Boss telegraph is hidden by own VFX with no alternate warning.
- Boss is immune to all strong-build damage without explicit phase gate feedback.
- Victory and failure flows run simultaneously.

## Edge Cases

- If player kills boss before 30:00, victory starts immediately.
- If boss and player die in same frame, deterministic policy decides result; MVP favors player victory if boss defeat event resolves first.
- If boss spawn anchor is invalid, use chapter fallback center/edge anchor and log error.
- If boss phase requests unavailable add pool, skip adds and keep boss fight running.
- If endless mode later exists, victory choice can branch after boss defeat; MVP ends run.
- If draft UI is open at 25:00, boss warning queues until draft resolves or run timer pauses with draft.

## Dependencies

- **Resource Data Schemas**: Required boss data.
- **Run Director and Finite Spawning**: Required timing handoff.
- **Damage and Status Model**: Required boss health/death.
- **Camera and 2.5D Lighting**: Required boss framing.
- **In-Run HUD and Draft UI**: Required boss health/victory UI.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `boss_start_seconds` | `1500` | fixed MVP | 25:00 root GDD rule. |
| `enrage_start_seconds` | `1800` | `1500+` | 30:00 normal victory target. |
| `boss_health_multiplier` | `1.0` | `0.25-10.0` | Chapter/difficulty tuning. |
| `phase_count_mvp` | `3` | `1-5` | Prototype default. |
| `boss_zoom_multiplier` | `1.15` | `1.0-1.4` | Shared with camera. |

## Visual/Audio Requirements

- Boss entrance needs strong chapter-specific presentation.
- Boss telegraphs must read over Pagecraft/damage numbers.
- Boss damage numbers should be larger/more satisfying than normal enemy numbers.
- Victory music/stinger should clearly separate win state from combat.

## UI Requirements

- HUD shows boss warning, boss health, boss phase if useful, and victory prompt/summary.
- Victory screen shows key run stats: time, Page Events completed, favorite weapon/pet damage, highest damage number, rewards.
- Debug overlay shows boss state, phase, HP, enrage timer, and victory/failure flags.

## Acceptance Criteria

- Boss starts at 25:00 and normal Page Events stop.
- Boss can be defeated before 30:00 by strong builds.
- Boss defeat triggers one victory flow.
- Post-30:00 enrage/pressure is supported if boss survives.
- Victory/failure cleanup prevents duplicate run completion.

## Open Questions

- Exact MVP boss attacks belong to content implementation for first chapter boss.
- Endless branch remains post-MVP.

