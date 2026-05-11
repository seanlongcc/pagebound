# Systems Index: Pagebound

> **Status**: Draft
> **Created**: 2026-05-10
> **Last Updated**: 2026-05-11
> **Source Concept**: design/gdd/game-concept.md
> **Source Master GDD**: PAGEBOUND_CODEX_GDD_v1_5.md

---

## Overview

Pagebound needs a Godot 3D-runtime foundation for a 2.5D storybook action roguelite: planar movement, camera, lighting, resource-driven content, Pagecraft terrain state, auto-attacking combat, timed objectives, enemies, boss pacing, pets, meta progression, and readable UI/audio feedback. This index is a first-pass decomposition from the root GDD. All systems start as `Not Started` until their individual GDDs are written and reviewed.

---

## Systems Enumeration

| # | System Name | Layer | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|-------|----------|----------|--------|------------|------------|
| 1 | Godot Project Shell | Foundation | Core | MVP | Approved | design/gdd/godot-project-shell.md | None |
| 2 | Input and Rebinding | Foundation | Core | MVP | Approved | design/gdd/input-and-rebinding.md | Godot Project Shell |
| 3 | Player Controller and Dash | Core | Core | MVP | Approved | design/gdd/player-controller-and-dash.md | Godot Project Shell, Input and Rebinding |
| 4 | Camera and 2.5D Lighting | Core | Core | MVP | Approved | design/gdd/camera-and-2-5d-lighting.md | Godot Project Shell, Player Controller and Dash |
| 5 | Resource Data Schemas | Foundation | Core | MVP | Approved | design/gdd/resource-data-schemas.md | Godot Project Shell |
| 6 | Runtime Event Bus | Foundation | Core | MVP | Approved | design/gdd/runtime-event-bus.md | Godot Project Shell |
| 7 | Object Pooling and Performance Debug | Foundation | Core | MVP | Approved | design/gdd/object-pooling-and-performance-debug.md | Godot Project Shell |
| 8 | Damage and Status Model | Core | Gameplay | MVP | Approved | design/gdd/damage-and-status-model.md | Resource Data Schemas, Runtime Event Bus |
| 9 | Weapons and Auto-Attacks | Feature | Gameplay | MVP | Approved | design/gdd/weapons-and-auto-attacks.md | Damage and Status Model, Resource Data Schemas, Object Pooling and Performance Debug |
| 10 | Passive Items and Drafts | Feature | Progression | MVP | Approved | design/gdd/passive-items-and-drafts.md | Resource Data Schemas, Damage and Status Model |
| 11 | XP, Leveling, and Upgrade Drafts | Feature | Progression | MVP | Approved | design/gdd/xp-leveling-and-upgrade-drafts.md | Passive Items and Drafts, Weapons and Auto-Attacks |
| 12 | Evolution System | Feature | Progression | MVP | Approved | design/gdd/evolution-system.md | Weapons and Auto-Attacks, Passive Items and Drafts, XP, Leveling, and Upgrade Drafts |
| 13 | Pagecraft Materials and Grid | Feature | Gameplay | MVP | Approved | design/gdd/pagecraft-materials-and-grid.md | Godot Project Shell, Damage and Status Model, Object Pooling and Performance Debug |
| 14 | Enemies and AI Movement | Feature | Gameplay | MVP | Approved | design/gdd/enemies-and-ai-movement.md | Damage and Status Model, Player Controller and Dash |
| 15 | Run Director and Finite Spawning | Feature | Gameplay | MVP | Approved | design/gdd/run-director-and-finite-spawning.md | Enemies and AI Movement, Pagecraft Materials and Grid |
| 16 | Page Events and Objectives | Feature | Gameplay | MVP | Approved | design/gdd/page-events-and-objectives.md | Run Director and Finite Spawning, Pagecraft Materials and Grid |
| 17 | Boss and Victory Flow | Feature | Gameplay | MVP | Approved | design/gdd/boss-and-victory-flow.md | Run Director and Finite Spawning, Weapons and Auto-Attacks |
| 18 | Damage Numbers and Combat Feedback | Presentation | UI | MVP | Approved | design/gdd/damage-numbers-and-combat-feedback.md | Godot Project Shell, Damage and Status Model, Object Pooling and Performance Debug |
| 19 | In-Run HUD and Draft UI | Presentation | UI | MVP | Approved | design/gdd/in-run-hud-and-draft-ui.md | Godot Project Shell, XP, Leveling, and Upgrade Drafts, Page Events and Objectives |
| 20 | Character Roster and Mastery | Feature | Progression | Vertical Slice | Not Started | design/gdd/character-roster-and-mastery.md | Resource Data Schemas, Weapons and Auto-Attacks, Player Controller and Dash |
| 21 | Pets and Companion Combat | Feature | Gameplay | Vertical Slice | Not Started | design/gdd/pets-and-companion-combat.md | Resource Data Schemas, Damage and Status Model, Object Pooling and Performance Debug |
| 22 | Save, Profile, and Migration | Foundation | Persistence | Vertical Slice | Not Started | design/gdd/save-profile-and-migration.md | Resource Data Schemas |
| 23 | Hub, Chapter Select, and Restoration | Feature | Meta | Vertical Slice | Not Started | design/gdd/hub-chapter-select-and-restoration.md | Save, Profile, and Migration, Character Roster and Mastery |
| 24 | Meta Economy and Unlocks | Feature | Economy | Vertical Slice | Not Started | design/gdd/meta-economy-and-unlocks.md | Save, Profile, and Migration, Character Roster and Mastery, Pets and Companion Combat |
| 25 | Chapter and Map Construction | Feature | Gameplay | Vertical Slice | Not Started | design/gdd/chapter-and-map-construction.md | Camera and 2.5D Lighting, Page Events and Objectives, Run Director and Finite Spawning |
| 26 | Audio and Music Layers | Presentation | Audio | Vertical Slice | Not Started | design/gdd/audio-and-music-layers.md | Runtime Event Bus, Damage and Status Model |
| 27 | Accessibility and Options | Presentation | UI | Alpha | Not Started | design/gdd/accessibility-and-options.md | In-Run HUD and Draft UI, Input and Rebinding |
| 28 | Tutorial and First-Run Flow | Polish | Meta | Alpha | Not Started | design/gdd/tutorial-and-first-run-flow.md | In-Run HUD and Draft UI, Page Events and Objectives |
| 29 | Co-op Networking | Feature | Gameplay | Full Vision | Not Started | design/gdd/co-op-networking.md | Save, Profile, and Migration, Run Director and Finite Spawning, Player Controller and Dash |

---

## Categories

| Category | Description | Pagebound Systems |
|----------|-------------|-------------------|
| **Core** | Foundation systems everything depends on | Project shell, input, player controller, camera, resources, event bus, pooling |
| **Gameplay** | Systems that create run play | Combat, Pagecraft, enemies, director, events, bosses, pets |
| **Progression** | How the player grows during and between runs | XP, drafts, evolutions, character mastery |
| **Economy** | Resource creation and consumption | Pigment, Treats, unlocks, restoration costs |
| **Persistence** | Save state and continuity | Save/load, profile migration |
| **UI** | Player-facing information displays | HUD, draft UI, damage numbers, options |
| **Audio** | Sound and music systems | Music layers, SFX routing, mix priorities |
| **Meta** | Systems outside the core run loop | Hub, chapter select, tutorial, restoration |

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | Required to test whether the combat/Pagecraft loop is fun | First playable prototype and MVP run | Design FIRST |
| **Vertical Slice** | Required for one complete chapter and hub return | Vertical slice / demo | Design SECOND |
| **Alpha** | Broad support features and onboarding | Alpha milestone | Design THIRD |
| **Full Vision** | Later multiplayer and release-scope expansion | Beta / Release | Design as needed |

---

## Dependency Map

### Foundation Layer

1. Godot Project Shell - creates project structure and runtime root.
2. Resource Data Schemas - defines content contracts for weapons, items, pets, enemies, chapters, and events.
3. Runtime Event Bus - decouples damage, pickup, level-up, evolution, event, and UI signals.
4. Object Pooling and Performance Debug - required before high-volume combat effects.
5. Save, Profile, and Migration - required before durable unlocks and meta progression.

### Core Layer

1. Input and Rebinding - depends on Godot Project Shell.
2. Player Controller and Dash - depends on project shell and input.
3. Camera and 2.5D Lighting - depends on project shell and player controller.
4. Damage and Status Model - depends on resources and event bus.

### Feature Layer

1. Weapons and Auto-Attacks - depends on damage, resources, and pooling.
2. Passive Items and Drafts - depends on resources and damage.
3. XP, Leveling, and Upgrade Drafts - depends on weapons and passives.
4. Evolution System - depends on weapons, passives, and drafts.
5. Pagecraft Materials and Grid - depends on project shell, damage, and pooling.
6. Enemies and AI Movement - depends on damage and player controller.
7. Run Director and Finite Spawning - depends on enemies and Pagecraft.
8. Page Events and Objectives - depends on run director and Pagecraft.
9. Boss and Victory Flow - depends on run director and combat.
10. Character Roster and Mastery - depends on resources, weapons, and player controller.
11. Pets and Companion Combat - depends on resources, damage, and pooling.
12. Hub, Chapter Select, and Restoration - depends on save/profile and character roster.
13. Meta Economy and Unlocks - depends on save/profile, character roster, and pets.
14. Chapter and Map Construction - depends on camera, events, and director.
15. Co-op Networking - depends on solo runtime stability, save/profile, run director, and player controller.

### Presentation Layer

1. Damage Numbers and Combat Feedback - depends on project shell, damage, and pooling.
2. In-Run HUD and Draft UI - depends on project shell, XP/drafts, and page events.
3. Audio and Music Layers - depends on event bus and combat state.
4. Accessibility and Options - depends on UI and input.

### Polish Layer

1. Tutorial and First-Run Flow - depends on HUD, page events, and core gameplay.

---

## Recommended Design Order

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Godot Project Shell | MVP | Foundation | lead-programmer, godot-specialist | S |
| 2 | Resource Data Schemas | MVP | Foundation | systems-designer, godot-gdscript-specialist | M |
| 3 | Input and Rebinding | MVP | Foundation | ux-designer, godot-specialist | S |
| 4 | Player Controller and Dash | MVP | Core | game-designer, gameplay-programmer | M |
| 5 | Camera and 2.5D Lighting | MVP | Core | technical-artist, godot-specialist | M |
| 6 | Damage and Status Model | MVP | Core | systems-designer, gameplay-programmer | M |
| 7 | Object Pooling and Performance Debug | MVP | Foundation | performance-analyst, gameplay-programmer | M |
| 8 | Weapons and Auto-Attacks | MVP | Feature | systems-designer, gameplay-programmer | L |
| 9 | Pagecraft Materials and Grid | MVP | Feature | game-designer, gameplay-programmer | L |
| 10 | Enemies and AI Movement | MVP | Feature | game-designer, ai-programmer | M |
| 11 | Run Director and Finite Spawning | MVP | Feature | systems-designer, gameplay-programmer | M |
| 12 | XP, Leveling, and Upgrade Drafts | MVP | Feature | systems-designer, ui-programmer | M |
| 13 | Page Events and Objectives | MVP | Feature | game-designer, level-designer | M |
| 14 | Boss and Victory Flow | MVP | Feature | game-designer, gameplay-programmer | M |
| 15 | Damage Numbers and Combat Feedback | MVP | Presentation | ui-programmer, technical-artist | S |
| 16 | In-Run HUD and Draft UI | MVP | Presentation | ux-designer, ui-programmer | M |
| 17 | Character Roster and Mastery | Vertical Slice | Feature | systems-designer, gameplay-programmer | M |
| 18 | Pets and Companion Combat | Vertical Slice | Feature | systems-designer, gameplay-programmer | M |
| 19 | Save, Profile, and Migration | Vertical Slice | Foundation | lead-programmer, qa-lead | M |
| 20 | Hub, Chapter Select, and Restoration | Vertical Slice | Feature | ux-designer, gameplay-programmer | M |
| 21 | Meta Economy and Unlocks | Vertical Slice | Feature | economy-designer, systems-designer | M |
| 22 | Chapter and Map Construction | Vertical Slice | Feature | level-designer, technical-artist | M |
| 23 | Audio and Music Layers | Vertical Slice | Presentation | audio-director, sound-designer | S |
| 24 | Accessibility and Options | Alpha | Presentation | accessibility-specialist, ux-designer | M |
| 25 | Tutorial and First-Run Flow | Alpha | Polish | ux-designer, game-designer | M |
| 26 | Co-op Networking | Full Vision | Feature | network-programmer, gameplay-programmer | L |

---

## Circular Dependencies

- None found in this first-pass index.

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|------------------|------------|
| Pagecraft Materials and Grid | Technical / Design | Needs readable terrain-state changes under high enemy and VFX load | Prototype early with dirty-chunk updates and strict visual readability tests |
| Camera and 2.5D Lighting | Technical / Art | 2.5D paper diorama must read clearly during crowded combat | Build a lit paper arena prototype before content production |
| Object Pooling and Performance Debug | Technical | Damage numbers, projectiles, enemies, decals, pets, and VFX can overwhelm frame budget | Build pooling and debug overlays before scaling content |
| Run Director and Finite Spawning | Design / Technical | Finite-map pacing must avoid empty downtime and unfair crowding | Prototype spawn budgets and test a 25-minute boss timeline |
| Co-op Networking | Scope | Co-op can distort solo architecture and expand testing cost | Keep post-MVP; define seams but do not implement before solo vertical slice |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 29 |
| Design docs started | 19 |
| Design docs reviewed | 19 |
| Design docs approved | 19 |
| MVP systems designed | 19/19 |
| Vertical Slice systems designed | 0/7 |

---

## Next Steps

- [x] Review and approve MVP systems enumeration.
- [x] Design MVP-tier systems first with `/design-system [system-name]`.
- [x] Complete MVP system GDDs through `In-Run HUD and Draft UI`.
- [ ] Run `/gate-check systems-design` after MVP systems are designed.
- [ ] Start implementation with `Resource Data Schemas`, then `Input and Rebinding`, then `Player Controller and Dash`.
