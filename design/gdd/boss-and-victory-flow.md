# Boss and Victory Flow

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-14
> **Implements Pillar**: Power Fantasy First

## Overview

`Boss and Victory Flow` defines boss/finale timing, boss actor lifecycle, event-overlap rules, phase handoff, victory trigger, failure/death handoff, and run-complete events. It owns the run climax and resolution. It does not own normal enemy spawning, base damage math, player controller, draft generation, or permanent meta progression spending.

Design source consulted: `PAGEBOUND_CODEX_GDD_v1_5.md`; `design/gdd/page-events-and-objectives.md`; `design/gdd/run-director-and-finite-spawning.md`; `design/gdd/in-run-hud-and-draft-ui.md`; first polished exemplar grilling session, 2026-05-14.

## Player Fantasy

The boss is the proof that the run has become powerful. A strong build should be allowed to shred the boss early; a weak build should face escalating pressure but still understand what happened.

## Detailed Design

### Core Rules

1. Full normal runs target boss/finale start at 30:00.
2. The first polished exemplar uses a compressed mini-boss/finale tease instead of the full final boss.
3. Boss/finale scheduling must not overlap active Page Events.
4. Event and boss schedules should be authored so overlap is impossible.
5. If overlap still occurs, boss/finale waits until the active Page Event resolves.
6. Boss/finale owns the same top-right HUD banner slot used by Page Events.
7. Boss and Page Event banners never display simultaneously.
8. Boss uses Damage and Status Model for health/damage.
9. Boss phases can change attacks, adds, telegraphs, and pressure but must preserve damage readability.
10. Boss defeat triggers victory/finale resolution unless the encounter is explicitly a mini-boss tease.
11. Boss pressure can escalate after it starts, but victory remains possible.
12. Boss/finale rewards are not part of the first polished exemplar draft model.
13. Boss telegraphs must remain readable over Pagecraft marks and damage numbers.

### First Polished Exemplar Mini-Boss

| Field | Decision |
|---|---|
| Encounter | `Crownless Echo` / `Scribble King Stirs` tease. |
| Schedule | Target `3:30` in the compressed first package. |
| Overlap Policy | If `Color Well` is active, wait until it succeeds or fails. |
| HUD | Top-right boss banner replaces event banner after event resolves. |
| Health Display | HP percent primary. |
| Reward | Drops XP/Color Motes only. No in-run reward draft. |
| End | Run does not hard stop at `5:00`; five minutes is an evaluation target. |

`Crownless Echo` is a killable mini-boss/finale tease, not the full 30-minute final boss.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `WaitingForFinale` | Run is before boss/finale time. | `BossWarning`, `BossQueuedForEvent`, `RunFailed` |
| `BossQueuedForEvent` | Boss time arrived while Page Event is active. | `BossWarning`, `RunFailed` |
| `BossWarning` | Pre-boss warning and pressure wave. | `BossActive`, `RunFailed` |
| `BossActive` | Boss exists and fight is active. | `BossEnraged`, `BossDefeated`, `RunFailed` |
| `BossEnraged` | Post-start escalation while boss remains alive. | `BossDefeated`, `RunFailed` |
| `BossDefeated` | Boss death has triggered finale/victory transition or mini-boss cleanup. | `VictoryFlow`, `RunActive` |
| `VictoryFlow` | Rewards/summary/return flow is active. | `RunComplete` |
| `RunFailed` | Player death or abort before victory. | `RunComplete` |
| `RunComplete` | Run cleanup/return handoff finished. | none |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Resource Data Schemas | Upstream | Provides boss resource, phases, rewards, telegraph refs, chapter link. |
| Run Director and Finite Spawning | Upstream | Starts or queues boss/finale according to authored schedule. |
| Page Events and Objectives | Peer | Supplies active event state; boss waits for event resolution. |
| Damage and Status Model | Bidirectional | Handles boss health, damage intake, damage dealt, death. |
| Enemies and AI Movement | Downstream | Requests boss adds if phase data requires. |
| Camera and 2.5D Lighting | Downstream | Requests boss framing/warning/victory camera states. |
| In-Run HUD and Draft UI | Downstream | Shows exclusive boss banner, HP percent, warnings, victory UI. |
| Runtime Event Bus | Supporting | Emits boss queued, spawned, phase changed, defeated, victory started. |

## Formulas

`boss_start_ready = run_time_seconds >= authored_boss_start_seconds`

`boss_can_start = boss_start_ready and not page_event_active`

`boss_queued_for_event = boss_start_ready and page_event_active`

`boss_health_after_damage = clamp(boss_health - resolved_damage, 0, max_boss_health)`

`boss_hp_percent = ceil(boss_health_after_damage / max_boss_health * 100)`

`victory_triggered = boss_health_after_damage <= 0 and victory_not_started and boss_is_finale`

Invalid states:

- Boss and Page Event are active simultaneously.
- Boss banner and Page Event banner display simultaneously.
- Boss death does not trigger its configured finale/victory/cleanup handoff.
- Boss telegraph is hidden by own VFX with no alternate warning.
- Boss is immune to all strong-build damage without explicit phase gate feedback.
- Victory and failure flows run simultaneously.

## Edge Cases

- If player kills boss quickly after spawn, victory or mini-boss cleanup starts immediately.
- If boss and player die in same frame, deterministic policy decides result; MVP favors player victory if boss defeat event resolves first.
- If boss spawn anchor is invalid, use chapter fallback center/edge anchor and log error.
- If boss phase requests unavailable add pool, skip adds and keep boss fight running.
- If draft UI is open at boss time, boss warning queues until draft resolves or run timer pauses with draft.
- If active Page Event runs long, boss remains queued and the top-right banner stays on the event until resolution.

## Dependencies

- **Resource Data Schemas**: Required boss data.
- **Run Director and Finite Spawning**: Required timing handoff.
- **Page Events and Objectives**: Required active event state.
- **Damage and Status Model**: Required boss health/death.
- **Camera and 2.5D Lighting**: Required boss framing.
- **In-Run HUD and Draft UI**: Required boss health/victory UI.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `boss_start_seconds` | `1800` full run | authored | Full normal run target. |
| `first_exemplar_boss_seconds` | `210` | tuning | Crownless Echo target time. |
| `boss_waits_for_event` | `true` | fixed current | Prevents overlap. |
| `boss_health_multiplier` | `1.0` | `0.25-10.0` | Chapter/difficulty tuning. |
| `phase_count_mvp` | `3` | `1-5` | Prototype default for full boss. |
| `boss_zoom_multiplier` | `1.15` | `1.0-1.4` | Shared with camera. |

## Visual/Audio Requirements

- Boss entrance needs strong chapter-specific presentation.
- Crownless Echo should feel like a finale tease, not a random elite.
- Boss telegraphs must read over Pagecraft/damage numbers.
- Boss damage numbers should be larger/more satisfying than normal enemy numbers.
- Victory music/stinger should clearly separate win state from combat.

## UI Requirements

- HUD shows boss warning and boss HP percent in the top-right exclusive banner.
- Boss banner takes over only after any active event resolves.
- Victory screen shows key run stats when the encounter is a true finale.
- Debug overlay shows boss state, queued-for-event state, phase, HP, pressure timer, and victory/failure flags.

## Acceptance Criteria

- Full-run boss target remains 30:00.
- First polished exemplar can spawn Crownless Echo around 3:30.
- Boss waits if a Page Event is active.
- Boss and Page Event HUD banners never overlap.
- Boss can be defeated quickly by strong builds.
- Boss defeat triggers one configured handoff.
- Post-start pressure escalation is supported if boss survives.
- Victory/failure cleanup prevents duplicate run completion.

## Open Questions

- Exact full MVP boss attacks belong to content implementation for first chapter boss.
- Endless branch remains post-MVP.
