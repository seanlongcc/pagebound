# Camera and 2.5D Lighting

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: True 2.5D Diorama Lighting

## Overview

`Camera and 2.5D Lighting` defines the playable camera rig, zoom rules, lighting presets, shadows, and readability contract for Pagebound's true 2.5D paper diorama. It owns framing and lighting behavior. It does not own player movement, map geometry, Pagecraft simulation, UI layout, or final art production.

## Player Fantasy

The game should look like a physical storybook page under real light. The player should read enemies, marks, pickups, pets, boss attacks, and objectives without fighting the camera.

## Detailed Design

### Core Rules

1. The game uses Godot 3D runtime with `Camera3D`, `DirectionalLight3D`, and `WorldEnvironment`.
2. Camera views the X/Z gameplay plane from a perspective top-down angle.
3. Camera follows the active player target with smoothing but must not lag enough to hide danger.
4. Camera can zoom out for boss fights, major Page Events, high density, and later co-op spread.
5. Camera bounds respect finite chapter map bounds and avoid showing empty void outside the page when possible.
6. Lighting uses real shadows for player, bosses, elites, major props, and raised paper geometry.
7. Sprite/card actors may billboard toward camera while staying grounded in the 3D world.
8. Visual readability beats dramatic lighting; combat silhouettes must stay clear.
9. Lighting presets are data-driven per chapter and can be overridden for boss/page event states.
10. Shell placeholder lighting remains valid until this system takes ownership.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `PlaceholderView` | Shell default camera/light are active. | `FollowReady` |
| `FollowReady` | Camera follows player with default run framing. | `EventFocus`, `BossFocus`, `CinematicLock` |
| `EventFocus` | Camera biases or zooms for Page Event readability. | `FollowReady`, `BossFocus` |
| `BossFocus` | Camera zooms/framing adjust for boss arena and telegraphs. | `FollowReady`, `CinematicLock` |
| `CinematicLock` | Temporary authored framing for intro/victory/death. | `FollowReady` |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Godot Project Shell | Upstream | Provides `CameraRig/Camera3D` and `Lighting` roots. |
| Player Controller and Dash | Upstream | Provides follow target, velocity, dash state, and player bounds. |
| Chapter and Map Construction | Downstream | Provides finite bounds, lighting preset, camera anchors, and page edge masks. |
| Page Events and Objectives | Downstream | Requests temporary event framing and edge markers. |
| Boss and Victory Flow | Downstream | Requests boss zoom, warning framing, victory framing. |
| In-Run HUD and Draft UI | Downstream | Needs safe framing and projection helpers for offscreen markers. |

## Formulas

`follow_target = player_position + velocity * lookahead_seconds`

`camera_position = smooth_damp(camera_position, clamped_follow_target, follow_smoothing)`

`target_zoom = max(base_zoom, event_zoom, boss_zoom, co_op_zoom)`

`framed_width_meters = camera_projection_width_at_page_plane`

Invalid states:

- Camera sees only blank page or black environment during active run.
- Camera exits finite page bounds without an intentional edge presentation.
- Lighting preset makes enemies, telegraphs, or Pagecraft marks unreadable.
- UI relies on camera zoom values not exposed by this system.

## Edge Cases

- If player target is missing, camera holds last valid position and logs warning.
- If player reaches map edge, camera clamps while preserving player visibility.
- If boss and Page Event request zoom together, boss focus wins after 30:00.
- If heavy VFX hides telegraphs, lighting/camera do not solve it alone; feedback systems must reduce clutter.
- If sprites/card actors pop at steep angles, billboard mode or camera pitch is adjusted before final art import.

## Dependencies

- **Godot Project Shell**: Required camera/light nodes.
- **Player Controller and Dash**: Required follow target.
- **Chapter and Map Construction**: Later source for bounds and presets.
- **Boss and Victory Flow**: Later source for boss camera states.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `camera_pitch_degrees` | `55` | `45-65` | Top-down perspective angle. |
| `framed_width_meters` | `34` | `28-40` | Root GDD target combat view. |
| `follow_smoothing` | `0.12 s` | `0.04-0.30` | Lower is snappier. |
| `lookahead_seconds` | `0.25` | `0.0-0.6` | Movement lookahead. |
| `boss_zoom_multiplier` | `1.15` | `1.0-1.4` | Wider boss framing. |
| `shadow_enabled` | `true` | bool | Disable only for performance fallback. |

## Visual/Audio Requirements

- Paper ground must show tactile depth under light.
- Shadows should reinforce diorama feel without hiding collision clarity.
- Camera movement must avoid nausea-inducing shake during normal combat.
- Audio is not owned here, but camera state may publish focus state for music layers.

## UI Requirements

- HUD safe area must remain readable at all zoom levels.
- Edge markers need world-to-screen projection support.
- Debug overlay needs current zoom/framed width, camera mode, target, and lighting preset ID.

## Acceptance Criteria

- Camera follows the player on X/Z and keeps the paper battlefield visible.
- Directional light and environment produce nonblank readable first gameplay frame.
- Camera can switch to boss/event zoom without moving UI slots.
- Finite chapter bounds can clamp camera position.
- Lighting preset data can be referenced by chapter resources.

## Open Questions

- Exact chapter lighting palettes belong to Art Bible and Chapter GDDs.
- Steam Deck performance fallback for shadows remains profiling-driven.
