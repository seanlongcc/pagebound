# Player Controller and Dash

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-13
> **Implements Pillar**: Simple Controls, Deep Pagecraft

## Overview

`Player Controller and Dash` defines the MVP player actor: planar X/Z movement, dash state, collision shape, interaction handoff, health hooks, and Pagecraft dash sampling hooks. It owns locomotion and player body state only. It does not own weapon firing, Pagecraft simulation, damage resolution, input rebinding, camera follow tuning, or character progression data.

## Player Fantasy

The hero should feel tiny, nimble, and reliable. Movement is simple, but dash timing matters because the page reacts. The player should trust that when they press dash, the hero commits cleanly through danger and through marks that can turn the fight.

## Detailed Design

### Core Rules

1. MVP player uses `CharacterBody3D` on the X/Z plane with Y as visual height.
2. Movement direction is camera-relative and derived from input system output.
3. The player has no precision aim input requirement.
4. Dash direction uses current movement input; if no input exists, it uses last nonzero movement direction.
5. Dash has startup, active travel, recovery timing, and charge recharge timing so feedback and Pagecraft hooks can attach cleanly.
6. Dash samples the traveled path and emits a dash-path event for Pagecraft; it does not directly mutate Pagecraft.
7. Movement can be slowed, sped up, or blocked by downstream status/Pagecraft systems through typed modifiers.
8. Player scene mounts under `RunRoot/Actors/Players`.
9. Player controller exposes position, velocity, facing direction, dash state, hurt state, and interaction query data.
10. Combat stats come from character/resource data; controller only applies current resolved movement and dash values.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `Spawned` | Player instance exists but runtime refs are not wired. | `MoveReady` |
| `MoveReady` | Player can walk and receive input. | `Dashing`, `HitStun`, `Dead` |
| `Dashing` | Forced dash vector is active and dash path is sampled. | `DashRecover`, `Dead` |
| `DashRecover` | Player can move with recovery limits but cannot dash again. | `MoveReady`, `HitStun`, `Dead` |
| `HitStun` | Temporary interruption after damage if configured. | `MoveReady`, `Dead` |
| `Dead` | Player cannot move; death/victory flow owns next transition. | none |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Godot Project Shell | Upstream | Provides `RunRoot/Actors/Players` mount. |
| Input and Rebinding | Upstream | Provides normalized move vector, dash edge, interact edge. |
| Camera and 2.5D Lighting | Downstream | Follows player position and may read facing/dash state. |
| Damage and Status Model | Bidirectional | Applies damage/status to player and receives player hurt/death events. |
| Pagecraft Materials and Grid | Downstream | Receives dash path samples and returns movement modifiers from terrain marks. |
| Enemies and AI Movement | Downstream | Uses player position as target and collision reference. |
| Runtime Event Bus | Supporting | Publishes `player_spawned`, `player_dashed`, `player_damaged`, `player_died`. |

## Formulas

`desired_velocity = camera_relative_move * move_speed * movement_multiplier`

`dash_distance = dash_speed * dash_active_seconds`

`dash_available = dash_charge_count > 0 and state == MoveReady`

`dash_recharge_ready = dash_recharge_remaining <= 0 and dash_charge_count < max_dash_charges`

`dash_path = segment(dash_start_position, dash_end_position)`

Invalid states:

- Dash active with zero dash direction.
- Player outside chapter bounds without a recovery/clamp rule.
- Player controller directly changing weapon cooldowns or draft state.
- Player body not mounted under `RunRoot/Actors/Players`.

## Edge Cases

- If player spawns before camera exists, movement still works in world axes until camera context arrives.
- If dash path collides with a hard boundary, dash ends at collision point and emits shortened path.
- If Pagecraft slows the player below minimum movement speed, clamp to a small controllable value unless hard-rooted by status.
- If player is hit during dash, invulnerability/interrupt behavior is controlled by dash profile data.
- If input disappears mid-dash, dash continues along committed vector.
- If multiple players exist later for co-op, each player owns its own controller state and input source.

## Dependencies

- **Godot Project Shell**: Required mount roots.
- **Input and Rebinding**: Required input vector and action edges.
- **Resource Data Schemas**: Character and dash profile data.
- **Damage and Status Model**: Health/status hooks.
- **Pagecraft Materials and Grid**: Dash path interactions.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `move_speed` | `7.0 m/s` | `4.0-10.0` | Base player speed before modifiers. |
| `dash_speed` | `14.0 m/s` | `10.0-28.0` | Active dash travel speed. |
| `dash_active_seconds` | `0.15` | `0.08-0.35` | Determines dash distance. |
| `dash_recovery_seconds` | `0.18` | `0.05-0.40` | Post-dash lockout. |
| `max_dash_charges` | `1` | `1-8` | Base charge count before items/character modifiers. |
| `dash_recharge_seconds` | `2.0` | `0.4-4.0` | Time to restore one spent dash charge. |
| `dash_invulnerability_seconds` | `0.15` | `0.0-0.5` | Brief i-frame window during active dash. |
| `dash_invulnerable` | `true` | bool | Can vary by character profile later. |

## Visual/Audio Requirements

- Player placeholder can be primitive/card art until character assets are selected.
- Dash must have a visible trail/cue that reads over paper ground and Pagecraft marks.
- Hit and death cues must be distinguishable from enemy damage.
- Dash SFX should be short and not mask weapon/pet hits.

## UI Requirements

- HUD needs optional dash charge/recharge and player health hooks.
- Debug overlay needs player position, velocity, state, dash charge count, dash recharge, and dash path sample.
- Interact prompts use input system prompt metadata and player interaction query results.

## Acceptance Criteria

- A `CharacterBody3D` player can move on X/Z under the shell's `Players` root.
- Movement is camera-relative and normalized.
- Dash uses current or last movement direction and respects available charges, recharge, and recovery.
- Dash emits or exposes a dash path for Pagecraft without directly owning Pagecraft simulation.
- Controller can run with no weapons, no enemies, and no HUD.

## Open Questions

- Exact starting character dash variants belong to `Character Roster and Mastery`.
- Exact invulnerability tuning remains prototype-driven.
