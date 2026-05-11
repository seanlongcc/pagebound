# Adoption Plan

> **Generated**: 2026-05-10
> **Project phase**: Systems Design
> **Engine**: Godot 4.6.2 (configured during automatic setup; root GDD targets Godot 4.6.x)
> **Template version**: v1.0+

Work through these steps in order. Check off each item as you complete it.
Re-run `/adopt` anytime to check remaining gaps.

---

## Step 1: Fix Blocking Gaps

### 1a. Convert the root GDD into template-readable artifacts

**Problem**: `PAGEBOUND_CODEX_GDD_v1_5.md` has strong design content, but it is a single root-level master document. Template skills expect `design/gdd/game-concept.md`, `design/gdd/systems-index.md`, and per-system GDD files with required sections.

**Impact**: `/map-systems`, `/design-system`, `/create-architecture`, and `/create-stories` may miss requirements or fail to find inputs.

**Fix**:

```text
/map-systems
/design-system retrofit PAGEBOUND_CODEX_GDD_v1_5.md
```

**Manual setup**:

- Preserve `PAGEBOUND_CODEX_GDD_v1_5.md` as the source-of-truth master GDD until derived artifacts are reviewed.
- Create `design/gdd/game-concept.md` from the project vision, pillars, genre, run structure, and core Pagecraft mechanic.
- Create `design/gdd/systems-index.md` listing MVP systems, dependencies, priority, and status.
- Split or retrofit MVP system GDDs from the master GDD.

**2026-05-10 setup note**: Starter `game-concept.md` and `systems-index.md` were created from the root GDD. Per-system GDDs still need retrofit work before this item is complete.

**Time**: 1 session

- [ ] Root GDD is represented by template-readable design artifacts.

---

## Step 2: Fix High-Priority Gaps

### 2a. Configure the engine and language

**Problem**: The root GDD targets Godot 4.6.x, but `.codex/docs/technical-preferences.md` still contains setup placeholders.

**Impact**: Engine specialists, ADR checks, test setup, and implementation guidance cannot reliably route work.

**Fix**:

```text
/setup-engine godot 4.6.2
```

**Time**: 15-30 min

- [x] `AGENTS.md` technology stack is pinned to Godot 4.6.2.
- [x] `.codex/docs/technical-preferences.md` is populated.
- [x] `docs/engine-reference/godot/VERSION.md` is verified against current official Godot docs.

### 2b. Create the systems index

**Problem**: No `design/gdd/systems-index.md` exists.

**Impact**: System dependency ordering, MVP scope, gate checks, and story generation do not have a stable source.

**Fix**:

```text
/map-systems
```

**Time**: 30 min to 1 session

- [x] `design/gdd/systems-index.md` exists.
- [x] Status values use exact strings only: `Not Started`, `In Progress`, `In Review`, `Designed`, `Approved`, `Needs Revision`.
- [x] Table includes System name, Layer, Priority, and Status columns.

### 2c. Create MVP system GDDs with required sections

**Problem**: No per-system GDDs exist under `design/gdd/`.

**Impact**: `/create-stories` cannot generate implementation stories with reliable acceptance criteria or dependencies.

**Fix**:

```text
/design-system retrofit PAGEBOUND_CODEX_GDD_v1_5.md
```

**Required sections per GDD**:

- `## Overview`
- `## Player Fantasy`
- `## Detailed Design` or `## Core Rules`
- `## Formulas`
- `## Edge Cases`
- `## Dependencies`
- `## Tuning Knobs`
- `## Acceptance Criteria`

**Time**: 1 session per large system, less for small systems

- [ ] MVP combat/run loop GDD exists.
- [ ] Pagecraft GDD exists.
- [ ] Progression/drafts/evolutions GDD exists.
- [ ] Weapons/items data GDD exists.
- [ ] Enemies/boss/director GDD exists.
- [ ] UI/HUD GDD or UX spec exists.

### 2d. Extract architecture into standalone docs

**Problem**: Architecture notes exist inside the master GDD, but there is no `docs/architecture/architecture.md` and no ADR files.

**Impact**: `/architecture-review`, `/create-control-manifest`, and later story-readiness checks have no accepted architecture sources.

**Fix**:

```text
/create-architecture
/architecture-decision
```

**Time**: 1-2 sessions

- [ ] `docs/architecture/architecture.md` exists.
- [ ] At least 3 foundation ADRs exist and are accepted.

### 2e. Preserve current TR registry and bootstrap traceability later

**Problem**: `docs/architecture/tr-registry.yaml` exists, but no architecture traceability document exists yet.

**Impact**: Stable requirement IDs cannot be meaningfully mapped until GDDs and ADRs exist.

**Fix**:

```text
/architecture-review
```

**Time**: 1 session

- [ ] `docs/architecture/architecture-traceability.md` exists.
- [ ] TR registry maps requirements to source design and architecture docs.

### 2f. Create production tracking from the GDD milestone plan

**Problem**: The GDD contains milestones, but there are no production sprint or milestone files.

**Impact**: `/sprint-status`, `/story-done`, milestone review, and production tracking cannot operate on durable artifacts.

**Fix**:

```text
/sprint-plan
```

**Time**: 30 min

- [ ] `production/sprints/` contains the first sprint plan.
- [ ] `production/sprint-status.yaml` exists.

---

## Step 3: Bootstrap Infrastructure

### 3a. Register existing requirements

Run `/architecture-review` after GDDs and ADRs exist. This bootstraps or updates the TR registry from current design and architecture sources.

**Time**: 1 session

- [ ] `docs/architecture/tr-registry.yaml` is current.

### 3b. Create control manifest

Run `/create-control-manifest`.

**Time**: 30 min

- [ ] `docs/architecture/control-manifest.md` created.

### 3c. Create sprint tracking file

Run `/sprint-plan update`.

**Time**: 5 min if sprint plan already exists as markdown

- [ ] `production/sprint-status.yaml` created.

### 3d. Set authoritative project stage

Run `/gate-check systems-design` after the design adoption artifacts exist.

**Time**: 5 min

- [x] `production/stage.txt` written.

**Note**: The stage file was written as part of automatic setup. Run `/gate-check systems-design` later to validate the stage formally.

---

## Step 4: Medium-Priority Gaps

### 4a. Add formulas and tuning sections to per-system GDDs

**Problem**: The master GDD contains many tuning values, curves, budgets, and data examples, but they are not organized under template-required per-system headings.

**Impact**: Balance checks and story generation may lose important numeric constraints.

**Fix**:

```text
/design-system retrofit design/gdd/[system].md
```

**Time**: 30 min per system

- [ ] Each MVP system GDD has formulas and tuning knobs.

### 4b. Create test setup once engine config is pinned

**Problem**: No test framework or test files exist.

**Impact**: Later implementation stories will lack a consistent verification path.

**Fix**:

```text
/test-setup
```

**Time**: 30 min

- [ ] Test framework selected.
- [ ] Smoke test path documented.

### 4c. Prototype the core loop before production planning

**Problem**: No prototype exists for combat feel, Pagecraft, camera, or 2.5D rendering.

**Impact**: Production stories may encode untested assumptions.

**Fix**:

```text
/prototype
```

**Time**: 1 session

- [ ] Throwaway prototype validates movement, dash, enemy pressure, Pagecraft marks, and camera readability.

### 4d. Create UX specs for key screens

**Problem**: The GDD lists UI screens, but no standalone UX specs exist.

**Impact**: UI implementation stories may miss navigation, accessibility, and state handling details.

**Fix**:

```text
/ux-design
```

**Time**: 30 min per screen or flow

- [ ] Main menu UX spec exists.
- [ ] In-run HUD UX spec exists.
- [ ] Level-up draft UX spec exists.

### 4e. Create an art bible from the root GDD style direction

**Problem**: Art direction is documented in the GDD, but there is no standalone art bible.

**Impact**: Asset prompts, visual review, and consistency checks have no dedicated source.

**Fix**:

```text
/art-bible
```

**Time**: 1 session

- [ ] Art bible exists.

---

## Step 5: Optional Improvements

### 5a. Keep root GDD as archive once derived docs are approved

**Problem**: The master GDD is useful, but future skills should read smaller canonical artifacts.

**Impact**: Without a clear policy, future changes may duplicate or conflict between root GDD and derived files.

**Fix**:

- Keep `PAGEBOUND_CODEX_GDD_v1_5.md` as `source-of-truth until adoption complete`.
- After derived docs are approved, mark it as an archived reference or move it under a source/archive folder.

**Time**: 5 min after adoption

- [ ] Root GDD status is documented.

---

## What to Expect from Existing Stories

Existing stories continue to work with all template skills. New format checks
(TR-ID validation, manifest version staleness) auto-pass when fields are absent,
so nothing breaks. They will not benefit from staleness tracking until regenerated.
Do not regenerate stories that are in progress or done.

This project currently has no existing stories.

---

## Re-run

Run `/adopt` again after completing Step 3 to verify all blocking and high gaps
are resolved. The new run will reflect the current state of the project.
