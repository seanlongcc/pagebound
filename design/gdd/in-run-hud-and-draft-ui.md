# In-Run HUD and Draft UI

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Simple Controls, Deep Pagecraft

## Overview

`In-Run HUD and Draft UI` defines the MVP gameplay HUD, level-up/reward draft modal, boss/event indicators, loadout display, objective markers, pause/victory slot usage, and keyboard/gamepad navigation rules. It owns player-facing run UI presentation. It does not own gameplay calculations, reward eligibility, input bindings, or save/meta screens.

## Player Fantasy

The HUD should keep the player oriented without smothering the page. Drafts should be fast, readable, and exciting: three clear cards, one decisive pick, back to chaos.

## Detailed Design

### Core Rules

1. UI uses shell `CanvasLayer` with existing slots: `HUD`, `ModalLayer`, `LevelUpScreen`, `PauseMenu`, `VictoryScreen`, and `DebugOverlay`.
2. HUD shows health, run XP, run level, timer, weapon slots, passive slots, current Page Event timer/objective, boss warning/health, currency pickups when relevant, and offscreen markers.
3. Draft UI shows exactly 3 choices for normal level-up, Page Event, elite/chest, and boss reward drafts.
4. Draft choices support keyboard and gamepad navigation with no hover-only behavior.
5. Modal draft pauses or slows gameplay according to runtime policy; UI only requests state change.
6. HUD must remain readable over bright paper, Pagecraft marks, damage numbers, and boss VFX.
7. UI consumes content metadata from resources: names, icons, descriptions, rarity, tags, level text.
8. Debug overlay is hidden by default and developer-facing.
9. Pause and victory screens use shell slots but detailed menu systems can expand later.
10. UI never recomputes gameplay eligibility; it displays supplied choices/state.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `HUDOnly` | Normal gameplay HUD visible, no modal. | `DraftModal`, `PauseModal`, `VictoryModal`, `Hidden` |
| `DraftModal` | Three-choice draft is focused. | `HUDOnly`, `VictoryModal`, `Hidden` |
| `PauseModal` | Pause menu is focused. | `HUDOnly`, `Hidden` |
| `VictoryModal` | Victory/summary flow is visible. | `Hidden` |
| `Hidden` | UI hidden for boot/cinematic/tests. | `HUDOnly`, `VictoryModal` |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Godot Project Shell | Upstream | Provides CanvasLayer and slot topology. |
| Input and Rebinding | Upstream | Provides UI navigation, accept/cancel, prompt metadata. |
| XP, Leveling, and Upgrade Drafts | Upstream | Provides draft choices and selection callbacks. |
| Page Events and Objectives | Upstream | Provides objective text, timer, progress, markers. |
| Boss and Victory Flow | Upstream | Provides boss warning/health/victory summary. |
| Weapons and Auto-Attacks | Upstream | Provides loadout slots/levels/icons. |
| Passive Items and Drafts | Upstream | Provides item slots/levels/icons. |
| Damage Numbers and Combat Feedback | Peer | Coordinates modal visibility and clutter options. |

## Formulas

`draft_card_count = 3`

`event_timer_display = ceil(event_time_remaining_seconds)`

`xp_progress_ratio = clamp(current_xp / xp_threshold, 0, 1)`

`offscreen_marker_direction = normalize(projected_target_position - screen_center)`

Invalid states:

- Normal draft UI shows not exactly 3 choices.
- Modal has no focused/default selectable card.
- UI recomputes draft eligibility instead of displaying supplied choices.
- HUD blocks gameplay input when no modal is visible.
- Player-facing UI shows raw placeholder/debug labels in release content.

## Edge Cases

- If draft opens while another modal is visible, modal priority decides order: victory > pause > draft > HUD.
- If gamepad disconnects during modal, keyboard navigation remains valid.
- If icon missing in prototype content, use approved placeholder icon and log warning.
- If text overflows card/container, UI must wrap/resize within constraints.
- If Page Event and boss warning overlap, boss warning takes priority after 30:00.
- If damage numbers clutter HUD, combat feedback reduces/suppresses numbers before HUD hides required info.

## Dependencies

- **Godot Project Shell**: Required UI slots.
- **Input and Rebinding**: Required navigation.
- **Resource Data Schemas**: Required display metadata.
- **XP, Leveling, and Upgrade Drafts**: Required draft choices.
- **Page Events and Objectives**: Required event HUD data.
- **Boss and Victory Flow**: Required boss/victory data.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `draft_card_count` | `3` | fixed | Root GDD rule. |
| `event_timer_warning_seconds` | `30` | `5-90` | Countdown emphasis. |
| `boss_warning_seconds` | `30` | `5-120` | Pre-boss UI warning. |
| `hud_opacity` | `1.0` | `0.4-1.0` | Accessibility/options later. |
| `marker_edge_padding_px` | `32` | `8-96` | Offscreen marker spacing. |

## Visual/Audio Requirements

- UI should support cute storybook/paper/card presentation without becoming beige-only or low-contrast.
- Draft cards need icon area, title, level/category, description, rarity, and tag/compatibility hints.
- HUD elements must be compact and scan-friendly for repeated play.
- UI SFX hooks include draft open, card move, card select, event warning, boss warning, victory.

## UI Requirements

- HUD slot: health, XP, run level, timer, loadout, event/boss objective, markers.
- LevelUpScreen slot: 3-card draft with focused card, accept/cancel rules, device prompts.
- PauseMenu slot: resume/options/quit-to-hub placeholders until menu system expands.
- VictoryScreen slot: run summary and rewards handoff.
- DebugOverlay slot: FPS, pools, events, player state, Pagecraft, director/boss state.

## Acceptance Criteria

- HUD can display core run state without gameplay logic.
- Draft modal displays exactly 3 supplied choices and returns selected choice.
- UI supports keyboard/gamepad navigation and prompt metadata.
- Page Event and boss HUD states have priority rules.
- Debug overlay remains hidden by default and developer-only.

## Open Questions

- Exact final UI art/style waits for asset direction pass and UI asset provenance.
- Pause/options details belong to Accessibility and Options later.
