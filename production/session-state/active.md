# Active Session State

**Task**: Hardened First 5-Minute Vertical Slice Foundation
**Status**: Implemented and smoke validated
**Stage**: Technical Setup
**Review Mode**: lean
**Current Section**: First 5-minute vertical slice UI/flow, pacing, draft breadth, and 5:00 summary on `feat/mvp`

## Files

- `PAGEBOUND_CODEX_GDD_v1_5.md`
- `production/project-stage-report.md`
- `docs/adoption-plan-2026-05-10.md`
- `design/gdd/game-concept.md`
- `design/gdd/systems-index.md`
- `.codex/docs/technical-preferences.md`
- `docs/engine-reference/godot/VERSION.md`
- `design/gdd/godot-project-shell.md`
- `design/gdd/reviews/godot-project-shell-review-log.md`
- `project.godot`
- `Main.tscn`
- `src/shell/game_bootstrap.gd`
- `src/shell/shell_refs.gd`
- `src/shell/shell_validation_result.gd`
- `tests/smoke/shell_smoke_check.gd`
- `addons/godot_ai/`
- `production/assets/local-asset-library.md`
- `design/gdd/resource-data-schemas.md`
- `design/gdd/input-and-rebinding.md`
- `design/gdd/player-controller-and-dash.md`
- `design/gdd/camera-and-2-5d-lighting.md`
- `design/gdd/runtime-event-bus.md`
- `design/gdd/object-pooling-and-performance-debug.md`
- `design/gdd/damage-and-status-model.md`
- `design/gdd/weapons-and-auto-attacks.md`
- `design/gdd/passive-items-and-drafts.md`
- `design/gdd/xp-leveling-and-upgrade-drafts.md`
- `design/gdd/evolution-system.md`
- `design/gdd/pagecraft-materials-and-grid.md`
- `design/gdd/enemies-and-ai-movement.md`
- `design/gdd/run-director-and-finite-spawning.md`
- `design/gdd/page-events-and-objectives.md`
- `design/gdd/boss-and-victory-flow.md`
- `design/gdd/damage-numbers-and-combat-feedback.md`
- `design/gdd/in-run-hud-and-draft-ui.md`
- `design/gdd/reviews/mvp-systems-design-review-2026-05-11.md`
- `production/gates/systems-design-to-technical-setup-2026-05-11.md`
- `docs/architecture/ADR-0001-resource-schema-foundation.md`
- `docs/architecture/ADR-0002-first-playable-player-input.md`
- `docs/architecture/ADR-0003-gameplay-camera-follow.md`
- `docs/architecture/ADR-0004-runtime-events-damage-model.md`
- `docs/architecture/ADR-0005-pooled-damage-feedback.md`
- `docs/architecture/ADR-0006-first-combat-prototype.md`
- `docs/architecture/ADR-0007-pagecraft-mvp-hook.md`
- `src/data/`
- `src/input/`
- `src/player/`
- `src/camera/`
- `src/events/`
- `src/combat/`
- `src/pooling/`
- `src/feedback/`
- `src/enemies/`
- `src/weapons/`
- `src/pagecraft/`
- `src/runtime/first_playable_runtime.gd`
- `src/runtime/run_director.gd`
- `src/runtime/run_level_tracker.gd`
- `src/runtime/run_draft_controller.gd`
- `src/runtime/run_upgrade_state.gd`
- `src/runtime/run_menu_controller.gd`
- `src/runtime/page_event_controller.gd`
- `src/pickups/`
- `data/weapons/prototype_waxlight_comet.tres`
- `data/weapons/prototype_star_sticker_swarm.tres`
- `data/enemies/prototype_inkling_chaser.tres`
- `data/enemies/prototype_paper_scrap_swarmer.tres`
- `data/passives/prototype_candle_spark.tres`
- `data/upgrades/waxlight_damage_plus_1.tres`
- `data/upgrades/waxlight_cooldown_minus_10.tres`
- `data/upgrades/waxlight_duration_plus_1.tres`
- `data/upgrades/waxlight_mark_cap_plus_2.tres`
- `data/upgrades/player_max_hp_plus_10.tres`
- `tests/smoke/schema_smoke_check.gd`
- `tests/smoke/player_movement_smoke_check.gd`
- `tests/smoke/camera_follow_smoke_check.gd`
- `tests/smoke/camera_readability_smoke_check.gd`
- `tests/smoke/damage_model_smoke_check.gd`
- `tests/smoke/damage_numbers_smoke_check.gd`
- `tests/smoke/combat_prototype_smoke_check.gd`
- `tests/smoke/pagecraft_smoke_check.gd`
- `tests/smoke/waxlight_dash_damage_smoke_check.gd`
- `tests/smoke/waxlight_contact_decay_smoke_check.gd`
- `tests/smoke/first_playable_smoke_check.gd`
- `tests/smoke/xp_pickup_smoke_check.gd`
- `tests/smoke/player_death_flow_smoke_check.gd`
- `tests/smoke/run_level_smoke_check.gd`
- `tests/smoke/draft_choice_smoke_check.gd`
- `tests/smoke/upgrade_effects_smoke_check.gd`
- `tests/smoke/run_director_smoke_check.gd`
- `tests/smoke/director_time_bands_smoke_check.gd`
- `tests/smoke/enemy_loop_smoke_check.gd`
- `tests/smoke/hud_counters_smoke_check.gd`
- `tests/smoke/page_bounds_smoke_check.gd`
- `tests/smoke/vertical_slice_mvp_smoke_check.gd`

## Next

First 5-minute vertical slice foundation is now in place with primitive placeholders only. Next practical work: extract `src/runtime/first_playable_runtime.gd` below the local 800-line guardrail, continue moving prototype runtime tuning into focused `.tres` content, add more documented weapon/passive choices, add Page Events/boss timing beyond the first Color Well objective, and replace primitive placeholders only after asset provenance is recorded.

## Current Vertical Slice Facts

- Boot now shows a start menu. Run timer, director spawning, weapon firing, pickups, and player control remain idle until keyboard/gamepad accept or Start Run begins gameplay.
- Death and victory/summary screens share Retry and Main Menu flow. Retry resets HP, XP, level, enemies, pickups, marks, director time, upgrades, draft state, page event state, and runtime counters.
- Opening enemy pacing uses only `inkling_chaser` until the 60s pressure band. `paper_scrap_swarmer` joins after 60s.
- Opening `inkling_chaser` HP is authored as two starting Waxlight hits. Early health scaling is a readable time-band multiplier: `1.0` opening, `1.15` at 60s, `1.3` at 120s, `1.5` at 240s.
- Spawn pressure is time-band driven through target budget, interval, and batch size. The gameplay pacing cap was replaced with a high `safety_enemy_cap` of 120 for runaway protection only.
- Dash prototype tune is shorter: `dash_speed = 14.0`, `dash_active_seconds = 0.15`, expected travel `2.1m`, with dash activation still triggering crossed Waxlight marks.
- Runtime HUD now shows HP/max HP, level/XP, Waxlight damage, cooldown, active duration, inactive cap, inactive/active mark counts, director rate/band/budget/spawned/active/safety, page event state, weapons, and passives.
- Draft UI now presents exactly 3 horizontal choices with title, current value, new value, and short effect text. Draft eligibility includes owned weapon upgrades, new documented weapon choices, documented passives, existing Waxlight/player stat upgrades, and fallback stat choices with prototype 5 weapon / 5 passive slot limits.
- Prototype data now loads authored `.tres` resources for Waxlight weapon tuning, Star Sticker weapon tuning, enemy families, Candle Spark passive, and upgrade metadata/effects, with fallback factory content retained.
- Documented second weapon chosen: `star_sticker_swarm`. Reason: documented early-run MVP weapon in the main GDD example, distinct from Waxlight through burst hits, star sticker mark feedback, and multi-target primitive feedback. Damage routes through `DamageModel`.
- Documented first passive chosen: `candle_spark`. Reason: documented first passive in the main GDD example and catalyst-compatible with Waxlight/Firelight-style play. Prototype effect increases glow/Waxlight runtime damage and appears in HUD stats.
- Documented first Page Event/objective chosen: `fill_color_well`. Reason: documented MVP Page Event. Prototype starts at 5:00, shows objective text/progress on HUD, gains progress from kills/mark activation, applies light pressure while active, and is visible on the vertical-slice endpoint.
- 5:00 vertical-slice end condition now stops gameplay and shows summary with time survived, level, XP collected, enemies defeated, weapons, and passives.
- Large-file note: `src/runtime/first_playable_runtime.gd` is now 925 lines. The change kept most new gameplay behavior in focused helpers/controllers, but this orchestration file still grew past the 800-line guardrail and should be the next extraction target.

## Validation

- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/shell_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/schema_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/player_movement_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/camera_follow_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/camera_readability_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/damage_model_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/damage_numbers_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/combat_prototype_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/pagecraft_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/waxlight_dash_damage_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/waxlight_contact_decay_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/xp_pickup_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/player_death_flow_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/run_level_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/draft_choice_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/upgrade_effects_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/run_director_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/director_time_bands_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/enemy_loop_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/hud_counters_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/page_bounds_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/vertical_slice_mvp_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/first_playable_smoke_check.gd` passed.
- Full `tests/smoke/*.gd` suite passed on 2026-05-11.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --quit-after 1` ran the configured main scene without shell validation errors.
- Godot AI addon is copied to `addons/godot_ai/` and enabled in `project.godot`; MCP endpoint `http://127.0.0.1:8000/mcp` is not running until the Godot editor opens with the plugin active.
- MVP Systems Design gate passed on 2026-05-11 with accepted risks documented in `production/gates/systems-design-to-technical-setup-2026-05-11.md`.
- First playable behavior: `Main.tscn` boots to a start menu, runtime creates a primitive player, input actions, more top-down camera follow, runtime event bus, damage model, pooled damage numbers, a scene-owned run director with early pressure time bands, two placeholder enemy families (`inkling_chaser` and delayed `paper_scrap_swarmer`), Waxlight Comet plus draft-acquired Star Sticker Swarm, documented Candle Spark passive, visible runtime stats HUD, collectible Color Mote XP drops with magnet pull range, run XP thresholds, level-up event flow, exactly 3 horizontal draft choices, runtime upgrades for Waxlight damage, Waxlight duration, Waxlight unactivated mark cap, Waxlight cooldown, and player max HP, finite page bounds clamp, finite spawn bounds, visible Pagecraft marks, dash activation into finite active Waxlight zones, contact-only active Waxlight damage through DamageModel, activated mark decay, unactivated mark cap enforcement, primitive Waxlight dash pulse visuals, 5:00 Fill the Color Well event/objective, and 5:00 victory summary. XP awards only after pickup collection. Player death now opens a `Run Over` death screen with Retry/Main Menu, pauses/stops gameplay, blocks dead-body XP collection, and blocks post-death upgrades/healing. Dead enemies visibly despawn, stop physics, disable collision, and stop being targetable. `move_up`/W moves toward negative Z/page top.
- Current implementation count: 29 GDScript source files, 22 smoke checks, 7 ADRs. No third-party gameplay/art assets imported.

## Asset Direction Pass

- Direction: cohesive cute top-down pixel fantasy sprites/cards presented as Godot 3D `Sprite3D`/card-like objects on a lit finite paper diorama.
- Favor one pixel scale and one creator/family per prototype pass. Do not casually mix 8x8, 16x16, 32x32, voxel, and painterly card packs.
- Current source pool: itch.io fantasy + top-down, Godot + top-down, and fantasy card asset pages. Candidate families to evaluate next include Kenmi `Cute Fantasy RPG`, Pixel Frog `Tiny Swords`, SnowHex top-down packs, and Caz `Pixel Fantasy Playing Cards`.
- No gameplay/art assets were imported. Before any import, record source URL, creator, license, cost, and allowed commercial use.
- Local source library exists at `C:\Users\seanl\Documents\Godot\assets` (`/mnt/c/Users/seanl/Documents/Godot/assets`), about 1.4 GB and 88,427 files. Inventory is recorded in `production/assets/local-asset-library.md`.
- Do not bulk-copy the local source library into this repo. Import curated subsets only, with provenance and license metadata.
