# Page Events and Objectives

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-14
> **Implements Pillar**: The Page Is Alive, Power Fantasy First

## Overview

`Page Events and Objectives` defines timed mid-run objectives, offscreen event spawning, countdowns, progress tracking, success/failure, reward drafts, and boss-overlap rules. It owns objective state and rewards. It does not own run-level draft math, enemy AI, HUD layout, or boss combat.

Design source consulted: `PAGEBOUND_CODEX_GDD_v1_5.md`; `design/gdd/xp-leveling-and-upgrade-drafts.md`; `design/gdd/run-director-and-finite-spawning.md`; `design/gdd/in-run-hud-and-draft-ui.md`; first polished exemplar grilling session, 2026-05-14.

## Player Fantasy

Page Events should make the finite page matter. The player sees a storybook problem somewhere beyond the current view, routes toward it using a clear marker, fights around the objective, and earns a build reward when successful.

## Detailed Design

### Core Rules

1. Page Events are scheduled by authored run timing. They must not intentionally overlap with boss/finale windows.
2. If a boss/finale would begin while a Page Event is active, the boss waits until the active event resolves.
3. Events always spawn completely outside the player's current vision.
4. Event spawn location is random among valid reachable offscreen locations.
5. Event spawn validation must reject blocked, unreachable, locked, clipping, boss-only, or visible locations.
6. Event countdown starts when the event spawns, not when the player arrives.
7. Event HUD progress should be percent-first, with count/timer as secondary information.
8. Offscreen event guidance uses an edge marker/arrow. No minimap or compass is required for the first package.
9. Event success grants a 3-choice reward draft using `XP, Leveling, and Upgrade Drafts` rules.
10. If legal unowned gear exists and a slot is open, a successful Page Event reward must include at least one new gear card.
11. Event failure for the first package gives no reward and the run continues.
12. Page Events do not grant evolutions, Pagecraft modifiers, rare utility rewards, temporary super attacks, elite chest rewards, or boss reward drafts in current scope.
13. Event state emits progress for HUD, audio, debug, and future save/meta handoff.

### First Polished Exemplar Event

| Field | Decision |
|---|---|
| Event | `Color Well` |
| Schedule | Spawn at `1:00` in the compressed first polished exemplar slice. |
| Spawn | Random valid location completely outside current camera vision. |
| Marker | Edge arrow/marker points toward the event. |
| Countdown | `60s`, starts immediately on spawn. |
| Objective | Kill enemies inside the event circle. |
| Required Progress | `15` enemy deaths, counted by enemy death position. |
| Enemy Bias | None. Normal enemy spawns continue; objective does not pull or spawn special enemies. |
| Success | Opens Page Event reward draft with legal new-gear guarantee. |
| Failure | No reward. Run continues. |
| Boss Interaction | Boss waits if event is active. Schedules should be authored so this wait is rare or impossible. |

The event circle should show ring/fill world feedback, not a large center count. HUD banner shows percentage progress.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `Scheduled` | Director selected event/time but it is not spawned. | `Spawned`, `Cancelled` |
| `Spawned` | Event anchor/objective exists offscreen. | `Active`, `Failed`, `Cancelled` |
| `Active` | Countdown and progress are running. | `Succeeded`, `Failed`, `Cancelled` |
| `Succeeded` | Objective complete; reward draft begins. | `RewardClaimed` |
| `Failed` | Countdown or fail condition expired. | `Complete` |
| `RewardClaimed` | Reward is selected/applied. | `Complete` |
| `Cancelled` | Run/death cleanup removed event before completion. | `Complete` |
| `Complete` | Event is cleaned up. | none |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Resource Data Schemas | Upstream | Provides Page Event resources, objective type, rewards, chapter eligibility. |
| Run Director and Finite Spawning | Upstream | Schedules events and supplies valid offscreen spawn candidates. |
| Pagecraft Materials and Grid | Bidirectional | Supplies walkable/reachable/page-state validation. |
| Enemies and AI Movement | Downstream | Supplies enemy death positions for objective progress. |
| XP, Leveling, and Upgrade Drafts | Downstream | Opens 3-choice reward drafts with event guarantee. |
| In-Run HUD and Draft UI | Downstream | Shows percent progress, timer, and edge marker. |
| Boss and Victory Flow | Peer | Boss waits for active event resolution; event schedules should avoid overlap. |

## Formulas

`event_time_remaining = event_duration_seconds - elapsed_active_seconds`

`event_progress_ratio = clamp(current_objective_progress / required_objective_progress, 0, 1)`

`event_progress_percent = floor(event_progress_ratio * 100)`

`event_succeeded = event_progress_ratio >= 1.0 before event_time_remaining <= 0`

`spawn_candidate_valid = outside_current_vision and inside_chapter_bounds and reachable_from_play_area and not blocked and not boss_only`

Invalid states:

- Active event has no countdown.
- Event spawns inside the player's current vision.
- Event spawns unreachable, blocked, locked, clipping, or boss-only.
- Reward draft has not exactly 3 choices.
- Successful event reward omits guaranteed new gear while legal unowned gear exists and a slot is open.
- Boss and Page Event are active at the same time.

## Edge Cases

- If no valid offscreen event spawn exists, log a blocking edge error and do not spawn the event onscreen.
- If player reaches event after countdown expires, event fails with no reward.
- If event anchor becomes blocked after spawn, marker remains visible and objective area must remain reachable or event logs an error.
- If boss start time arrives while an event is active, boss queues until event success/failure resolves.
- If reward pool cannot produce 3 distinct legal choices in the tiny prototype pool, the draft system applies its temporary underfilled-pool rule.

## Dependencies

- **Resource Data Schemas**: Required Page Event data.
- **Run Director and Finite Spawning**: Required scheduling and spawn validation.
- **Pagecraft Materials and Grid**: Required map reachability.
- **XP, Leveling, and Upgrade Drafts**: Required reward drafts.
- **In-Run HUD and Draft UI**: Required event banner and marker.
- **Boss and Victory Flow**: Required boss wait rule.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `event_spawn_times_seconds` | authored | tuning | Full runs use authored non-overlap schedules; first exemplar uses `60`. |
| `event_duration_seconds` | `60` first exemplar | tuning | Full-run events can use longer timers later. |
| `color_well_required_kills` | `15` | tuning | First exemplar. |
| `minimum_offscreen_margin_px` | camera-dependent | `0+` | Event must be fully outside current view. |
| `objective_marker_edge_padding_px` | `32` | `8-96` | HUD readability. |

## Visual/Audio Requirements

- Event anchors need strong silhouettes on paper ground.
- Countdown warning needs visible and audible escalation.
- Success should feel celebratory; failure should be clear but not punishingly obscure.
- Objective progress visuals must not hide enemy danger.
- Color Well should read as storybook magic, not a generic combat circle.

## UI Requirements

- HUD shows current Page Event name, percentage progress, compact timer/count, and offscreen marker.
- Event progress is shown as a percentage.
- Reward uses 3-choice draft UI.
- Failure/success messages are short and action-focused.
- Debug overlay shows active event ID, progress, timer, spawn validity, reward guarantee state, and boss-wait state.

## Acceptance Criteria

- Event can spawn completely outside current camera vision at a random valid reachable location.
- Edge marker points to offscreen event.
- Color Well tracks 15 enemy deaths inside its circle by death position.
- Countdown starts immediately on spawn.
- Success opens a 3-choice reward draft with a new-gear guarantee when legal.
- Failure gives no reward and run continues.
- Boss and event never run simultaneously; boss waits if an event is active.

## Open Questions

- Full-run Page Event schedule and content count remain separate from the first polished exemplar slice.
