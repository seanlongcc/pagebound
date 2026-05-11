# Page Events and Objectives

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: The Page Is Alive, Power Fantasy First

## Overview

`Page Events and Objectives` defines timed mid-run objectives, event spawning, countdowns, progress tracking, success/failure, reward drafts, failure consequences, and chapter eligibility. It owns objective state and rewards. It does not own run timer scheduling, enemy AI, draft UI layout, or boss victory rules.

## Player Fantasy

Page Events should make the finite page matter. The player chooses to route toward a timed storybook problem, fights through pressure, and earns a meaningful reward that can accelerate the build.

## Detailed Design

### Core Rules

1. Major Page Events occur at 5:00, 10:00, 15:00, and 20:00.
2. Each Page Event has a 3-minute countdown.
3. Events spawn in reachable finite-map locations.
4. Event objectives can include cleanse marks, defend object, escort/rescue pet, dash challenge, defeat elite, collect fragments, repair map tear, or fill/paint zone.
5. Event success grants a 3-choice reward draft stronger than normal level-up drafts.
6. Event failure creates a consequence such as hazard, enemy burst, missed pet progress, lower next reward tier, or map pressure.
7. Events can reward Pigment, Treats, weapon/passive upgrade, evolution card, pet quest/unlock, Pagecraft modifier, temporary super attack, map repair, or Sticker Album entry.
8. MVP should support at least 10 Page Event definitions, even if some share prototype logic.
9. Page Events stop normal scheduling when boss/finale starts.
10. Event state emits progress for HUD, audio, debug, save/meta handoff later.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `Scheduled` | Director selected event/time but it is not spawned. | `Spawned`, `Cancelled` |
| `Spawned` | Event anchor/objective exists on map. | `Active`, `Failed`, `Cancelled` |
| `Active` | Countdown and progress are running. | `Succeeded`, `Failed`, `Cancelled` |
| `Succeeded` | Objective complete; reward draft/quest progress begins. | `RewardClaimed` |
| `Failed` | Countdown or fail condition expired. | `ConsequenceApplied` |
| `RewardClaimed` | Reward is selected/applied. | `Complete` |
| `ConsequenceApplied` | Failure consequence is applied. | `Complete` |
| `Cancelled` | Run/boss/death removed event. | `Complete` |
| `Complete` | Event is cleaned up. | none |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Resource Data Schemas | Upstream | Provides Page Event resources, objective type, rewards, chapter eligibility. |
| Run Director and Finite Spawning | Upstream | Schedules events and may alter spawns during event. |
| Pagecraft Materials and Grid | Bidirectional | Supplies cleanse/fill/mark objectives and hazards. |
| Enemies and AI Movement | Downstream | Requests elites/objective hunters/event waves. |
| XP, Leveling, and Upgrade Drafts | Downstream | Opens 3-choice reward drafts. |
| Pets and Companion Combat | Downstream | Receives pet rescue/unlock progress later. |
| In-Run HUD and Draft UI | Downstream | Shows timer, objective, progress, markers, reward draft. |

## Formulas

`event_time_remaining = event_duration_seconds - elapsed_active_seconds`

`event_progress_ratio = clamp(current_objective_progress / required_objective_progress, 0, 1)`

`event_succeeded = event_progress_ratio >= 1.0 before event_time_remaining <= 0`

`reward_tier = base_reward_tier + event_number_bonus + optional_difficulty_bonus`

Invalid states:

- Active event has no countdown.
- Active event has no success reward pool.
- Event spawns unreachable.
- Reward draft has not exactly 3 choices.
- Event remains active after boss/finale starts unless explicitly boss-compatible.

## Edge Cases

- If player reaches event after countdown expires, failure consequence applies.
- If event objective object is destroyed, event fails or switches to rescue/repair fallback by event data.
- If boss starts while event is active, event resolves by data policy: fail, cancel, or convert to boss-compatible objective.
- If reward pool produces fewer than 3 choices, draft fallback fills choices.
- If event anchor is blocked by Pagecraft or enemies, marker remains visible and objective area must still be reachable.
- If pet rescue event succeeds but pet system is absent, store unlock/progress event for later or warn in prototype.

## Dependencies

- **Resource Data Schemas**: Required Page Event data.
- **Run Director and Finite Spawning**: Required scheduling.
- **Pagecraft Materials and Grid**: Required for page objectives.
- **XP, Leveling, and Upgrade Drafts**: Required reward drafts.
- **In-Run HUD and Draft UI**: Required player-facing timer/progress.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `event_spawn_times_seconds` | `300,600,900,1200` | fixed MVP | Root GDD rule. |
| `event_duration_seconds` | `180` | fixed MVP | 3-minute countdown. |
| `minimum_event_count_mvp` | `10` | `10+` | Root GDD content target. |
| `event_reward_tier_bonus` | `1` | `0-5` | Stronger than normal level-up. |
| `objective_marker_radius_m` | `2.5` | `0.5-10.0` | Readability tuning. |

## Visual/Audio Requirements

- Event anchors need strong silhouettes on paper ground.
- Countdown warning needs visible and audible escalation.
- Success should feel celebratory; failure should be clear but not punishingly obscure.
- Objective progress visuals must not hide enemy danger.

## UI Requirements

- HUD shows current Page Event objective, countdown, progress, and distance/edge marker.
- Reward uses 3-choice draft UI.
- Failure/success messages are short and action-focused.
- Debug overlay shows active event ID, progress, timer, reward pool, and consequence.

## Acceptance Criteria

- Events can spawn at 5/10/15/20 with 3-minute countdowns.
- Event objectives can track progress and resolve success/failure.
- Success opens a stronger 3-choice reward draft.
- Failure applies a defined consequence.
- Events integrate with finite map markers and stop/resolve at boss start.

## Open Questions

- Exact first 10 event names can follow root GDD production spec during content implementation.
- Pet rescue persistence belongs to Pets/Save later.

