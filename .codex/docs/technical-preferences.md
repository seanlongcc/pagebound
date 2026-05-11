# Technical Preferences

<!-- Populated by /setup-engine. Updated as the user makes decisions throughout development. -->
<!-- All agents reference this file for project-specific standards and conventions. -->

## Engine & Language

- **Engine**: Godot 4.6.2
- **Language**: GDScript
- **Rendering**: Godot 3D runtime for true 2.5D: Camera3D, DirectionalLight3D, WorldEnvironment, Sprite3D/cards, real shadows, and tactile paper/material surfaces
- **Physics**: Godot 3D physics using planar X/Z gameplay movement, `CharacterBody3D`, and Y as visual height

## Input & Platform

<!-- Written by /setup-engine. Read by /ux-design, /ux-review, /test-setup, /team-ui, and /dev-story -->
<!-- to scope interaction specs, test helpers, and implementation to the correct input methods. -->

- **Target Platforms**: PC / Steam first, Steam Deck optimization target, local/LAN debug co-op, Steam co-op later
- **Input Methods**: Keyboard/Mouse and Gamepad
- **Primary Input**: Keyboard/Mouse for development, Gamepad-supported gameplay
- **Gamepad Support**: Partial for MVP, full before Steam Deck-focused polish
- **Touch Support**: None
- **Platform Notes**: Combat does not require aiming. Dash direction comes from movement input. UI must support keyboard and gamepad navigation; avoid hover-only interactions.

## Naming Conventions

- **Classes**: PascalCase with `class_name` where global access is intended, e.g. `PlayerController`
- **Variables**: snake_case, e.g. `move_speed`
- **Signals/Events**: snake_case past tense, e.g. `health_changed`
- **Files**: snake_case matching class or resource role, e.g. `player_controller.gd`
- **Scenes/Prefabs**: PascalCase matching root node, e.g. `PlayerController.tscn`
- **Constants**: UPPER_SNAKE_CASE, e.g. `MAX_HEALTH`

## Performance Budgets

- **Target Framerate**: 60 FPS desktop 1080p; 40-60 FPS Steam Deck target
- **Frame Budget**: 16.6 ms desktop target; 25 ms Steam Deck lower-bound target
- **Draw Calls**: Keep scene/render budgets profiler-driven; pool projectiles, pickups, VFX, damage numbers, enemies, pet attacks, and decals
- **Memory Ceiling**: [TO BE CONFIGURED during profiling]

## Testing

- **Framework**: GUT planned for Godot tests; install/configure during `/test-setup`
- **Minimum Coverage**: Critical gameplay systems, resource schema validation, save migration, balance formulas, and smoke tests
- **Required Tests**: Balance formulas, gameplay systems, networking (if applicable)

## Forbidden Patterns

<!-- Add patterns that should never appear in this project's codebase -->
- [None configured yet — add as architectural decisions are made]

## Allowed Libraries / Addons

<!-- Add approved third-party dependencies here -->
- [None configured yet — add as dependencies are approved]

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [No ADRs yet — use /architecture-decision to create one]

## Engine Specialists

<!-- Written by /setup-engine when engine is configured. -->
<!-- Read by /code-review, /architecture-decision, /architecture-review, and team skills -->
<!-- to know which specialist to spawn for engine-specific validation. -->

- **Primary**: godot-specialist
- **Language/Code Specialist**: godot-gdscript-specialist (all `.gd` files)
- **Shader Specialist**: godot-shader-specialist (`.gdshader` files, VisualShader resources)
- **UI Specialist**: godot-specialist (Control nodes, CanvasLayer, UI scenes)
- **Additional Specialists**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **Routing Notes**: Invoke primary for architecture decisions, ADR validation, scene structure, and cross-cutting review. Invoke GDScript specialist for code quality, signal architecture, static typing, and GDScript idioms. Invoke shader specialist for material and shader code. Invoke GDExtension specialist only when native extensions are actively involved.

### File Extension Routing

<!-- Skills use this table to select the right specialist per file type. -->
<!-- If a row says [TO BE CONFIGURED], fall back to Primary for that file type. -->

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.gd files) | godot-gdscript-specialist |
| Shader / material files (.gdshader, VisualShader) | godot-shader-specialist |
| UI / screen files (Control nodes, CanvasLayer) | godot-specialist |
| Scene / prefab / level files (.tscn, .tres) | godot-specialist |
| Native extension / plugin files (.gdextension, C++) | godot-gdextension-specialist |
| General architecture review | godot-specialist |
