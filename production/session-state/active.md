# Active Session State

**Task**: MVP Tuning Pass: Draft Weights, Weapon Picks, Pacing, and Page Events
**Status**: Implemented and smoke validated
**Stage**: Technical Setup
**Review Mode**: lean
**Current Section**: MVP tuning pass for rarity-weighted drafts, one-stat upgrade cards, weapon-pick intervals, close-range XP pickup, faster early pacing, passive tag modifiers, draft card layout, and Page Event announcements on `feat/mvp`

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
- `src/runtime/page_event_announcement.gd`
- `src/pickups/`
- `src/weapons/primitive_weapon_effects.gd`
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
- `tests/smoke/draft_layout_scaling_smoke_check.gd`
- `tests/smoke/draft_rarity_weights_smoke_check.gd`
- `tests/smoke/passive_tag_modifier_smoke_check.gd`
- `tests/smoke/upgrade_effects_smoke_check.gd`
- `tests/smoke/run_director_smoke_check.gd`
- `tests/smoke/director_time_bands_smoke_check.gd`
- `tests/smoke/enemy_loop_smoke_check.gd`
- `tests/smoke/hud_counters_smoke_check.gd`
- `tests/smoke/page_bounds_smoke_check.gd`
- `tests/smoke/page_event_timing_smoke_check.gd`
- `tests/smoke/star_sticker_loop_smoke_check.gd`
- `tests/smoke/vertical_slice_mvp_smoke_check.gd`

## Next

First 5-minute vertical slice readability pass is now in place with primitive placeholders only. Next practical work: extract `src/runtime/first_playable_runtime.gd` below the local 800-line guardrail, continue moving prototype runtime tuning into focused `.tres` content, add more documented weapon/passive choices, add Page Events/boss timing beyond the prototype 60s Color Well trigger, and replace primitive placeholders only after asset provenance is recorded.

## Current Vertical Slice Facts

- Boot now shows a start menu. Run timer, director spawning, weapon firing, pickups, and player control remain idle until keyboard/gamepad accept or Start Run begins gameplay.
- Death and victory/summary screens share Retry and Main Menu flow. Retry resets HP, XP, level, enemies, pickups, marks, director time, upgrades, draft state, page event state, runtime counters, and snaps/rebinds camera follow to the new player at spawn.
- Opening enemy pacing uses only `inkling_chaser` until the 60s pressure band. `paper_scrap_swarmer` joins after 60s. Early spawn pressure is faster than the prior readability pass: opening target budget 10, opening interval 0.95s, first-pressure target 18, and later prototype bands ramp batch/interval from there.
- Opening `inkling_chaser` HP is authored as two starting Waxlight hits. Early health scaling is a readable time-band multiplier: `1.0` opening, `1.15` at 60s, `1.3` at 120s, `1.5` at 240s.
- Spawn pressure is time-band driven through target budget, interval, and batch size. The gameplay pacing cap remains a high `safety_enemy_cap` of 120 for runaway protection only.
- Dash prototype tune is shorter: `dash_speed = 14.0`, `dash_active_seconds = 0.15`, expected travel `2.1m`, with dash activation still triggering crossed Waxlight marks.
- Runtime HUD now shows HP/max HP, level/XP, Waxlight damage, cooldown, active duration, inactive cap, inactive/active mark counts, director rate/band/budget/spawned/active/safety, page event state, weapons, and passives.
- Draft UI now presents exactly 3 centered vertical cards with equal card sizes, category/rarity, title, current/new stat line, and wrapped effect text. The modal hides HUD while open and scales across tested 16:9 sizes: 960x540, 1152x648, 1280x720, 1600x900, and 1920x1080. Draft generation uses rarity-weighted selection (`common` 60, `uncommon` 25, `rare` 9, `epic` 5, `legendary` 1), avoids duplicates, respects prototype 5 weapon / 5 passive slots, and uses set weapon-pick levels `[2, 6, 10, 14]` when enough new weapons are available.
- Prototype data now loads authored `.tres` resources for Waxlight weapon tuning, Star Sticker weapon tuning, enemy families, Candle Spark passive, and upgrade metadata/effects, with fallback factory content retained. Content resources include draft rarity metadata.
- Documented second weapon: `star_sticker_swarm`. Reason: documented early-run MVP weapon in the main GDD example, distinct from Waxlight through a readable orbit -> fire -> page-stick -> pop -> reform loop. Immediate hit and page-pop damage route through `DamageModel`, create damage numbers, and all Star Sticker visuals/gameplay artifacts have finite cleanup.
- Additional primitive weapon-pick options: `paper_plane_dart` is a readable straight dart, and `margin_spark_ring` is a local ring burst. They exist so the first weapon-pick interval can present 3 new weapon choices without third-party assets.
- Documented first passive: `candle_spark`. Reason: documented first passive in the main GDD example and catalyst-compatible with Waxlight/Firelight-style play. Prototype effect remains +15%, +30%, +45%, +60%, +75% and now modifies Firelight/Waxlight-tagged damage broadly instead of hardcoding only `waxlight_comet`.
- Documented first Page Event/objective: `fill_color_well`. Reason: documented MVP Page Event. Prototype/test tuning starts it at 60s for fast validation while the full-run GDD rule remains 5:00; HUD shows objective text/progress, gains progress from kills/mark activation, applies light pressure while active, shows a temporary centered announcement (`Page Event: Fill the Color Well` plus descriptor), and remains visible before the 5:00 vertical-slice endpoint.
- 5:00 vertical-slice end condition now stops gameplay and shows summary with time survived, level, XP collected, enemies defeated, weapons, and passives.
- Prototype upgrade steps are chunky/readable and one-stat-per-card: Waxlight damage +2, Waxlight cooldown -0.25s, Waxlight active duration +1s, Waxlight unactivated mark cap +3, player max HP +20, Star Sticker damage +2 is separate from Star Sticker count +1, and Candle Spark advances in 15% tagged-damage steps.
- No current attack artifact is indefinite: active Waxlight marks decay, inactive Waxlight marks expire after finite lifetime plus cap enforcement, Waxlight dash pulse visuals clean up, Star Sticker page stickers pop/clean up, and Star Sticker travel/pop feedback is transient.
- Finite page/map is larger for early-slice movement: playable half-extents are 11.0 x 7.0, visible page mesh is 22 x 14, director spawn bounds and player clamp use the larger extents, and camera follow/framing is widened. Color Mote magnet radius is back to close-range 3.0 so pickup still reads but requires nearby movement.
- Large-file note: `src/runtime/first_playable_runtime.gd` is now 965 lines. This pass added Page Event announcement wiring only in that over-800-line orchestration file; feature behavior lives in focused runtime helpers (`AutoWeaponManager`, `PrimitiveWeaponEffects`, `PagecraftManager`, `RunDraftController`, `RunUpgradeState`, `PageEventController`, `PageEventAnnouncement`). Extraction below the local guardrail remains tracked in `pagebound-hup`.

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
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/draft_layout_scaling_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/draft_rarity_weights_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/passive_tag_modifier_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/upgrade_effects_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/run_director_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/director_time_bands_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/enemy_loop_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/hud_counters_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/page_bounds_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/page_event_timing_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/star_sticker_loop_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/vertical_slice_mvp_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/first_playable_smoke_check.gd` passed.
- Full `tests/smoke/*.gd` suite passed on 2026-05-11.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --quit-after 1` ran the configured main scene without shell validation errors.
- Godot AI addon is copied to `addons/godot_ai/` and enabled in `project.godot`; MCP endpoint `http://127.0.0.1:8000/mcp` is not running until the Godot editor opens with the plugin active.
- MVP Systems Design gate passed on 2026-05-11 with accepted risks documented in `production/gates/systems-design-to-technical-setup-2026-05-11.md`.
- First playable behavior: `Main.tscn` boots to a start menu, runtime creates a primitive player, input actions, widened top-down camera follow, runtime event bus, damage model, pooled damage numbers, a scene-owned run director with faster early pressure time bands, two placeholder enemy families (`inkling_chaser` and delayed `paper_scrap_swarmer`), Waxlight Comet, draft-acquired Star Sticker Swarm, and prototype Paper Plane Dart / Margin Spark Ring weapon-pick options, documented Candle Spark passive, visible runtime stats HUD, collectible Color Mote XP drops with 3m close-range magnet pull, run XP thresholds, level-up event flow, rarity-weighted exactly-3 vertical draft cards, weapon-pick levels, runtime upgrades for Waxlight damage, Waxlight duration, Waxlight unactivated mark cap, Waxlight cooldown, player max HP, separate Star Sticker damage/count upgrades, and Candle Spark Firelight/Waxlight-tagged damage, finite 22x14 page bounds clamp, finite spawn bounds, visible Pagecraft marks, dash activation into finite active Waxlight zones, contact-only active Waxlight damage through DamageModel, activated mark decay, finite inactive mark expiry, primitive finite Waxlight dash pulse visuals, prototype 60s Fill the Color Well event/objective with temporary announcement, and 5:00 victory summary. XP awards only after pickup collection. Player death opens a `Run Over` death screen with Retry/Main Menu, pauses/stops gameplay, blocks dead-body XP collection, blocks post-death upgrades/healing, and Retry snaps/rebinds the camera to the new player. Dead enemies visibly despawn, stop physics, disable collision, and stop being targetable. `move_up`/W moves toward negative Z/page top.
- Current implementation count: 35 GDScript source files, 28 smoke checks, 7 ADRs. No third-party gameplay/art assets imported.

## Asset Direction Pass

- Direction: cohesive cute top-down pixel fantasy sprites/cards presented as Godot 3D `Sprite3D`/card-like objects on a lit finite paper diorama.
- Favor one pixel scale and one creator/family per prototype pass. Do not casually mix 8x8, 16x16, 32x32, voxel, and painterly card packs.
- Current source pool: itch.io fantasy + top-down, Godot + top-down, and fantasy card asset pages. Candidate families to evaluate next include Kenmi `Cute Fantasy RPG`, Pixel Frog `Tiny Swords`, SnowHex top-down packs, and Caz `Pixel Fantasy Playing Cards`.
- No gameplay/art assets were imported. Before any import, record source URL, creator, license, cost, and allowed commercial use.
- Local source library exists at `C:\Users\seanl\Documents\Godot\assets` (`/mnt/c/Users/seanl/Documents/Godot/assets`), about 1.4 GB and 88,427 files. Inventory is recorded in `production/assets/local-asset-library.md`.
- Do not bulk-copy the local source library into this repo. Import curated subsets only, with provenance and license metadata.
