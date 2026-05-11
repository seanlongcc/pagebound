# MVP Systems Design Review

> **Date**: 2026-05-11
> **Scope**: MVP GDDs in `design/gdd/`
> **Mode**: Lean cross-GDD review
> **Verdict**: PASS WITH ACCEPTED RISKS
> **Reviewer**: Codex

## Summary

The MVP Systems Design package is ready to advance to Technical Setup / architecture work. All 19 MVP systems listed in `design/gdd/systems-index.md` have approved design documents, dependencies are mapped, root GDD commitments are preserved, and the implementation path is clear.

This review accepts that some exact tuning values, art choices, and implementation API names remain prototype-owned. Those are not blockers for architecture or first implementation stories.

## Reviewed Files

- `design/gdd/godot-project-shell.md`
- `design/gdd/input-and-rebinding.md`
- `design/gdd/player-controller-and-dash.md`
- `design/gdd/camera-and-2-5d-lighting.md`
- `design/gdd/resource-data-schemas.md`
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

## Artifact Checks

| Check | Result |
|---|---|
| Systems index exists and enumerates MVP systems | PASS |
| All 19 MVP GDD files exist | PASS |
| Required GDD sections are present in new MVP docs | PASS |
| Placeholder text removed from MVP system docs | PASS |
| MVP system statuses updated to `Approved` | PASS |
| MVP progress tracker updated to `19/19` | PASS |
| Godot Project Shell remains approved implementation baseline | PASS |

## Cross-GDD Consistency

### Passed Rules

- Godot runtime direction is consistent: Godot 4.6.2, typed GDScript, 3D runtime, X/Z gameplay plane, `CharacterBody3D` for player/enemy movement where practical.
- Root GDD counts are preserved: 20 shared weapons, 20 passive items, 5 weapon slots, 5 passive slots, 5 pet tiers, 10 weapon levels, 5 passive levels, 10 character mastery levels, and exactly 3 draft choices.
- Run timing is consistent: Page Events at 5:00, 10:00, 15:00, 20:00 with 3-minute countdowns; boss/finale at 25:00; normal victory target around 30:00.
- Evolution rule is consistent: level 10 weapon plus level 5 compatible passive catalyst tag; no Pagecraft evolution gate; passive item is not consumed.
- Pagecraft ownership is consistent: grid/material simulation belongs to `Pagecraft Materials and Grid`; weapons, pets, enemies, and events only request deposits/queries/activations.
- Damage ownership is consistent: `Damage and Status Model` resolves damage; damage numbers, audio, UI, weapons, enemies, pets, and Pagecraft do not recompute final damage.
- Pooling ownership is consistent: high-volume projectiles, enemies, pickups, VFX, damage numbers, pet attacks, decals, and telegraphs use shared pooling policy.
- UI ownership is consistent: shell provides slots; `In-Run HUD and Draft UI` owns run UI presentation; gameplay systems provide data.

### Accepted Risks

| Risk | Severity | Decision |
|---|---|---|
| Exact event bus placement is open: scene-owned service vs autoload. | Low | Resolve during architecture ADR. |
| Pagecraft visual renderer technique is open: decals, mesh ribbons, shader masks, or hybrid. | Medium | Resolve through prototype and technical art test. |
| Damage number implementation is open: world-space text/quads vs screen-space projection. | Medium | Resolve through performance/readability prototype. |
| Some tuning values are defaults, not final balance. | Low | Tune after first playable loop. |
| Asset style is not locked yet. | Medium | Use primitive placeholders until asset direction pass selects cohesive source family. |

## Dependency Review

MVP dependencies are acyclic enough for implementation order:

1. `Godot Project Shell`
2. `Resource Data Schemas`
3. `Input and Rebinding`
4. `Runtime Event Bus`
5. `Player Controller and Dash`
6. `Camera and 2.5D Lighting`
7. `Damage and Status Model`
8. `Object Pooling and Performance Debug`
9. `Weapons and Auto-Attacks`
10. `Passive Items and Drafts`
11. `XP, Leveling, and Upgrade Drafts`
12. `Evolution System`
13. `Pagecraft Materials and Grid`
14. `Enemies and AI Movement`
15. `Run Director and Finite Spawning`
16. `Page Events and Objectives`
17. `Boss and Victory Flow`
18. `Damage Numbers and Combat Feedback`
19. `In-Run HUD and Draft UI`

`Camera and 2.5D Lighting` can begin after a basic player target exists. `Object Pooling and Performance Debug` should be implemented before scaling enemies, damage numbers, Pagecraft visuals, or weapon VFX.

## Gate Recommendation

Advance from **Systems Design** to **Technical Setup** with accepted risks. Next work should create architecture/ADR/control artifacts and then first implementation stories.

Recommended next practical implementation path:

1. Implement `Resource Data Schemas`: typed Resource classes, registries, placeholder content, schema smoke validation.
2. Implement `Input and Rebinding`: action map, typed input access, default bindings.
3. Implement `Player Controller and Dash`: moving `CharacterBody3D` on the paper page with dash path event.
4. Implement `Camera and 2.5D Lighting`: follow camera, readable lighting, finite bounds.
5. Implement `Damage and Status Model` plus minimal `Runtime Event Bus`.

## Notes

- Entity registry is currently empty; consistency review relied on full GDD reads and root GDD constraints.
- No third-party gameplay/art assets were imported as part of systems design.
- Godot Project Shell is already implemented and smoke-validated; remaining MVP systems are design-approved, not yet implemented.
