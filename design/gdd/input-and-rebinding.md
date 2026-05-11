# Input and Rebinding

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Simple Controls, Deep Pagecraft

## Overview

`Input and Rebinding` defines Pagebound's player input actions, device support, rebinding rules, prompt metadata, and input handoff to gameplay/UI systems. It owns action maps and input interpretation only. It does not own player movement, dash physics, pause behavior, draft UI layout, or accessibility options beyond providing bindable actions.

## Player Fantasy

Controls should disappear. The player moves, dashes, confirms rewards, and pauses without thinking about devices or key names. Good input makes Pagebound feel approachable on keyboard and gamepad while leaving mastery to positioning, dash timing, build choices, and Pagecraft interactions.

## Detailed Design

### Core Rules

1. MVP supports keyboard/mouse and gamepad. Touch is out of scope.
2. Combat does not require precision aiming; movement and dash are the only moment-to-moment gameplay inputs.
3. Required gameplay actions are `move_left`, `move_right`, `move_up`, `move_down`, `dash`, `interact`, and `pause`.
4. Required UI actions are `ui_up`, `ui_down`, `ui_left`, `ui_right`, `ui_accept`, `ui_cancel`, and `ui_focus_next`.
5. Default keyboard bindings are WASD/arrow movement, Space dash, E interact/confirm, Escape pause/cancel, Enter accept.
6. Default gamepad bindings are left stick/D-pad movement, south face button dash/accept when context allows, west or north face button interact, Start pause, east face button cancel.
7. Rebinding must prevent one device profile from having two conflicting required actions unless the conflict is explicitly allowed by context.
8. Input state exposes normalized movement vector, device family, last active device, and just-pressed action edges.
9. Gameplay systems consume input through a small typed access layer, not direct string lookups scattered across scripts.
10. Rebinding changes are local profile data and must be saveable later by `Save, Profile, and Migration`.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `DefaultBindings` | Project settings contain canonical actions and defaults. | `RuntimeInputReady`, `Rebinding` |
| `RuntimeInputReady` | Input actions are active and gameplay/UI can query them. | `Rebinding`, `DeviceChanged` |
| `DeviceChanged` | Last active device family changed by new input. | `RuntimeInputReady` |
| `Rebinding` | UI is waiting for a new input event for one action. | `RuntimeInputReady`, `RebindRejected` |
| `RebindRejected` | Candidate input is invalid, reserved, or conflicting. | `Rebinding`, `RuntimeInputReady` |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Godot Project Shell | Upstream | Shell boots before this system and exposes UI slots later used for rebinding screens. |
| Player Controller and Dash | Downstream | Consumes normalized move vector, dash edge, interact edge, and last movement direction support. |
| In-Run HUD and Draft UI | Downstream | Consumes UI navigation, accept/cancel actions, device prompts, and focus handoff. |
| Accessibility and Options | Downstream | Consumes binding metadata and prompt labels for options menus. |
| Save, Profile, and Migration | Downstream | Persists custom bindings and restores them before gameplay input begins. |

## Formulas

`raw_move = Vector2(action_strength(move_right) - action_strength(move_left), action_strength(move_down) - action_strength(move_up))`

`move_vector = raw_move.normalized() if raw_move.length() > 1.0 else raw_move`

`rebind_allowed = candidate_input not in reserved_inputs and conflict_count == 0`

Invalid states:

- Required action missing from project settings.
- Movement vector length greater than 1.0 after normalization.
- Required action has no binding for keyboard or gamepad default profile.
- Rebind candidate removes the final valid binding for a required action.

## Edge Cases

- If keyboard and gamepad input happen in the same frame, the last nonzero input event updates the active device.
- If a gamepad disconnects, keyboard remains valid and gameplay must not crash.
- If dash and UI accept share a button, the focused modal context owns the button while visible.
- If player gives no movement input, dash consumers use last nonzero movement direction.
- If a rebinding candidate is Escape/Start during rebinding, it cancels instead of assigning unless explicitly requested by UI flow.
- If a saved binding references a missing device or invalid event type, defaults are restored and a warning is logged.

## Dependencies

- **Godot Project Shell**: Required for project boot and UI slots.
- **Godot InputMap**: Required action storage.
- **Save, Profile, and Migration**: Later persistence consumer.
- **Accessibility and Options**: Later UI/options consumer.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `analog_deadzone` | `0.20` | `0.05-0.40` | Applied before movement normalization. |
| `device_switch_cooldown_ms` | `100` | `0-500` | Prevents prompt flicker from noisy devices. |
| `rebind_timeout_seconds` | `10.0` | `3.0-30.0` | Time before rebinding returns to previous binding. |
| `allow_contextual_dash_accept_overlap` | `true` | bool | Allows gamepad south button in gameplay and UI contexts. |

## Visual/Audio Requirements

- Input has no world visuals.
- UI prompt glyphs must distinguish keyboard, mouse, and gamepad.
- Rebind success/failure may trigger UI SFX later through audio metadata.

## UI Requirements

- Rebinding UI must support keyboard and gamepad navigation.
- Each action row shows action name, current bindings, device family, and conflict state.
- Rebind failure messages use player-readable text, not raw Godot event names.
- Gameplay HUD can request current prompt text for interact/Page Event prompts.

## Acceptance Criteria

- All required actions are defined in `project.godot` or setup code.
- Keyboard and gamepad defaults exist for movement, dash, interact, pause, accept, and cancel.
- Input layer returns a normalized movement vector and just-pressed edges.
- Rebinding rejects duplicate required bindings in the same context.
- Player controller can be implemented without direct `InputMap` string scattering.

## Open Questions

- Exact glyph art source remains open until UI asset selection.
- Steam Deck-specific glyph rules move to Accessibility/Options polish.

