# Active Session State

**Task**: First Playable Foundation
**Status**: Implemented and smoke validated
**Stage**: Technical Setup
**Review Mode**: lean
**Current Section**: First playable combat/Pagecraft foundation on `feat/mvp`

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
- `src/pickups/`
- `tests/smoke/schema_smoke_check.gd`
- `tests/smoke/player_movement_smoke_check.gd`
- `tests/smoke/camera_follow_smoke_check.gd`
- `tests/smoke/damage_model_smoke_check.gd`
- `tests/smoke/damage_numbers_smoke_check.gd`
- `tests/smoke/combat_prototype_smoke_check.gd`
- `tests/smoke/pagecraft_smoke_check.gd`
- `tests/smoke/first_playable_smoke_check.gd`
- `tests/smoke/xp_pickup_smoke_check.gd`
- `tests/smoke/run_director_smoke_check.gd`
- `tests/smoke/enemy_loop_smoke_check.gd`
- `tests/smoke/hud_counters_smoke_check.gd`
- `tests/smoke/page_bounds_smoke_check.gd`

## Next

First playable MVP runtime foundation is now in place. Next practical work: expand Resource schemas toward full `.tres` authored MVP counts, add draft/level-up flow, broaden weapon/passive content, and replace primitive placeholders only after asset provenance is recorded.

## Validation

- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/shell_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/schema_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/player_movement_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/camera_follow_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/damage_model_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/damage_numbers_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/combat_prototype_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/pagecraft_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/xp_pickup_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/run_director_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/enemy_loop_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/hud_counters_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/page_bounds_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --script tests/smoke/first_playable_smoke_check.gd` passed.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --quit-after 1` ran the configured main scene without shell validation errors.
- Godot AI addon is copied to `addons/godot_ai/` and enabled in `project.godot`; MCP endpoint `http://127.0.0.1:8000/mcp` is not running until the Godot editor opens with the plugin active.
- MVP Systems Design gate passed on 2026-05-11 with accepted risks documented in `production/gates/systems-design-to-technical-setup-2026-05-11.md`.
- First playable behavior: `Main.tscn` boots, runtime creates a primitive player, input actions, camera follow, runtime event bus, damage model, pooled damage numbers, a scene-owned run director, two placeholder enemy families (`inkling_chaser` and `paper_scrap_swarmer`), one auto weapon, visible HP/XP/enemy/time HUD, collectible Color Mote XP drops, 50 player HP, 5 enemy contact damage, finite page bounds clamp, finite spawn bounds, visible Pagecraft marks, and dash activation of marks. XP awards only after pickup collection. Dead enemies visibly despawn, stop physics, disable collision, and stop being targetable. `move_up`/W now moves toward negative Z/page top.

## Asset Direction Pass

- Direction: cohesive cute top-down pixel fantasy sprites/cards presented as Godot 3D `Sprite3D`/card-like objects on a lit finite paper diorama.
- Favor one pixel scale and one creator/family per prototype pass. Do not casually mix 8x8, 16x16, 32x32, voxel, and painterly card packs.
- Current source pool: itch.io fantasy + top-down, Godot + top-down, and fantasy card asset pages. Candidate families to evaluate next include Kenmi `Cute Fantasy RPG`, Pixel Frog `Tiny Swords`, SnowHex top-down packs, and Caz `Pixel Fantasy Playing Cards`.
- No gameplay/art assets were imported. Before any import, record source URL, creator, license, cost, and allowed commercial use.
- Local source library exists at `C:\Users\seanl\Documents\Godot\assets` (`/mnt/c/Users/seanl/Documents/Godot/assets`), about 1.4 GB and 88,427 files. Inventory is recorded in `production/assets/local-asset-library.md`.
- Do not bulk-copy the local source library into this repo. Import curated subsets only, with provenance and license metadata.
