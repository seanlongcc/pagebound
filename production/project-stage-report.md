# Project Stage Analysis Report

**Generated**: 2026-05-10
**Last Updated**: 2026-05-13
**Stage**: Technical Setup moving into early Production prototype
**Stage Confidence**: CONCERNS - `production/stage.txt` still correctly records the formal gate as Technical Setup, but the repo now has a smoke-tested first playable prototype and enough implementation to behave like early Production.
**Analysis Scope**: Full project

---

## Executive Summary

Pagebound has completed MVP systems design and now has a working Godot first-playable prototype on `feat/mvp`. The project should not pause to fully design every weapon, event, pet, enemy, and character before more implementation. The best next move is to keep building in narrow, high-standard vertical slices so design quality is validated through play feel.

The right content strategy is **one exemplar per category before bulk production**: one polished character, one polished pet, one polished Page Event, one polished boss encounter, one polished enemy family set, and one polished weapon/passive bundle. Each exemplar should set the quality bar, resource shape, smoke-test pattern, and art/UX expectations before scaling to many variants.

**Current Focus**: stabilize the prototype architecture, move hardcoded tuning into resources, then build a polished exemplar vertical slice.
**Blocking Issues**: `src/runtime/first_playable_runtime.gd` is over the local guardrail; production planning is still informal; Vertical Slice systems are not designed yet.
**Estimated Time to Next Stage**: 2-4 focused sessions to clean runtime boundaries and define the first exemplar slice; more to reach formal Production gate.

---

## Completeness Overview

### Design Documentation

- **Status**: MVP design complete enough for implementation; Vertical Slice design not started.
- **Files Found**: 25 GDD/review files in `design/gdd/`.
- **Systems Index**: 29 total systems, 19 MVP systems approved, 0/7 Vertical Slice systems designed.
- **Current Ownership**:
  - Root GDD keeps stable rules and cross-system intent.
  - `design/gdd/mvp-weapon-candidate-pool.md` owns exact weapon candidate rows and tuning.
  - `design/gdd/mvp-item-candidate-pool.md` owns exact item and Wonder Box rows/tuning.
- **Key Gaps**:
  - [ ] Vertical Slice systems need focused GDDs when they become implementation blockers: character roster, pets, save/profile, hub/meta, chapter construction, audio.
  - [ ] Existing MVP candidate pools need implementation-selected subsets, not full-roster production immediately.
  - [ ] Root GDD and focused sheets now need periodic consistency checks after source-of-truth reshaping.

### Source Code

- **Status**: first playable prototype implemented; not production-structured enough for sustained feature growth.
- **Files Found**: 35 GDScript source files, about 6382 lines in `src/`.
- **Major Systems Identified**:
  - `src/runtime/` - run orchestration, draft flow, director, upgrades, Page Event prototype.
  - `src/data/` - schema/resource foundation and prototype content factory.
  - `src/weapons/` - auto weapon manager plus MVP effect helpers.
  - `src/pagecraft/` - Pagecraft mark deposit, activation, damage, and debug hooks.
  - `src/player/`, `src/camera/`, `src/combat/`, `src/feedback/`, `src/enemies/`, `src/pickups/`, `src/input/`.
- **Key Gaps**:
  - [ ] `src/runtime/first_playable_runtime.gd` remains over the local 800-line guardrail and is tracked by bead `pagebound-hup`.
  - [ ] More prototype content needs to move from fallback/runtime code into `.tres` resources.
  - [ ] Save/profile, pets, real character variants, boss actor flow, and hub/meta systems are not implemented.

### Architecture Documentation

- **Status**: useful ADR foundation exists, but no master architecture overview/control manifest yet.
- **ADRs Found**: 7 decisions in `docs/architecture/`.
- **Coverage**:
  - Resource schemas, player input, camera follow, event bus/damage, pooled feedback, first combat prototype, and Pagecraft hook are documented.
  - Runtime orchestration and prototype content ownership have evolved beyond the current ADR set.
- **Key Gaps**:
  - [ ] No standalone `docs/architecture/architecture.md`.
  - [ ] No generated control manifest for implementation rules.
  - [ ] Need architecture decision or architecture note after extracting runtime orchestration.

### Production Management

- **Status**: Beads are active; sprint/milestone files are not.
- **Found**:
  - `production/stage.txt`: Technical Setup.
  - `production/session-state/active.md`: current first-playable facts and validation history.
  - `production/gates/systems-design-to-technical-setup-2026-05-11.md`.
  - No `production/sprints/` or `production/milestones/` files.
- **Key Gaps**:
  - [ ] No sprint plan for the next playable increment.
  - [ ] No explicit milestone definition for "exemplar vertical slice".
  - [ ] Current status lives partly in session notes and beads, not a producer-facing plan.

### Testing

- **Status**: strong smoke coverage for prototype stage; limited unit/integration layering.
- **Test Files**: 30 GDScript smoke checks, 60 files including Godot `.uid` sidecars.
- **Coverage by System**:
  - Good: shell, schemas, player movement/dash, camera, damage model, damage numbers, combat, XP, drafts, Pagecraft, run director, Page Events, HUD, first playable, vertical slice.
  - Weak/missing: save/profile, pets, characters, boss actor flow, hub/meta, content migration, broad performance soak.
- **Key Gaps**:
  - [ ] No full Godot test helper layer beyond smoke scripts.
  - [ ] No automated perf/soak baseline for dense late-run content.
  - [ ] Exemplar content needs smoke tests before bulk variants.

### Prototypes

- **Active Prototypes**: 0 separate `prototypes/` directories.
- **Current Prototype Location**: main Godot project on `feat/mvp`.
- **Key Gap**:
  - [ ] Prototype is no longer throwaway; architecture cleanup is required before more content is added.

---

## Stage Classification Rationale

**Why Technical Setup moving into early Production prototype?**

The formal stage remains Technical Setup because the project has not passed a Production gate and still lacks master architecture/control-manifest/sprint artifacts. However, implementation has moved past a bare setup stage: the Godot project runs, the core loop exists, and 30 smoke checks cover a playable prototype.

**Indicators**:

- `production/stage.txt` explicitly says Technical Setup.
- MVP systems are designed and reviewed.
- First playable run loop exists in `Main.tscn` and `src/`.
- Drafts, prototype weapons, one passive, two enemy families, one Page Event, death/retry, and 5:00 summary exist.
- Smoke coverage is substantial for the prototype.

**Next stage requirements**:

- [ ] Extract runtime orchestration below guardrail.
- [ ] Move remaining prototype tuning/content into resource data.
- [ ] Define an exemplar vertical-slice milestone.
- [ ] Implement one high-standard exemplar each for character, pet, event, boss, enemy set, and weapon/passive bundle.
- [ ] Create a sprint plan and update stage only after a gate review.

---

## Gaps Identified

### Critical Gaps

1. **Runtime orchestration is too large**
   - **Impact**: Adding pets, bosses, save/profile, more events, and more content directly into `FirstPlayableRuntime` will compound maintenance risk.
   - **Question**: Should the next implementation session claim `pagebound-hup` and extract orchestration before new gameplay?
   - **Suggested Action**: Do `pagebound-hup` first.

2. **No exemplar milestone definition**
   - **Impact**: The project can drift between designing everything and implementing random pieces.
   - **Question**: Which exemplar should define the standard first: character, pet, Page Event, boss, or weapon/passive bundle?
   - **Suggested Action**: Define a small milestone: "one chapter-ready run slice with one polished sample per major content category."

### Important Gaps

3. **Vertical Slice systems are not designed**
   - **Impact**: Pets, characters, save/profile, hub/meta, and chapter construction will need design before durable implementation.
   - **Question**: Should these be designed all at once, or just-in-time as each exemplar becomes next?
   - **Suggested Action**: Design just-in-time. Start with the next exemplar's focused doc only.

4. **Production planning is informal**
   - **Impact**: Beads track tasks, but there is no single sprint/milestone plan for the next playable increment.
   - **Question**: Should the next plan be a sprint or a milestone definition?
   - **Suggested Action**: Create a short sprint plan after `pagebound-hup` or alongside it.

### Nice-to-Have Gaps

5. **No imported art/audio assets yet**
   - **Impact**: Gameplay readability and "up to my standards" feel cannot be fully judged with primitives.
   - **Question**: Should exemplar content include curated placeholder-quality assets with provenance, or stay primitive until mechanics pass?
   - **Suggested Action**: Use curated assets only for the exemplar slice after mechanics stabilize.

---

## Recommended Next Steps

### Immediate Priority

1. **Extract first playable runtime orchestration**
   - Bead: `pagebound-hup`.
   - Why: prevents every new feature from worsening the biggest current code health risk.
   - Effort: M.

2. **Define the Exemplar Vertical Slice**
   - Suggested output: one milestone or sprint plan.
   - Include one high-standard example of each:
     - 1 character with distinct dash/passive.
     - 1 pet with attack, tier progression, and Pagecraft hook.
     - 1 Page Event with objective, UI, reward, fail consequence.
     - 1 boss with warning, health bar, phase or telegraph, victory handoff.
     - 1 enemy family set beyond the two prototypes.
     - 1 weapon/passive bundle from the focused MVP sheets.
   - Effort: S/M.

### Short-Term

3. **Make content resource-driven**
   - Move prototype weapon, passive, enemy, upgrade, and event values into `.tres`.
   - Add guard smoke checks for resource coverage.

4. **Implement the first polished content bundle**
   - Best candidate: one weapon/passive/Pagecraft loop because it tests the heart of the game.
   - Then add enemy/event pressure around it.

5. **Design only the next blocking Vertical Slice system**
   - If pet is next: create `design/gdd/pets-and-companion-combat.md`.
   - If character is next: create `design/gdd/character-roster-and-mastery.md`.
   - Avoid designing all future content in one pass.

### Medium-Term

6. **Add save/profile when meta becomes real**
   - Required before Wonder Box, character unlocks, pet unlocks, or chapter progression matter.

7. **Replace primitives in the exemplar slice**
   - Import curated assets only with source URL, creator, license, cost, and commercial-use note.

8. **Run a gate/milestone review**
   - Use it to decide when to move from Technical Setup to Production formally.

---

## Direct Answer: Design All First Or Implement Now?

Implement now, but do it through polished exemplars.

Do not design all characters, pets, events, enemies, and bosses before implementation. That creates too much untested paper design. Instead, create one of each up to your standards, verify it in-game, then use those as production templates.

This gives you:

- real play-feel data,
- a quality bar for future content,
- reusable resource/schema patterns,
- smoke-test examples,
- less wasted design work.

---

## Follow-Up Skills To Run

- `/sprint-plan` - create the next work plan around `pagebound-hup` and exemplar vertical slice.
- `/design-system character-roster-and-mastery` - when character exemplar becomes next.
- `/design-system pets-and-companion-combat` - when pet exemplar becomes next.
- `/design-system save-profile-and-migration` - before durable meta progression.
- `/milestone-review` - after the exemplar slice is implemented.

---

## Appendix: Current Counts

```text
design/gdd/             25 files
design/narrative/        0 files
design/levels/           0 files

src/*.gd                35 files
src LOC               6382 lines

tests/smoke/*.gd        30 files
tests total             60 files including .uid sidecars

docs/architecture/       7 ADRs plus tr-registry.yaml
production/              6 files
prototypes/              0 files
```
