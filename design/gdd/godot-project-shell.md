# Godot Project Shell

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-10
> **Implements Pillar**: True 2.5D Diorama Lighting

## Overview

`Godot Project Shell` defines Pagebound's canonical Godot 4.6.2 project container: `Main.tscn`, boot validation, stable runtime mount points, placeholder first-frame presentation, and the handoff contract that later systems use. It owns structure only. It does not own movement, input rebinding, camera follow, combat, Pagecraft rules, save data, pooling internals, resource schemas, UI flow, or performance metrics.

This document is the canonical implementation contract for `Main.tscn`. The older root-GDD task phrase `WorldRoot`, `PlayerRoot`, `LightingRoot`, and `UIRoot` is superseded by the tree below because the root GDD's Technical Architecture section already uses `RunRoot`, `Actors`, `Lighting`, and `UI`.

## Player Fantasy

The player should never notice the Godot Project Shell as a feature. They should feel its effects as immediate trust: the storybook opens cleanly, the page world appears grounded, and every visible system seems to belong in one coherent magical diorama. A good shell makes the first playable scene feel intentional instead of provisional. The player-facing promise is clarity: no confusing boot flow, no disconnected test rooms, no technical seams, and no root scene clutter leaking into the experience.

## Detailed Design

### Core Rules

1. `Main.tscn` owns boot orchestration and stable root topology only.
2. `GameBootstrap` is scene-owned under `Main.tscn`; downstream autoloads are optional and must not be required for shell smoke boot.
3. `GameBootstrap` validates the shell contract by calling `validate_shell(root: Node) -> ShellValidationResult`.
4. `GameBootstrap` emits `shell_ready(shell_refs: ShellRefs)` exactly once per successful boot cycle.
5. `ShellRefs` is a lightweight typed GDScript `RefCounted` class with direct typed references to canonical roots. It is not a dictionary.
6. The shell exposes mount roots for downstream systems. Downstream systems may depend on the named paths and typed references, but not on private `GameBootstrap` internals.
7. Placeholder boot must immediately show a visible finite paper page in a lit 3D scene. Blank lit boot is invalid.
8. Placeholder labels and debug text are developer-only. Player-facing boot must not show "placeholder" labels.
9. UI shell nodes are slots only. The shell sets boot visibility and layer order, but UI-specific systems own focus, modal behavior, menu behavior, draft behavior, pause behavior, accessibility, and content.
10. Shell validation must be one-shot and O(required_paths) during normal boot. It must not do recursive full-tree scans every frame.
11. Shell-owned scripts may only contain boot validation, shell handoff, placeholder scene setup, and lifecycle cleanup. Gameplay code belongs elsewhere.

### Canonical Root Scene

Use this exact root scene topology for implementation:

```text
Main (Node3D) [scene: Main.tscn]
|-- GameBootstrap (Node)
|-- RunRoot (Node3D)
|   |-- LevelRoot (Node3D)
|   |   |-- PageGround (MeshInstance3D)
|   |   |-- EnvironmentProps (Node3D)
|   |   |-- Boundaries (Node3D)
|   |   |-- SpawnZones (Node3D)
|   |   `-- QuestLocations (Node3D)
|   |-- Actors (Node3D)
|   |   |-- Players (Node3D)
|   |   |-- Pets (Node3D)
|   |   |-- Enemies (Node3D)
|   |   `-- Bosses (Node3D)
|   |-- Projectiles (Node3D)
|   |-- Pagecraft (Node3D)
|   |-- Pickups (Node3D)
|   |-- VFX (Node3D)
|   |-- DamageNumbers (Node3D)
|   |-- CameraRig (Node3D)
|   |   `-- Camera3D (Camera3D)
|   `-- Lighting (Node3D)
|       |-- DirectionalLight3D (DirectionalLight3D)
|       |-- WorldEnvironment (WorldEnvironment)
|       `-- OptionalLocalLights (Node3D, optional)
`-- UI (CanvasLayer)
    |-- HUD (Control)
    |-- ModalLayer (Control)
    |   |-- LevelUpScreen (Control)
    |   |-- PauseMenu (Control)
    |   `-- VictoryScreen (Control)
    `-- DebugOverlay (Control)
```

`Pagecraft` is only a mount root. `PagecraftGrid`, `PagecraftRenderer`, material simulation, decals, masks, ribbons, and shader behavior belong to the `Pagecraft Materials and Grid` GDD.

`Projectiles`, `Pickups`, `VFX`, and `DamageNumbers` are active scene mount roots only. Pooling registries, caps, inactive storage, object reuse, and per-frame instrumentation belong to `Object Pooling and Performance Debug`.

### Node Type Contract

| Path | Required Type | Required | Owner |
|---|---|---:|---|
| `Main` | `Node3D` | Yes | Project Shell |
| `Main/GameBootstrap` | `Node` with `GameBootstrap` script | Yes | Project Shell |
| `Main/RunRoot` | `Node3D` | Yes | Project Shell |
| `RunRoot/LevelRoot` | `Node3D` | Yes | Project Shell |
| `LevelRoot/PageGround` | `MeshInstance3D` | Yes | Project Shell placeholder |
| `LevelRoot/EnvironmentProps` | `Node3D` | Yes | Chapter/Map later |
| `LevelRoot/Boundaries` | `Node3D` | Yes | Chapter/Map later |
| `LevelRoot/SpawnZones` | `Node3D` | Yes | Run Director later |
| `LevelRoot/QuestLocations` | `Node3D` | Yes | Page Events later |
| `RunRoot/Actors` | `Node3D` | Yes | Project Shell |
| `Actors/Players` | `Node3D` | Yes | Player Controller later |
| `Actors/Pets` | `Node3D` | Yes | Pets later |
| `Actors/Enemies` | `Node3D` | Yes | Enemies later |
| `Actors/Bosses` | `Node3D` | Yes | Boss later |
| `RunRoot/Projectiles` | `Node3D` | Yes | Weapons/Pooling later |
| `RunRoot/Pagecraft` | `Node3D` | Yes | Pagecraft later |
| `RunRoot/Pickups` | `Node3D` | Yes | XP/Pickups later |
| `RunRoot/VFX` | `Node3D` | Yes | VFX later |
| `RunRoot/DamageNumbers` | `Node3D` | Yes | Combat Feedback later |
| `RunRoot/CameraRig` | `Node3D` | Yes | Camera later |
| `CameraRig/Camera3D` | `Camera3D` | Yes | Project Shell placeholder |
| `RunRoot/Lighting` | `Node3D` | Yes | Lighting later |
| `Lighting/DirectionalLight3D` | `DirectionalLight3D` | Yes | Project Shell placeholder |
| `Lighting/WorldEnvironment` | `WorldEnvironment` | Yes | Project Shell placeholder |
| `Lighting/OptionalLocalLights` | `Node3D` | No | Lighting later |
| `Main/UI` | `CanvasLayer` | Yes | Project Shell |
| `UI/HUD` | `Control` | Yes | HUD later |
| `UI/ModalLayer` | `Control` | Yes | UI systems later |
| `ModalLayer/LevelUpScreen` | `Control` | Yes | Draft UI later |
| `ModalLayer/PauseMenu` | `Control` | Yes | Pause UI later |
| `ModalLayer/VictoryScreen` | `Control` | Yes | Victory UI later |
| `UI/DebugOverlay` | `Control` | Yes | Performance Debug later |

Duplicate detection is scoped to each canonical parent. For example, duplicate `RunRoot` means more than one direct `RunRoot` child under `Main`; duplicate `Players` means more than one direct `Players` child under `RunRoot/Actors`. Godot may allow duplicate names under unrelated parents; shell validation only rejects duplicates that claim the same canonical role.

### Placeholder Boot Presentation

The first boot scene must include:

- A finite paper-like `PageGround` mesh visible to `Camera3D`.
- `Camera3D` angled for later 2.5D X/Z gameplay.
- One visible `DirectionalLight3D`.
- One active `WorldEnvironment`.
- Nonblack, nonblank first frame.
- No player character required.
- No visible UI slots by default.
- No player-facing "placeholder" text.

If the player controller is absent, the shell still presents the lit paper page. This tells the player and developer that the world exists even before gameplay systems are mounted.

### UI Layer Contract

| Slot | Path | Boot Visibility | Layer Role | Shell Owns |
|---|---|---|---|---|
| HUD | `UI/HUD` | Hidden | Gameplay HUD layer | Slot existence only |
| Modal layer | `UI/ModalLayer` | Hidden | Blocks HUD when UI systems show a modal | Slot existence only |
| Level up | `UI/ModalLayer/LevelUpScreen` | Hidden | Draft modal slot | Slot existence only |
| Pause | `UI/ModalLayer/PauseMenu` | Hidden | Pause modal slot | Slot existence only |
| Victory | `UI/ModalLayer/VictoryScreen` | Hidden | Victory modal slot | Slot existence only |
| Debug | `UI/DebugOverlay` | Hidden | Developer overlay above gameplay UI | Slot existence only |

Layer order is `HUD` below `ModalLayer` below `DebugOverlay`. The shell does not implement input capture, focus routing, pause state, draft selection, victory flow, accessibility behavior, safe-area layout, or debug metrics.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `ColdStart` | `Main.tscn` has loaded, but validation has not run. | `BootValidating` |
| `BootValidating` | `GameBootstrap` validates project settings, root paths, node types, duplicate canonical roles, placeholder boot, UI slots, and shell ownership rules. | `BootReady`, `FatalBootError` |
| `BootReady` | Required shell roots exist and placeholder boot is valid. | `StartupHandoff` |
| `StartupHandoff` | Bootstrap emits `shell_ready(shell_refs)` and waits for the startup/session coordinator to accept it. | `RunActive`, `FatalBootError` |
| `RunActive` | Downstream systems own active play behavior under shell roots. | `Shutdown` |
| `FatalBootError` | Required shell contract failed or handoff was not accepted. No gameplay handoff occurs. | Manual editor/developer fix |
| `Shutdown` | Scene is exiting, restarting, or returning to a higher-level menu flow. | `ColdStart` on reload |

Transitions:

- `ColdStart -> BootValidating`: `GameBootstrap` enters `_ready()`.
- `BootValidating -> BootReady`: every required check passes.
- `BootValidating -> FatalBootError`: any required check fails.
- `BootReady -> StartupHandoff`: `GameBootstrap` emits `shell_ready(shell_refs)`.
- `StartupHandoff -> RunActive`: the startup/session coordinator accepts `shell_refs`.
- `StartupHandoff -> FatalBootError`: no receiver accepts `shell_refs` before `startup_handoff_timeout_ms`, or receiver rejects it.
- `RunActive -> Shutdown`: quit, scene reload, restart, or run-exit request begins.

Pause is not a shell state. Pause belongs to future runtime/UI systems.

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Input and Rebinding | Downstream depends on shell | Shell boots before input rebinding exists. Input later owns action maps, device prompts, and rebinding UI. |
| Player Controller and Dash | Downstream depends on shell | Shell provides `RunRoot/Actors/Players`; player system owns `CharacterBody3D`, movement, dash, health hooks, and player scene internals. |
| Camera and 2.5D Lighting | Downstream depends on shell | Shell provides `CameraRig/Camera3D` and `Lighting`; camera/lighting systems later own follow, zoom, mood, shadows, and tuning. |
| Resource Data Schemas | Downstream depends on shell | Shell reserves folder homes and boot timing only. Resource classes and content schemas are defined elsewhere. |
| Runtime Event Bus | Downstream depends on shell | Shell can boot without an event bus. Event bus may subscribe to `shell_ready` later. |
| Object Pooling and Performance Debug | Downstream depends on shell | Shell provides active mount roots and `DebugOverlay`; pooling owns registries, caps, inactive storage, update cadence, metrics, and profiling. |
| Pagecraft Materials and Grid | Downstream depends on shell | Shell provides `RunRoot/Pagecraft`; Pagecraft owns grid, renderer, materials, masks, decals, ribbons, and simulation. |
| In-Run HUD and Draft UI | Downstream depends on shell | Shell provides `CanvasLayer` and slot paths; UI systems own layout, focus, modals, accessibility, and visual content. |
| Test Setup | Downstream depends on shell | Smoke tests load `Main.tscn`, call shell validation, inspect `ShellRefs`, and verify first-frame presentation. |

### ShellRefs Payload

`ShellRefs` must expose typed fields for:

- `run_root: Node3D`
- `level_root: Node3D`
- `page_ground: MeshInstance3D`
- `actors: Node3D`
- `players: Node3D`
- `pets: Node3D`
- `enemies: Node3D`
- `bosses: Node3D`
- `projectiles: Node3D`
- `pagecraft: Node3D`
- `pickups: Node3D`
- `vfx: Node3D`
- `damage_numbers: Node3D`
- `camera_rig: Node3D`
- `camera: Camera3D`
- `lighting: Node3D`
- `directional_light: DirectionalLight3D`
- `world_environment: WorldEnvironment`
- `ui: CanvasLayer`
- `hud: Control`
- `modal_layer: Control`
- `level_up_screen: Control`
- `pause_menu: Control`
- `victory_screen: Control`
- `debug_overlay: Control`

Optional refs must not be included as required fields. `OptionalLocalLights` may be discovered by the lighting system later.

## Formulas

No gameplay balance formulas apply to this system. Project Shell formulas validate boot topology and handoff readiness only.

`required_checks = count(required_check_results)`

`passed_checks = count(required_check_results where status == "pass")`

`failed_checks = count(required_check_results where status == "fail")`

`boot_readiness = passed_checks / required_checks`

`boot_error_count = failed_checks`

`shell_ready_allowed = failed_checks == 0 and passed_checks == required_checks`

**Variables:**

| Variable | Type | Range | Description |
|---|---|---|---|
| `required_check_results` | array | length `1+` | One result per required path or policy check. |
| `required_checks` | int | `1+` | Total required validation checks. |
| `passed_checks` | int | `0` to `required_checks` | Count of required checks that pass. |
| `failed_checks` | int | `0` to `required_checks` | Count of required checks that fail. |
| `boot_readiness` | float | `0.0` to `1.0` | Reporting score only. |
| `boot_error_count` | int | `0` to `required_checks` | Blocking validation failure count. |
| `shell_ready_allowed` | bool | `true` or `false` | Whether `shell_ready` may emit. |

Invalid formula states are fatal validation errors:

- If `required_checks == 0`, fail with `BOOT_SHELL_INVALID_CHECK_CONFIG`.
- If `passed_checks < 0`, fail with `BOOT_SHELL_INVALID_CHECK_COUNTS`.
- If `passed_checks > required_checks`, fail with `BOOT_SHELL_INVALID_CHECK_COUNTS`.
- If `failed_checks != required_checks - passed_checks`, fail with `BOOT_SHELL_INVALID_CHECK_COUNTS`.

Example: If 30 required checks exist and 29 pass, `boot_readiness = 29 / 30 = 0.97`, `boot_error_count = 1`, and `shell_ready_allowed = false`.

### Minimum Required Checks

The implementation must produce one result per required check ID.

| Check ID | Pass Condition |
|---|---|
| `has_configured_main_scene` | Project setting `application/run/main_scene` points to canonical `Main.tscn`. |
| `has_main_root` | Loaded main root exists and is `Node3D`. |
| `has_game_bootstrap` | `Main/GameBootstrap` exists, is `Node`, and has the shell bootstrap script. |
| `has_run_root` | `Main/RunRoot` exists and is `Node3D`. |
| `has_level_root` | `RunRoot/LevelRoot` exists and is `Node3D`. |
| `has_page_ground` | `LevelRoot/PageGround` exists and is `MeshInstance3D`. |
| `has_environment_props_root` | `LevelRoot/EnvironmentProps` exists and is `Node3D`. |
| `has_boundaries_root` | `LevelRoot/Boundaries` exists and is `Node3D`. |
| `has_spawn_zones_root` | `LevelRoot/SpawnZones` exists and is `Node3D`. |
| `has_quest_locations_root` | `LevelRoot/QuestLocations` exists and is `Node3D`. |
| `has_actors_root` | `RunRoot/Actors` exists and is `Node3D`. |
| `has_players_root` | `Actors/Players` exists and is `Node3D`. |
| `has_pets_root` | `Actors/Pets` exists and is `Node3D`. |
| `has_enemies_root` | `Actors/Enemies` exists and is `Node3D`. |
| `has_bosses_root` | `Actors/Bosses` exists and is `Node3D`. |
| `has_projectiles_root` | `RunRoot/Projectiles` exists and is `Node3D`. |
| `has_pagecraft_root` | `RunRoot/Pagecraft` exists and is `Node3D`. |
| `has_pickups_root` | `RunRoot/Pickups` exists and is `Node3D`. |
| `has_vfx_root` | `RunRoot/VFX` exists and is `Node3D`. |
| `has_damage_numbers_root` | `RunRoot/DamageNumbers` exists and is `Node3D`. |
| `has_camera_rig` | `RunRoot/CameraRig` exists and is `Node3D`. |
| `has_camera` | `CameraRig/Camera3D` exists and is `Camera3D`. |
| `has_lighting_root` | `RunRoot/Lighting` exists and is `Node3D`. |
| `has_directional_light` | `Lighting/DirectionalLight3D` exists and is `DirectionalLight3D`. |
| `has_world_environment` | `Lighting/WorldEnvironment` exists and is `WorldEnvironment`. |
| `has_ui_root` | `Main/UI` exists and is `CanvasLayer`. |
| `has_hud_slot` | `UI/HUD` exists and is `Control`. |
| `has_modal_layer` | `UI/ModalLayer` exists and is `Control`. |
| `has_level_up_slot` | `ModalLayer/LevelUpScreen` exists and is `Control`. |
| `has_pause_slot` | `ModalLayer/PauseMenu` exists and is `Control`. |
| `has_victory_slot` | `ModalLayer/VictoryScreen` exists and is `Control`. |
| `has_debug_overlay_slot` | `UI/DebugOverlay` exists and is `Control`. |
| `has_no_duplicate_canonical_roots` | No duplicate canonical roles exist under their canonical parent scopes. |
| `has_placeholder_boot_visual` | First frame contains visible `PageGround`, active camera, active directional light, and active world environment. |
| `has_no_shell_gameplay_logic` | Shell-owned scene scripts are limited to bootstrap, validation, placeholder setup, and lifecycle cleanup. |
| `has_shell_refs_payload` | `ShellRefs` contains every required typed field and no required field is null. |

## Edge Cases

- **If `Main.tscn` is missing or project settings point elsewhere**: an external editor/headless smoke check fails with `BOOT_SHELL_MISSING_MAIN_SCENE`. `GameBootstrap` cannot be responsible for reporting a scene that never loaded.
- **If `Main.tscn` loads but the root node is wrong**: validation fails `has_main_root` and reports expected type, actual type, and actual path.
- **If a required root node is missing**: the exact path check fails, `boot_error_count` increases by 1 for that missing path, and `shell_ready` is not emitted.
- **If multiple required roots are missing**: each missing path gets its own failed check and error entry.
- **If a required root has the wrong node type or wrong hierarchy location**: validation reports `BOOT_SHELL_WRONG_PATH_OR_TYPE` with `expected_path`, `actual_path`, `expected_type`, and `actual_type`.
- **If duplicate canonical roots exist**: validation reports `BOOT_SHELL_DUPLICATE_ROOT` with every duplicate path in the relevant parent scope.
- **If placeholder `Camera3D` is missing or inactive**: boot fails because the first playable shell must always have a valid view.
- **If `DirectionalLight3D` or `WorldEnvironment` is missing or inactive**: boot fails because the shell must prove lit 3D scene readiness.
- **If `PageGround` is absent, not visible, or outside the camera frustum**: placeholder boot fails because blank boot is invalid.
- **If downstream systems are absent**: boot may still pass if all shell roots and placeholder requirements are satisfied. Empty mount roots are valid.
- **If a downstream system requests a missing mount root after handoff**: that system fails loudly; shell validation should already have caught required mount roots.
- **If gameplay-specific nodes are added directly into base `Main.tscn`**: `has_no_shell_gameplay_logic` fails unless the node is an inert placeholder documented in this GDD.
- **If a shell-owned node has a script outside approved shell/bootstrap paths or is tagged with gameplay groups such as `gameplay`, `combat`, `spawner`, `progression`, `pagecraft_rule`, `save_schema`, or `pool_manager`**: validation fails `BOOT_SHELL_GAMEPLAY_CONTAMINATION`.
- **If startup handoff emits twice**: second emit is blocked and logged as `BOOT_SHELL_DUPLICATE_HANDOFF`.
- **If the startup handoff receiver is missing or rejects refs**: `StartupHandoff` transitions to `FatalBootError` with `BOOT_SHELL_HANDOFF_UNCLAIMED` or `BOOT_SHELL_HANDOFF_REJECTED`.
- **If `ShellRefs` contains null or stale required references**: validation fails before handoff.
- **If boot validation passes in editor but fails in exported build**: treat as release-blocking configuration drift. Test setup must include editor/headless and exported-build smoke paths before release.
- **If shutdown occurs while runtime children still exist**: shell clears only placeholder-owned children and cached shell refs. Downstream-owned children are cleaned by owning systems or by full scene unload.
- **If scene reloads after shutdown**: new lifecycle starts at `ColdStart`; previous refs, signals, and emission count do not carry over.
- **If Godot 4.6.2 renderer or physics defaults differ by platform**: shell still boots, but platform-specific rendering/physics behavior must be handled by architecture decisions or downstream system GDDs.

## Dependencies

Godot Project Shell has no upstream gameplay dependencies. It depends only on the configured project baseline:

- Godot 4.6.2.
- GDScript.
- Godot 3D runtime for the main scene.
- Project settings that point the configured main scene to `Main.tscn`.
- A scene-owned `GameBootstrap` script.

Downstream systems listed here are future contracts. Their GDDs may not exist yet, but when authored they must treat these paths as the shell interface.

| Downstream System | Dependency Type | Interface |
|---|---|---|
| Input and Rebinding | Hard | Project boots and provides `UI` slots before input UI or action-map editing exists. |
| Player Controller and Dash | Hard | `RunRoot/Actors/Players` exists as player scene mount. |
| Camera and 2.5D Lighting | Hard | `CameraRig`, placeholder `Camera3D`, `Lighting`, `DirectionalLight3D`, and `WorldEnvironment` exist. |
| Resource Data Schemas | Soft | Folder layout reserves `data/` and resource homes; schemas are defined elsewhere. |
| Runtime Event Bus | Soft | Shell can boot without the event bus; later event bus may subscribe to `shell_ready`. |
| Object Pooling and Performance Debug | Hard | `Projectiles`, `Pickups`, `VFX`, and `DamageNumbers` roots exist as active mount points; pooling owns inactive storage and caps. |
| Pagecraft Materials and Grid | Hard | `RunRoot/Pagecraft` exists as the Pagecraft mount root; Pagecraft owns internals. |
| In-Run HUD and Draft UI | Hard | `UI/HUD`, `UI/ModalLayer/LevelUpScreen`, `UI/ModalLayer/PauseMenu`, `UI/ModalLayer/VictoryScreen`, and `UI/DebugOverlay` exist. |
| Test Setup | Hard | Smoke tests can load `Main.tscn`, run shell validation, assert `shell_ready_allowed`, inspect `ShellRefs`, and verify nonblank placeholder boot. |

Resolved architecture assumptions:

- `GameBootstrap` is scene-owned, not an autoload.
- `ShellRefs` is a typed `RefCounted`.
- The canonical root names are `RunRoot`, `Actors`, `Lighting`, and `UI`.
- Placeholder boot includes a primitive paper mesh immediately.

Still deferred to later architecture/design docs:

- Exact file paths for implementation scripts.
- Export preset matrix and CI command details.
- Pooling storage strategy.
- Final camera behavior, lighting mood, and UI focus rules.

## Tuning Knobs

Project Shell should have very few designer-tunable values. Most values belong to downstream systems.

| Knob | Type | Default | Safe Range | Owner | Notes |
|---|---|---:|---|---|---|
| `boot_validation_enabled` | bool | `true` | `true` in all non-test builds | Project Shell | Disabling validation is only allowed for tests that intentionally inspect broken scenes. |
| `fatal_on_boot_error_in_editor` | bool | `true` | `true` | Project Shell | Editor/development builds must block handoff when shell topology is invalid. |
| `allow_placeholder_boot` | bool | `true` | `true` until first playable systems exist | Project Shell | Lets the shell boot without downstream gameplay systems. Does not allow blank boot. |
| `show_debug_overlay_on_boot` | bool | `false` | `false` or developer-only `true` | Debug/Performance later | Shell only exposes the slot; debug system owns overlay content and metrics. |
| `startup_handoff_timeout_ms` | int | `2000` | `500` to `10000` | Project Shell / Architecture | If no receiver accepts `shell_ready`, handoff fails loudly after this timeout. |

Unsafe tuning:

- Turning off boot validation for normal play invalidates every downstream system contract.
- Allowing shell gameplay logic makes `Main.tscn` a hidden gameplay owner and breaks separation of concerns.
- Increasing handoff timeout to hide slow initialization should be treated as a symptom, not a fix.
- Showing debug overlay by default in player-facing builds is invalid.

## Visual/Audio Requirements

This is not an art or audio system, but the shell must provide minimal placeholder presentation so the project never boots to a blank or visually misleading scene.

Visual requirements:

- Placeholder boot must show a finite paper-like `PageGround` mesh.
- `Camera3D` must see `PageGround` on first frame.
- `DirectionalLight3D` must visibly affect the scene.
- `WorldEnvironment` must be active.
- The first frame must be nonblack and nonblank.
- Placeholder visuals must be primitive and isolated from final art production.
- Any placeholder labels must be editor/developer-only.
- The shell must not define final camera composition, lighting mood, shader style, VFX style, or asset production rules.

Audio requirements:

- No required audio playback at shell boot.
- The shell may reserve an audio manager/autoload location, but audio routing, snapshots, music layers, and SFX rules belong to later audio systems.

## UI Requirements

Project Shell provides UI slots, not UI behavior.

Required UI slot contract:

- `UI` is a `CanvasLayer`.
- `UI/HUD` is a `Control`.
- `UI/ModalLayer` is a `Control`.
- `UI/ModalLayer/LevelUpScreen` is a `Control`.
- `UI/ModalLayer/PauseMenu` is a `Control`.
- `UI/ModalLayer/VictoryScreen` is a `Control`.
- `UI/DebugOverlay` is a `Control`.

Rules:

1. UI slots must exist at boot even if empty.
2. Every UI slot starts hidden.
3. `HUD` renders below `ModalLayer`.
4. `DebugOverlay` renders above `HUD` and `ModalLayer` only in developer/debug contexts.
5. Shell must not implement draft selection, pause behavior, victory flow, HUD content, input capture, focus navigation, accessibility behavior, safe-zone layout, or debug overlay metrics.
6. Future UI systems must test keyboard/gamepad focus separately from mouse/touch focus.
7. Missing UI slots are fatal shell-contract failures because downstream UI systems depend on stable paths.

UX flag: This system has UI slot requirements only. Full UX specs are not needed for this shell, but every future UI system that fills these slots should run `/ux-design` before implementation stories are written.

## Acceptance Criteria

- **GIVEN** `Main.tscn` is configured as the project main scene, **WHEN** editor/headless shell smoke validation runs, **THEN** `has_configured_main_scene == pass`.
- **GIVEN** `Main.tscn` loads, **WHEN** `GameBootstrap.validate_shell(root)` runs, **THEN** validation produces one result per required check ID listed in Minimum Required Checks.
- **GIVEN** all required roots exist with exact paths and expected node types, **WHEN** validation completes, **THEN** `boot_readiness == 1.0`, `boot_error_count == 0`, `shell_ready_allowed == true`, and `shell_ready(shell_refs)` emits once.
- **GIVEN** exactly one required canonical node path is removed from an otherwise valid shell, **WHEN** validation runs, **THEN** exactly one validation error names that missing path, `boot_error_count == 1`, `boot_readiness == (required_checks - 1) / required_checks`, and `shell_ready` is not emitted.
- **GIVEN** multiple required canonical node paths are removed, **WHEN** validation runs, **THEN** each missing path has a separate failed check and `boot_error_count` equals the number of failed required checks.
- **GIVEN** any required root has the wrong node type or wrong hierarchy location, **WHEN** validation runs, **THEN** validation reports `BOOT_SHELL_WRONG_PATH_OR_TYPE` with `expected_path`, `actual_path`, `expected_type`, and `actual_type`, and handoff is blocked.
- **GIVEN** duplicate canonical roots exist under the same canonical parent scope, **WHEN** validation runs, **THEN** validation reports `BOOT_SHELL_DUPLICATE_ROOT` with all duplicate paths and `shell_ready` is not emitted.
- **GIVEN** `CameraRig/Camera3D` is missing or not a `Camera3D`, **WHEN** validation runs, **THEN** `has_camera == fail` and handoff is blocked.
- **GIVEN** `Lighting/DirectionalLight3D` is missing or not a `DirectionalLight3D`, **WHEN** validation runs, **THEN** `has_directional_light == fail` and handoff is blocked.
- **GIVEN** `Lighting/WorldEnvironment` is missing or not a `WorldEnvironment`, **WHEN** validation runs, **THEN** `has_world_environment == fail` and handoff is blocked.
- **GIVEN** downstream gameplay systems are absent and all shell roots are valid, **WHEN** validation runs, **THEN** shell readiness still passes.
- **GIVEN** the base `Main.tscn` contains a shell-owned node with a script outside approved shell/bootstrap paths or a forbidden gameplay group, **WHEN** validation runs, **THEN** `has_no_shell_gameplay_logic == fail` and `BOOT_SHELL_GAMEPLAY_CONTAMINATION` includes node path and script or group name.
- **GIVEN** validation passes, **WHEN** `GameBootstrap` emits `shell_ready(shell_refs)`, **THEN** it emits exactly once per boot cycle and every required `ShellRefs` field is non-null.
- **GIVEN** validation fails, **WHEN** boot completes, **THEN** `shell_ready(shell_refs)` is never emitted.
- **GIVEN** `ShellRefs` is emitted, **WHEN** listeners inspect fields, **THEN** each field equals the node at its expected canonical path.
- **GIVEN** a required `ShellRefs` field is null, stale, duplicate, or points to the wrong node, **WHEN** handoff is attempted, **THEN** handoff is blocked.
- **GIVEN** invalid formula counts such as `required_checks == 0`, `passed_checks < 0`, `passed_checks > required_checks`, or mismatched `failed_checks`, **WHEN** validation evaluates readiness, **THEN** `BOOT_SHELL_INVALID_CHECK_CONFIG` or `BOOT_SHELL_INVALID_CHECK_COUNTS` is reported and handoff is blocked.
- **GIVEN** `boot_error_count > 0` or `passed_checks != required_checks`, **WHEN** readiness gate is checked, **THEN** `shell_ready_allowed == false`.
- **GIVEN** no handoff receiver accepts `shell_ready`, **WHEN** `startup_handoff_timeout_ms` elapses, **THEN** `StartupHandoff` transitions to `FatalBootError` and logs `BOOT_SHELL_HANDOFF_UNCLAIMED`.
- **GIVEN** shutdown, reload, or scene restart occurs, **WHEN** `GameBootstrap` runs again, **THEN** old `ShellRefs` object identity is not reused, old node instance IDs are absent from the new payload, and `shell_ready` may emit once for the new boot only.
- **GIVEN** UI slots are required, **WHEN** validation runs, **THEN** `UI` is `CanvasLayer`, each slot is a `Control`, all slots start hidden, and each slot is represented in `ShellRefs`.
- **GIVEN** placeholder boot runs, **WHEN** first-frame visual smoke validation checks the viewport, **THEN** the frame is nonblack, `PageGround` is visible to `Camera3D`, `DirectionalLight3D` affects the scene, and no player-facing placeholder label is visible.
- **GIVEN** editor/headless smoke validation and one exported build target run against the same `Main.tscn`, **WHEN** both complete, **THEN** both produce the same validation result, same `boot_error_count`, same failed check IDs, and same `shell_ready` emission count.

## Review Decisions Resolved

- Canonical root tree uses `RunRoot`, `Actors`, `Lighting`, and `UI`.
- `UI` is a `CanvasLayer`; UI slots are `Control`.
- `Pagecraft` is a mount root only; no shell-owned `PagecraftGrid` or `PagecraftRenderer`.
- `WorldEnvironment` lives under `RunRoot/Lighting`.
- `ShellRefs` is a typed `RefCounted`, not a dictionary.
- Placeholder boot includes a primitive paper mesh immediately.
- Blank lit boot is invalid.
- Pause is not a shell lifecycle state.
