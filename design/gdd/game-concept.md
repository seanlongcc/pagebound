# Game Concept: Pagebound

*Created: 2026-05-10*
*Status: Draft*
*Source*: `PAGEBOUND_CODEX_GDD_v1_5.md`

---

## Elevator Pitch

Pagebound is a 2.5D storybook action roguelite where tiny hand-drawn heroes fight living scribbles, blankness, and torn-page nightmares by flooding a magical page with color, spells, stickers, pets, and huge damage numbers.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Survivors-like action roguelite with finite-map exploration and timed page events |
| **Platform** | PC / Steam first, Steam Deck optimization target, co-op later |
| **Target Audience** | Players who enjoy power-fantasy roguelites, readable buildcraft, pets, collections, and stylized hand-drawn worlds |
| **Player Count** | Solo first; local/LAN debug co-op second; Steam co-op later |
| **Session Length** | Standard run targets about 30 minutes, with boss/finale at 25:00 |
| **Monetization** | Premium assumed; not yet formally decided |
| **Estimated Scope** | Large indie scope |
| **Comparable Titles** | Vampire Survivors, HoloCure, Brotato, Hades for run clarity and build momentum |

---

## Core Fantasy

The story is being erased, but the player is powerful enough to redraw it. A run begins with a small doodle hero on a fragile storybook page and grows into a storm of color, waxlight, stickers, pets, spells, and cascading damage numbers.

The fantasy is not barely surviving. The fantasy is overwhelming the page with readable, joyful power while restoring a magical storybook world.

---

## Unique Hook

The battlefield is a finite living page. Combat does not happen on a neutral floor: color spreads, paper folds, stickers stick, dream trails glow, blankness creeps, and dash timing can activate or reshape page marks.

---

## Player Experience Analysis

### Target Aesthetics

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** | 1 | Hand-drawn 2.5D diorama lighting, large readable effects, satisfying damage numbers, layered music and SFX |
| **Fantasy** | 2 | Doodle heroes, magical storybook kingdoms, pets, crowns, moons, stars, paper castles, living page materials |
| **Challenge** | 3 | Positioning, dash timing, finite-map routing, page event decisions, boss timing, build choices |
| **Expression** | 4 | Weapon/passive builds, character identity, pet choices, evolutions, page material synergies |
| **Discovery** | 5 | Chapters, events, unlocks, synergies, pet quests, storybook restoration |
| **Narrative** | 6 | Storybook restoration and chapter progression |
| **Fellowship** | 7 | Co-op later, not MVP-critical |
| **Submission** | 8 | Runs should be approachable, but the project is not primarily cozy or idle |

### Key Dynamics

- Players route across a finite page instead of standing in one optimal point.
- Players learn which page materials, dash interactions, and weapon synergies create strong zones.
- Players chase timed page events while balancing XP, safety, and boss readiness.
- Players form identity around character starters, pets, and evolutions.

### Core Mechanics

1. Planar movement and dash on an X/Z 3D gameplay plane.
2. Auto-attacking weapons and 3-choice level-up drafts.
3. Pagecraft materials that alter terrain, damage, movement, and cleansing.
4. Timed page events that create mid-run objectives and rewards.
5. Meta progression through characters, pets, chapters, and restoration.

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** | Build choices, route choices, page event priorities, pet and character selection | Core |
| **Competence** | Better positioning, dash timing, build planning, boss readiness, event routing | Core |
| **Relatedness** | Pets, character identity, restoration, later co-op | Supporting |

### Player Type Appeal

- [x] **Achievers** - chapter restoration, mastery tracks, pet tiers, unlocks, boss victories.
- [x] **Explorers** - synergies, page material interactions, events, chapter variations.
- [x] **Socializers** - later co-op and build sharing.
- [ ] **Killers/Competitors** - PvP is not a focus.

### Flow State Design

- **Onboarding curve**: Movement, dash, auto-attacks, and first page material must read clearly in the first 30 seconds.
- **Difficulty scaling**: Enemy density and boss pressure increase while player power ramps dramatically.
- **Feedback clarity**: Damage numbers, material marks, pet attacks, and page states show progress.
- **Recovery from failure**: Runs should return quickly to character/build selection and preserve meta progress.

---

## Core Loop

### Moment-to-Moment

Move, kite, dash, collect XP, trigger page marks, avoid corruption, and watch auto-attacks clear enemies.

### Short-Term

Choose upgrades, route to page events at timed intervals, build toward evolution eligibility, and prepare for the boss.

### Session-Level

Play a 25-30 minute run, defeat the boss or enter endless, collect meta rewards, return to the hub, spend progression currency, and plan the next run.

### Long-Term Progression

Unlock and master characters, pets, chapters, restoration tiers, permanent upgrades, and build options.

### Retention Hooks

- **Curiosity**: New chapters, page events, evolutions, pets, and restoration states.
- **Investment**: Mastery tracks, unlocks, hub restoration, collection logs.
- **Social**: Later co-op and build sharing.
- **Mastery**: Stronger runs through better routing, dash timing, and synergy choices.

---

## Game Pillars

### Pillar 1: The Page Is Alive

The battlefield changes because of player and enemy actions.

*Design test*: If a feature could happen on any generic arena, add a page-state interaction or cut it.

### Pillar 2: Storybook Fantasy, Hand-Drawn Soul

The content should feel like a magical storybook drawing made real, with hand-drawn texture as the visual language.

*Design test*: Prefer crowns, moons, ribbons, toy-like keepsakes, storybook kingdoms, and living page materials over school-supply identity.

### Pillar 3: Power Fantasy First

The player should feel strong, especially when a build comes together.

*Design test*: If tuning makes the player feel weak for long stretches, reduce friction or raise player power.

### Pillar 4: Simple Controls, Deep Pagecraft

The player moves and dashes while build choices and page interactions create depth.

*Design test*: Avoid combat that requires precision aiming.

### Pillar 5: True 2.5D Diorama Lighting

Hand-drawn characters and effects live in a physically lit 3D paper world.

*Design test*: Use Godot 3D runtime, real lights, shadows, paper depth, and material feel rather than a pure 2D scene.

### Anti-Pillars

- **NOT a school-supply roguelite**: Art supplies can be texture language, not the primary world identity.
- **NOT precision-aim combat**: Combat must remain playable through movement, dash, and build decisions.
- **NOT cosmetic-only pets**: Pets must be mechanically meaningful.
- **NOT infinite empty arena design**: The map is finite, authored, and page-like.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Vampire Survivors | Auto-attacking, run escalation, simple inputs | Finite living page, page events, 2.5D paper world | Validates immediate readability and power curve |
| HoloCure | Build clarity and character identity | Storybook restoration and Pagecraft materials | Validates approachable depth |
| Brotato | Compact builds, fast decisions, strong item identity | Longer chapter run and page-routing goals | Validates readable stat/build choices |
| Hades | Strong run identity and returning hub energy | Survivors-like combat instead of action brawler combat | Validates character and progression framing |

**Non-game inspirations**: Pop-up books, hand-drawn storybooks, paper craft, shadow boxes, watercolor, wax, stickers, bedtime fantasy, and tabletop dioramas.

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | Teens and adults |
| **Gaming experience** | Casual-to-mid-core action roguelite players |
| **Time availability** | 30-minute runs, repeatable sessions |
| **Platform preference** | PC / Steam, with Steam Deck support later |
| **Current games they play** | Survivors-like roguelites, approachable action roguelites, buildcraft-heavy indies |
| **What they're looking for** | Strong power fantasy, readable chaos, cute-but-strong companions, build variety |
| **What would turn them away** | Weak-feeling early combat, unreadable late-game effects, imprecise controls, bland arena repetition |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Godot 4.6.x; project now pinned to Godot 4.6.2 |
| **Key Technical Challenges** | 2.5D rendering readability, Pagecraft state simulation, pooling, damage number performance, finite-map spawning, save migration, later co-op |
| **Rendering Direction** | Godot 3D runtime with Camera3D, DirectionalLight3D, WorldEnvironment, tactile paper materials, and card/sprite presentation |
| **Input Direction** | Keyboard/mouse and gamepad; no precision aiming required |
| **Prototype Priority** | Movement, dash, camera, lit paper arena, Pagecraft marks, enemies, damage numbers |

---

## MVP Definition

MVP must prove that the core game is fun and visually distinct:

- One complete chapter.
- One boss.
- Timed page events.
- Boss spawn at 25:00.
- Victory on boss defeat.
- Full shared weapon and passive pools as functional placeholder content.
- At least 3-5 playable characters.
- At least 5 meaningful pets.
- Pagecraft grid with MVP material set.
- Damage numbers and pooling.
- Basic hub and save/load.

---

## Open Questions

1. Should the root GDD remain canonical until every derived GDD is approved?
2. Which MVP system should receive the first full `/design-system retrofit` pass?
3. How much co-op architecture should be prepared before the solo vertical slice?
