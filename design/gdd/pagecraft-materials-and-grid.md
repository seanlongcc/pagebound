# Pagecraft Materials and Grid

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: The Page Is Alive

## Overview

`Pagecraft Materials and Grid` defines the mutable battlefield layer: material marks, chunked grid storage, deposits, decay, dash activation, path sampling, visual overlays, and material queries used by weapons, pets, enemies, and Page Events. It owns page-state simulation. It does not own weapon cooldowns, damage resolution, enemy AI, map authoring, or final shader art.

## Player Fantasy

The page remembers the fight. Attacks color the ground, dashes wake marks up, enemies corrupt space, and the player turns a fragile paper battlefield into a living weapon.

## Detailed Design

### Core Rules

1. MVP Pagecraft uses a chunked grid or equivalent packed array structure, not one `Resource`/node per cell.
2. Pagecraft exists on the X/Z gameplay plane and maps world positions to cells/chunks.
3. MVP material support includes at least Waxlight, Color Bloom, Dreamsap, Star Sticker, and Clean Page.
4. Deposits can be circles, lines, trails, splats, decals, or authored zone masks.
5. Materials define density, duration/decay, team/source, material tags, and interaction channels.
6. Dash activation samples along the dash path and triggers material-specific effects.
7. Material queries support movement modifiers, damage zones, enemy path effects, and visual rendering.
8. Simulation separates data from visuals; renderer consumes dirty chunks/regions.
9. Pagecraft damage/status routes through Damage and Status Model.
10. Pagecraft marks must remain readable and not hide boss/player danger.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `Clean` | Cell/chunk has no active material density. | `Marked` |
| `Marked` | Friendly or neutral material affects gameplay/visuals. | `Activated`, `Decaying`, `Corrupted`, `Clean` |
| `Activated` | Dash/event/weapon triggered a material effect. | `Marked`, `Decaying`, `Clean` |
| `Corrupted` | Enemy/blankness material contests or overrides the cell. | `Cleansed`, `Decaying` |
| `Cleansed` | Clean Page or effect removes hostile material. | `Clean`, `Marked` |
| `Decaying` | Material density is fading. | `Clean`, `Marked` |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Godot Project Shell | Upstream | Provides `RunRoot/Pagecraft` mount. |
| Resource Data Schemas | Upstream | Provides material tag definitions and behavior refs. |
| Weapons and Auto-Attacks | Producer | Deposits marks and requests dash interaction metadata. |
| Player Controller and Dash | Producer | Sends dash path samples. |
| Damage and Status Model | Downstream | Resolves Pagecraft damage/status effects. |
| Enemies and AI Movement | Consumer/producer | Reads movement effects and can deposit hostile marks. |
| Page Events and Objectives | Consumer/producer | Uses event zones, cleanse/fill objectives, hazard marks. |
| Object Pooling and Performance Debug | Supporting | Pools decals/visuals and shows active chunks. |

## Formulas

`cell = floor((world_xz - origin_xz) / cell_size)`

`chunk = floor(cell / chunk_size_cells)`

`density_after_decay = max(0, density - decay_rate * delta_seconds)`

`dash_activation_strength = sum(material_density_along_path) * dash_material_multiplier`

Invalid states:

- One node/resource per Pagecraft cell in production.
- Unknown material tag in active mark.
- Dash path activation mutates unrelated gameplay systems directly.
- Dirty chunk list grows without clearing.
- Pagecraft visual overlays hide boss telegraphs.

## Edge Cases

- If mark is deposited outside finite page bounds, clamp or reject with debug warning.
- If two friendly materials overlap, blending/priority comes from material definitions.
- If friendly and hostile materials overlap, contest/cleanse rules decide final density.
- If chunk becomes empty after decay, clear visuals and remove from active update list.
- If time is paused for draft UI, Pagecraft decay pauses unless a system explicitly uses real-time effects.
- If performance drops, renderer may lower visual fidelity while simulation remains authoritative.

## Dependencies

- **Godot Project Shell**: Required mount.
- **Resource Data Schemas**: Required material tags.
- **Damage and Status Model**: Required damage/status routing.
- **Object Pooling and Performance Debug**: Required for visuals/decals at scale.
- **Player Controller and Dash**: Required dash path activation.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `cell_size_meters` | `0.5` | `0.25-2.0` | Prototype grid resolution. |
| `chunk_size_cells` | `16` | `8-64` | Dirty update unit. |
| `default_mark_duration_seconds` | `8.0` | `1.0-60.0` | Per material override. |
| `max_active_chunks` | `512` | `64-4096` | Debug warning threshold. |
| `dash_sample_spacing_meters` | `0.25` | `0.1-1.0` | Path query fidelity. |

## Visual/Audio Requirements

- Materials must read as page marks, not generic floor decals.
- Friendly, hostile, and neutral marks need distinct value/shape language.
- Dirty chunk renderer can use overlays, decals, mesh ribbons, masks, or shaders.
- Dash activation should have material-specific VFX/SFX hooks.

## UI Requirements

- HUD does not need raw grid data.
- Debug overlay shows active chunks, material counts, dirty chunk count, dash sample result, and top material coverage.
- Page Event UI may show objectives based on coverage/cleanse/fill progress.

## Acceptance Criteria

- Pagecraft supports depositing and decaying material marks on finite page bounds.
- Dash path can sample and activate materials.
- Weapons/pets/enemies/events can query material state without owning storage.
- Damage/status from Pagecraft routes through Damage Model.
- Renderer updates from dirty chunks/regions, not full-grid redraw every frame.

## Open Questions

- Exact render technique is prototype-driven: decals, mesh ribbons, shader masks, or hybrid.
- Final material list expands after MVP proof.

