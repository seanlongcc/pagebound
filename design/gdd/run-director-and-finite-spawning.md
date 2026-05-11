# Run Director and Finite Spawning

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: The Page Is Alive

## Overview

`Run Director and Finite Spawning` defines run timeline, finite-map spawn budgets, enemy waves, elite pressure, spawn location selection, cleanup, and handoff to Page Events and boss flow. It owns when and where enemies/objective pressure appear. It does not own enemy AI, boss attack logic, player movement, damage math, or map art.

## Player Fantasy

The page should feel pressured but fair. Enemies arrive from believable edges and lanes, Page Events pull the player across the finite page, and the 25:00 boss window feels like the planned climax of a run.

## Detailed Design

### Core Rules

1. Standard run timeline uses boss/finale spawn at 25:00 and normal victory target around 30:00.
2. Page Events spawn at 5:00, 10:00, 15:00, and 20:00; standard Page Events stop when boss/finale starts.
3. Director owns spawn budgets by time band, chapter, difficulty, player strength, and active objectives.
4. Spawns occur inside finite chapter bounds, generally outside camera view but not outside the map.
5. Director requests enemy instances from pools and enemy profiles from resources.
6. Director avoids long empty downtime and unfair instant surround spawns.
7. Director can schedule stronger chapter-specific waves at root GDD timing beats.
8. Director emits run timeline events for UI/audio/debug/boss systems.
9. Director does not directly control enemy movement after spawn.
10. Director supports cleanup on death, victory, restart, or scene unload.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `RunPending` | Chapter selected but run not started. | `RunActive` |
| `RunActive` | Timer, enemy budgets, and Page Event schedule run. | `EventPressure`, `PreBoss`, `BossStarted`, `RunEnded` |
| `EventPressure` | Active Page Event affects spawn mix/budget. | `RunActive`, `PreBoss`, `RunEnded` |
| `PreBoss` | 22:30 pressure wave and boss warning period. | `BossStarted`, `RunEnded` |
| `BossStarted` | Boss/finale flow owns primary climax. | `RunEnded` |
| `RunEnded` | Director stops spawning and cleans up. | none |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Resource Data Schemas | Upstream | Provides chapter spawn tables, enemy pools, timing data. |
| Pagecraft Materials and Grid | Upstream/consumer | Uses map bounds and may react to material pressure. |
| Enemies and AI Movement | Downstream | Requests enemy spawn/despawn and gives target context. |
| Page Events and Objectives | Bidirectional | Schedules events and reacts to event state. |
| Boss and Victory Flow | Downstream | Starts boss/finale at 25:00. |
| Object Pooling and Performance Debug | Supporting | Provides enemy pool counts and cap warnings. |
| In-Run HUD and Draft UI | Downstream | Receives run timer, event warnings, boss warnings. |

## Formulas

`run_time_seconds = current_time - run_start_time - paused_duration`

`spawn_budget = base_budget_by_time * difficulty_multiplier * event_pressure_multiplier * active_enemy_budget_modifier`

`spawn_allowed = active_enemy_count < spawn_budget and pool_available`

`spawn_position_valid = inside_chapter_bounds and outside_camera_margin and reachable_from_play_area`

Invalid states:

- Boss/finale fails to start at 25:00 in normal MVP run.
- Spawn occurs outside finite map bounds without explicit staging rule.
- Active enemies exceed hard cap by director budget alone.
- Page Event schedule continues normal events after boss start.
- Director owns enemy AI behavior.

## Edge Cases

- If no valid offscreen spawn point exists, use a safe distant edge point or delay spawn.
- If player camps a map corner, spawn logic avoids unfair instant body blocking but can increase pressure lanes.
- If pool exhausted, director delays low-priority spawns and logs pressure loss.
- If Page Event is active at 25:00, boss start rules resolve event first by Page Event policy.
- If run is paused for draft UI, run timer pauses unless design later chooses slow motion.
- If player is overpowered, director may increase density but must not erase strong-build fantasy.

## Dependencies

- **Resource Data Schemas**: Required chapter spawn data.
- **Enemies and AI Movement**: Required enemy actors.
- **Pagecraft Materials and Grid**: Required map bounds/material context.
- **Object Pooling and Performance Debug**: Required enemy pooling.
- **Boss and Victory Flow**: Required 25:00 finale handoff.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `boss_start_seconds` | `1500` | fixed MVP | 25:00 root GDD rule. |
| `event_times_seconds` | `300,600,900,1200` | fixed MVP | 5/10/15/20 minutes. |
| `event_countdown_seconds` | `180` | fixed MVP | Page Event rule. |
| `spawn_margin_from_camera_m` | `8` | `2-30` | Prevents visible pop-in. |
| `active_enemy_stress_target` | `300` | `100-800` | Profiling target. |
| `pre_boss_wave_time_seconds` | `1350` | `1200-1490` | Root GDD uses 22:30. |

## Visual/Audio Requirements

- Spawn cues should be readable but not distracting.
- Pre-boss warning needs stronger audiovisual escalation.
- Spawn pressure should avoid flooding the camera with unreadable bodies before feedback systems can handle it.

## UI Requirements

- HUD shows run timer, event timer, boss warning, and offscreen objective/boss markers.
- Debug overlay shows run time, spawn budget, active enemies, spawn failures, event state, and boss handoff state.

## Acceptance Criteria

- Director can run a 25:00 MVP timeline with Page Events at 5/10/15/20.
- Spawns stay within finite map bounds and generally outside camera view.
- Director respects enemy pool/cap data.
- Boss flow starts at 25:00 and normal Page Events stop.
- Director cleanup stops spawning and returns pooled actors.

## Open Questions

- Exact spawn curves are prototype-tuned after enemy and player controller implementation.
- Chapter-specific spawn anchors belong to Chapter and Map Construction.

