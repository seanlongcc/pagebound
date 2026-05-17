# In-Run HUD and Draft UI

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-16
> **Implements Pillar**: Simple Controls, Deep Pagecraft

## Overview

`In-Run HUD and Draft UI` defines the MVP gameplay HUD, level-up/reward draft modal, event/boss banner priority, loadout display, objective markers, pet feedback, and keyboard/gamepad navigation rules. It owns player-facing run UI presentation. It does not own gameplay calculations, reward eligibility, input bindings, or save/meta screens.

Design source consulted: `PAGEBOUND_CODEX_GDD_v1_5.md`; `design/gdd/xp-leveling-and-upgrade-drafts.md`; `design/gdd/page-events-and-objectives.md`; `design/gdd/boss-and-victory-flow.md`; first polished exemplar grilling session, 2026-05-14; HUD prototype at `prototypes/ui/pagebound-hud-live.html`.

## Player Fantasy

The HUD should look like a readable storybook margin around the action. It should tell the player what matters now: health, level, XP progress, weapons, items, current event or boss, and pet pickup feedback.

## Detailed Design

### Core Rules

1. UI uses shell `CanvasLayer` with existing slots: `HUD`, `ModalLayer`, `LevelUpScreen`, `PauseMenu`, `VictoryScreen`, and `DebugOverlay`.
2. HUD visual direction is storybook inspired: parchment, ink, ribbon, embossed paper, readable contrast, and compact fairytale labeling.
3. Top-left HUD space shows the solo kill counter in the current prototype. Future party/multiplayer ally portraits must share or replace that space intentionally.
4. Top-right HUD slot is exclusive: it shows either the active Page Event banner or the active boss/finale banner, never both.
5. Page Events and bosses must not overlap by schedule. If the boss waits on an event, the event banner remains until event resolution, then boss banner takes over.
6. Page Event banner shows percent progress as primary information. Count and timer are secondary.
7. Boss banner shows boss name/state and HP percent as primary information.
8. Bottom edge of the screen is the run XP bar. It fills horizontally only.
9. XP bar displays XP percentage on the bar itself, not raw current/needed XP.
10. Run level lives at bottom-left near the XP bar.
11. A small pet icon sits near the level badge and mirrors pet world feedback.
12. Player HP must be large enough to read during combat and stronger than the tiny prototype bar.
13. Loadout toolbar shows 10 slots from the start: 5 weapon slots and 5 passive item slots.
14. Toolbar does not include pets.
15. Toolbar does not need visible `weapon` or `item` text labels; slot order and icons should make category obvious.
16. Draft UI shows exactly 3 choices for normal level-up and Page Event reward drafts.
17. Draft choices support keyboard and gamepad navigation with no hover-only behavior.
18. HUD never recomputes gameplay eligibility; it displays supplied choices/state.
19. Debug overlay is hidden by default and developer-facing.

### First Polished Exemplar HUD Layout

| Area | Content |
|---|---|
| Top-left | Solo kill counter. Future party/multiplayer portraits may share or replace this slot. |
| Top-right | Exclusive event/boss banner. Color Well uses percent progress; Crownless Echo uses HP percent. |
| Center/world | Event circle ring/fill, offscreen marker, pet pickup pulses, damage numbers. |
| Bottom-left | Run level badge, dash recharge meter, plus Dog icon feedback. |
| Bottom edge | Full-width XP bar with percentage text. |
| Bottom center/right | 10-slot loadout: 5 weapons, 5 items. Pets excluded. |
| Health | Larger readable HP bar near bottom HUD cluster. |

The current browser mockup is a prototype reference, not a final art spec: `prototypes/ui/pagebound-hud-live.html`.

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
| XP, Leveling, and Upgrade Drafts | Upstream | Provides draft choices, XP percentage, and run level. |
| Page Events and Objectives | Upstream | Provides objective name, percent, timer, count, and marker target. |
| Boss and Victory Flow | Upstream | Provides boss warning/health/victory summary and exclusive banner state. |
| Weapons and Auto-Attacks | Upstream | Provides 5 weapon slots/levels/icons. |
| Passive Items and Drafts | Upstream | Provides 5 item slots/levels/icons. |
| Pets and Companion Combat | Upstream | Provides Dog icon feedback pulse and pickup-assist event. |
| Damage Numbers and Combat Feedback | Peer | Coordinates world feedback and clutter options. |

## Formulas

`draft_card_count = 3`

`event_timer_display = ceil(event_time_remaining_seconds)`

`event_progress_percent = floor(event_progress_ratio * 100)`

`boss_hp_percent = ceil(current_boss_hp / max_boss_hp * 100)`

`xp_progress_ratio = clamp(current_xp / xp_threshold, 0, 1)`

`xp_progress_percent = floor(xp_progress_ratio * 100)`

`offscreen_marker_direction = normalize(projected_target_position - screen_center)`

Invalid states:

- Draft UI shows not exactly 3 choices.
- Modal has no focused/default selectable card.
- UI recomputes draft eligibility instead of displaying supplied choices.
- HUD blocks gameplay input when no modal is visible.
- Player-facing UI shows raw placeholder/debug labels in release content.
- Page Event and boss banners display simultaneously.
- Pet appears as a loadout toolbar slot.
- XP bar grows vertically or from the left edge of the screen.

## Edge Cases

- If draft opens while another modal is visible, modal priority decides order: victory > pause > draft > HUD.
- If gamepad disconnects during modal, keyboard navigation remains valid.
- If icon missing in prototype content, use approved placeholder icon and log warning.
- If text overflows card/container, UI must wrap/resize within constraints.
- If boss start waits for active event, keep event banner until event resolves, then switch to boss banner.
- If damage numbers clutter HUD, combat feedback reduces/suppresses numbers before HUD hides required info.

## Dependencies

- **Godot Project Shell**: Required UI slots.
- **Input and Rebinding**: Required navigation.
- **Resource Data Schemas**: Required display metadata.
- **XP, Leveling, and Upgrade Drafts**: Required draft choices and XP state.
- **Page Events and Objectives**: Required event HUD data.
- **Boss and Victory Flow**: Required boss/victory data.
- **Pets and Companion Combat**: Required pet icon feedback.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `draft_card_count` | `3` | fixed | Current draft rule. |
| `event_timer_warning_seconds` | `15` first exemplar | `5-90` | Countdown emphasis. |
| `boss_warning_seconds` | `10` first exemplar | `5-120` | Pre-boss UI warning. |
| `hud_opacity` | `1.0` | `0.4-1.0` | Accessibility/options later. |
| `marker_edge_padding_px` | `32` | `8-96` | Offscreen marker spacing. |
| `hp_bar_min_width_px` | prototype tuned | `120+` | Must be readable under pressure. |
| `xp_bar_height_px` | prototype tuned | `10+` | Full-width bottom bar. |

## Visual/Audio Requirements

- UI should support cute storybook/paper/card presentation without becoming beige-only or low-contrast.
- Draft cards need icon area, title, level/category, description, rarity/style treatment, and compatibility hints.
- HUD elements must be compact and scan-friendly for repeated play.
- Pet pickup feedback should pulse both in world and on the pet icon.
- UI SFX hooks include draft open, card move, card select, event warning, boss warning, victory, pet fetch pulse, and XP fill.

## UI Requirements

- HUD slot: health, top-left kill counter, full-bottom XP bar, run level, loadout, event/boss banner, markers, pet icon.
- LevelUpScreen slot: 3-card draft with focused card, accept/cancel rules, device prompts.
- PauseMenu slot: resume/options/quit-to-hub placeholders until menu system expands.
- VictoryScreen slot: run summary and rewards handoff.
- DebugOverlay slot: FPS, pools, events, player state, Pagecraft, director/boss state.

## Acceptance Criteria

- HUD can display core run state without gameplay logic.
- Top-left shows the solo kill counter.
- Top-right banner is exclusive for event or boss.
- Event banner shows percent progress.
- Boss banner shows HP percent.
- Bottom XP bar fills horizontally only and displays percentage on-bar.
- Run level, dash recharge meter, and Dog icon sit near bottom-left.
- Loadout shows 5 weapon slots and 5 item slots, with no pet slot.
- HP bar is readable at combat scale.
- Draft modal displays exactly 3 supplied choices and returns selected choice.
- Draft cards show category, rarity, icon label, title, stat delta, description, level delta, and deduplicated tags; slot state and evolution hint lines are omitted.
- UI supports keyboard/gamepad navigation and prompt metadata.
- Debug overlay remains hidden by default and developer-only.

## Open Questions

- Final UI art/style waits for asset direction pass and UI asset provenance.
- Pause/options details belong to Accessibility and Options later.
