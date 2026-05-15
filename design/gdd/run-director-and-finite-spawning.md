# Run Director and Finite Spawning

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-14
> **Implements Pillar**: The Page Is Alive

## Overview

`Run Director and Finite Spawning` defines run timeline, finite-map spawn budgets, enemy waves, elite pressure, spawn location selection, cleanup, and handoff to Page Events and boss flow. It owns when and where enemies/objective pressure appear. It does not own enemy AI, boss attack logic, player movement, damage math, or map art.

## Player Fantasy

The page should feel pressured but fair. Enemies arrive from believable edges and lanes, Page Events pull the player across the finite page, and the 30:00 boss window feels like the planned climax of a run.

## Detailed Design

### Core Rules

1. Standard run timeline targets boss/finale at 30:00, with queueing if a Page Event is active.
2. Page Events use authored schedules and must not intentionally overlap with boss/finale windows.
3. Director owns spawn budgets by time band, chapter, difficulty, player strength, and active objectives.
4. Enemy spawns occur inside finite chapter bounds, generally outside camera view but not outside the map.
5. Director requests enemy instances from pools and enemy profiles from resources.
6. Director avoids long empty downtime and unfair instant surround spawns.
7. Director can schedule stronger chapter-specific waves at root GDD timing beats.
8. Director emits run timeline events for UI/audio/debug/boss systems.
9. Director does not directly control enemy movement after spawn.
10. Director supports cleanup on death, victory, restart, or scene unload.
11. Page Event anchors must spawn completely outside current player vision at a random valid reachable location.
12. If boss/finale time arrives while a Page Event is active, boss/finale queues until the event resolves.

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
| Boss and Victory Flow | Downstream | Starts or queues boss/finale at authored time. |
| Object Pooling and Performance Debug | Supporting | Provides enemy pool counts and cap warnings. |
| In-Run HUD and Draft UI | Downstream | Receives run timer, event warnings, boss warnings. |

## Formulas

`run_time_seconds = current_time - run_start_time - paused_duration`

`wave_progress = smoothstep(clamp(run_time_minutes / 30.0, 0.0, 1.0))`

`opening_progress = smoothstep(clamp(run_time_seconds / 60.0, 0.0, 1.0))`

`min_alive = round(lerp(8, 25, opening_progress))` before 1:00, otherwise `round(lerp(25, 320, wave_progress))`

`base_spawn_interval = lerp(1.00, 0.20, wave_progress)`

`effective_spawn_interval = base_spawn_interval / event_pressure_multiplier`

`target_kills_per_second = lerp(1.0, 10.0, wave_progress)`

`spawn_count = min_alive - active_enemy_count` when below minimum. During the first 1:00 opening grace, above-minimum pressure spawn count is `0`. After 1:00, pressure spawns use accumulated `target_kills_per_second * effective_spawn_interval` credit so fractional early rates do not round into a horde wall.

`spawn_allowed = active_enemy_count < 350 and pool_available`

`spawn_position_valid = inside_chapter_bounds and outside_camera_margin and reachable_from_play_area`

`event_spawn_position_valid = inside_chapter_bounds and outside_current_vision and reachable_from_play_area and not blocked and not boss_only`

Invalid states:

- Boss/finale fails to start or queue at authored boss time in normal MVP run.
- Spawn occurs outside finite map bounds without explicit staging rule.
- Active enemies exceed hard cap by director budget alone.
- Page Event schedule continues normal events after boss start.
- Page Event anchor spawns inside current player vision.
- Boss and Page Event are active simultaneously.
- Director owns enemy AI behavior.

## Edge Cases

- If no valid offscreen enemy spawn point exists, use a safe distant edge point or delay spawn.
- If no valid offscreen Page Event spawn point exists, log a blocking edge error and do not spawn the event onscreen.
- If player camps a map corner, spawn logic avoids unfair instant body blocking but can increase pressure lanes.
- If pool exhausted, director delays low-priority spawns and logs pressure loss.
- If Page Event is active at boss/finale time, boss/finale queues until the event succeeds or fails.
- If run is paused for draft UI, run timer pauses unless design later chooses slow motion.
- If player is overpowered, director may increase density but must not erase strong-build fantasy.

## Dependencies

- **Resource Data Schemas**: Required chapter spawn data.
- **Enemies and AI Movement**: Required enemy actors.
- **Pagecraft Materials and Grid**: Required map bounds/material context.
- **Object Pooling and Performance Debug**: Required enemy pooling.
- **Boss and Victory Flow**: Required 30:00 finale handoff.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `boss_start_seconds` | `1800` | fixed MVP | 30:00 root GDD rule. |
| `event_times_seconds` | `300,600,900,1200,1500` | fixed MVP | 5/10/15/20/25 minutes. |
| `endless_event_first_seconds` | `2100` | tuning | No earlier than 35:00, and only if no boss/event is active. |
| `event_countdown_seconds` | `180` | fixed MVP | Page Event rule. |
| `spawn_margin_from_camera_m` | `8` | `2-30` | Prevents visible pop-in. |
| `max_alive_enemies` | `350` | `100-800` | Hard standard-spawn cap for the MVP wave model. |
| `opening_min_alive_curve` | `8 -> 25` | tuning | Smoothstep over the first 60 seconds; director refills below this count and does not pressure-spawn above it. |
| `min_alive_curve` | `25 -> 320` | tuning | Smoothstep over 30 minutes after opening grace; director refills below this count. |
| `spawn_interval_curve` | `1.00s -> 0.20s` | tuning | Smoothstep over 30 minutes before event-pressure overrides. |
| `target_kills_per_second` | `1.0 -> 10.0` | tuning | Smoothstep over 30 minutes; pressure spawns match this rate after opening grace. |
| `enemy_health_multiplier` | `1.0 -> 10.0` | tuning | Linear over 30 minutes for the current prototype enemy profiles. |
| `pre_boss_wave_time_seconds` | `1650` | `1500-1790` | Root GDD uses 27:30. |

## Visual/Audio Requirements

- Spawn cues should be readable but not distracting.
- Pre-boss warning needs stronger audiovisual escalation.
- Spawn pressure should avoid flooding the camera with unreadable bodies before feedback systems can handle it.

## UI Requirements

- HUD shows run timer, event timer, boss warning, and offscreen objective/boss markers.
- Debug overlay shows run time, spawn budget, active enemies, spawn failures, event state, and boss handoff state.

## Acceptance Criteria

- Director can run a 30:00 MVP timeline with Page Events at 5/10/15/20/25.
- Spawns stay within finite map bounds and generally outside camera view.
- Director respects enemy pool/cap data.
- Boss flow starts or queues at authored boss time, and boss waits for any active Page Event.
- Director cleanup stops spawning and returns pooled actors.

## Open Questions

- Exact spawn curves are prototype-tuned after enemy and player controller implementation.
- Chapter-specific spawn anchors belong to Chapter and Map Construction.
