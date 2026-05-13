# Pagebound — Complete Codex-Ready Game Design Document

**Version:** 1.5 — Production Completeness Merge / Pagecraft Specificity / Tag-Based Evolutions  
**Engine:** Godot 4.6.x stable target  
**Implementation Language:** Typed GDScript first  
**Rendering Target:** True 2.5D Godot 3D pipeline with hand-drawn sprite/cards, real 3D lights, cast shadows, tactile paper/material surfaces, and a perspective top-down camera  
**Primary Platform:** PC / Steam  
**Secondary Platform:** Steam Deck after desktop vertical slice  
**Mode Targets:** Solo first, local/LAN debug co-op second, Steam co-op third  
**Run Target:** Boss/finale starts at 30:00. A normal strong run should reach run level 50 by the boss start, with 5 Page Events before the finale. Endless continues after standard victory/finale.
**MVP Content Rule:** MVP includes the complete shared weapon roster and complete 23 passive items, even if some visuals/audio start as placeholders.
**Progression Rule:** Progression systems use 5-tier or 10-level structures. Weapon levels are 10. Passive item levels are 5. Pet tiers are 5. Character mastery tracks are 10. Permanent upgrades are 5 ranks. Chapter restoration tracks are 5 tiers. Enemy spawn budgets, enemy health curves, and difficulty curves are tuning variables and do not have to be multiples of 5. Upgrade drafts use exactly 3 choices as an intentional readability exception.  
**Working Title:** Pagebound
**Revision Note:** v1.5 keeps the v1.4 storybook-fantasy theme, 3-choice drafts, and tag-based evolutions, then restores the useful production detail that was compressed out of v1.1/v1.2. Obsolete school-supply theming, 5-choice drafts, and Pagecraft-gated evolutions remain removed.

---

## 0. Codex Usage Instructions

This document is meant to be directly actionable. Codex should treat it as the canonical product, design, engineering, content, and implementation specification unless a later task explicitly overrides it.

The most important locked decisions are:

- Use **Godot 4.6.x**.
- Use Godot's **3D runtime** for a true 2.5D game, not a pure CanvasItem 2D game.
- Gameplay occurs on the **X/Z plane**. Y is used for height, bounce, flying effects, shadows, and visual layering.
- Use a **Camera3D** angled downward with a perspective view.
- Use a **DirectionalLight3D** as the main sun/desk-lamp/world light.
- Use **WorldEnvironment** for ambient/fill lighting and overall mood.
- Characters, enemies, and many VFX are hand-drawn **Sprite3D cards, textured quads, or simple mesh cards** in a 3D world.
- The battlefield is a finite, large, physical storybook page represented by 3D geometry.
- The game is a **storybook fantasy power fantasy**, not a school-supply fantasy.
- Art supplies are allowed as visual texture, material language, and occasional flavor, but they should not dominate weapons, enemies, maps, or theme.
- Pagecraft is the core differentiator: player attacks leave marks, marks affect movement/combat, and dash activates or reshapes marks.
- Every weapon must define a **type**, **material tags**, **page alteration**, **dash interaction**, and **level 1-10 progression**.
- The game uses **3-choice upgrade drafts** for level-ups, Page Event rewards, elite chests, and boss rewards.
- Weapon evolutions are **tag-based**, not 1:1 fixed recipes. A level 10 weapon can evolve if the player owns a level 5 item with a compatible catalyst tag.
- Evolutions do **not** require extra Pagecraft conditions.
- Damage numbers are on by default and should become huge, satisfying, and abundant late-game.
- The screen should look like enemies are overwhelming the player, but the player should feel strong enough to carve through them.

### Codex Development Rules

Codex should follow these rules:

- Prefer typed GDScript.
- Avoid beta/dev-only Godot APIs.
- Keep controllers small. Put game logic in modular systems.
- Use Resources (`.tres`) for characters, weapons, passives, pets, enemies, bosses, maps, quests, upgrades, and audio metadata.
- Do not hard-code weapon logic into the player controller.
- Do not instantiate one physics body for every persistent page mark.
- Implement Pagecraft as a chunked simulation/grid plus batched visual overlays, decals, mesh ribbons, and shader-driven masks.
- Pool projectiles, pickups, VFX, damage numbers, enemies, pet attacks, and decals.
- Build debug panels early: spawn budget, enemy count, active marks, damage numbers, Pagecraft chunks, quest state, boss phase, and FPS.

---

## 1. Project Vision

### One-Sentence Pitch

**Pagebound is a 2.5D storybook action roguelite where tiny hand-drawn heroes and their pets fight living scribbles, blankness, and torn-page nightmares by flooding a magical page with color, spells, stickers, doodle creatures, and massive damage numbers.**

### Core Fantasy

You begin as a small doodle hero on a fragile storybook page.

By the end of a run, you are not barely surviving. You are overwhelming the page with color, pets, magic, light, and cascading damage numbers while hordes dissolve around you.

The intended fantasy is:

> “The story is being erased, but I am powerful enough to redraw it.”

### Main Emotional Arc

Early run:

- The player feels cute, scrappy, and vulnerable.
- Attacks are readable and small.
- Enemies are manageable but start to crowd the page.
- The page still has large clean areas.

Mid run:

- Builds start to come online.
- Pets begin contributing meaningful attacks.
- Pagecraft marks cover key lanes.
- Page Events force movement and create objectives.
- Enemy density looks dangerous, but player tools are strong.

Late run:

- The player becomes a walking storm of storybook magic.
- The page is covered in color, waxlight, dream trails, stickers, glowing marks, pet attacks, and combo effects.
- Damage numbers become large and frequent.
- The boss enters at 30:00 and should test a core-complete build rather than finish it.
- The screen should feel chaotic but not unreadable.

---

## 2. Theme Revision — Storybook Fantasy, Not School Supplies

### Final Theme Direction

Pagebound should evoke **childlike wonder**, **hand-drawn fantasy**, and **a magical storybook world coming alive**.

The game should not feel like it is primarily about:

- school supplies,
- recess,
- classroom objects,
- pencil cases,
- lunchboxes,
- rulers,
- scissors,
- markers as a major weapon category,
- erasers as a major identity,
- school desks as a central setting.

Those objects may appear rarely as background props or flavor if they support the physical page, but they should not define the world.

### Correct Identity

The page is the medium. The fantasy is the subject.

The game is about:

- storybook kingdoms,
- doodle heroes,
- pets and companions,
- crowns,
- stars,
- moons,
- dragons,
- clouds,
- forests,
- ponds,
- ribbons,
- toy-like keepsakes,
- pop-up paper castles,
- living scribbles,
- blankness,
- torn-page nightmares,
- color restoring a dying story.

### Thematic Rule

> Art supplies are allowed as texture and rendering language, but Pagebound is not a school-supply roguelite. Pagebound is a magical hand-drawn storybook power fantasy.


### Mechanical Rule

The theme is storybook fantasy, but the combat system is still material-based Pagecraft. Do not remove weapon types, materials, page marks, dash interactions, or page-altering attacks while reducing school-supply content.

### Reframed Conflict

Old direction:

> Corrupted art supplies are attacking a child’s page.

New direction:

> A magical storybook kingdom is being consumed by living scribbles, blankness, and torn-page nightmares. Tiny doodle heroes fight back by filling the page with color, pets, spells, and imagination.

### What Still Belongs

Keep:

- crayon-like texture,
- watercolor-like paint,
- stickers,
- paper folds,
- pop-up book structures,
- hand-drawn lines,
- doodle animations,
- rough childlike silhouettes,
- 2.5D physical paper under real light,
- tactile wax/gloss/wetness/paper materials.

Reduce or remove as core content:

- lunchbox weapons,
- ruler/scissor weapons,
- classroom floor map,
- school desk map as a primary chapter,
- eraser monk identity,
- marker ranger identity,
- pencil shavings as gameplay theme,
- school-coded passive items.

---

## 3. Design Pillars

### 1. The Page Is Alive

The battlefield is not a neutral floor. It is a finite magical storybook page that changes as the player fights. Color spreads. Paper folds. Tears open. Dream trails glow. Stickers stick. Blankness creeps. The page remembers what the player does.

### 2. Storybook Fantasy, Hand-Drawn Soul

The content should feel like a child's fantasy drawing made real: crowns, pets, dragons, moons, trees, stars, ribbons, clouds, toy soldiers, paper boats, and tiny kingdoms. The hand-drawn style is the visual language, not the literal theme.

### 3. Power Fantasy First

The player should feel strong. The horde can look overwhelming, but combat should be tuned so a coherent build cuts through enemies with satisfying attacks, pets, combos, and huge damage numbers.

### 4. Simple Controls, Deep Pagecraft

The player moves and dashes. Weapons auto-fire. Skill comes from positioning, dash timing, mark activation, build choices, Page Event routing, and using the finite map effectively.

### 5. True 2.5D Diorama Lighting

Characters and effects are hand-drawn, but the world is physically lit. Real DirectionalLight3D shadows, paper geometry, glossy stickers, wet paint, wax highlights, and page depth sell the tactile fantasy.

### 6. Pets Are Strong, Not Cosmetic

Pets are a major system. Every pet attacks. Every pet has five powerful tiers. Pets should meaningfully affect combat and build identity.

### 7. Characters Feel Distinct Through Mechanics

Characters share the weapon pool, but each character has a unique starter, dash behavior, passive, material affinity, mastery path, and exclusive evolutions.

### 8. Every Major Progression Track Uses 5 or 10 Levels

This creates consistency, easier balancing, and cleaner UI. Players should quickly understand that weapons go to 10, passives go to 5, pets have 5 tiers, characters have 10 mastery levels, and upgrade nodes have 5 ranks.

---

## 4. Core Gameplay Summary

### Genre

- Survivors-like action roguelite.
- Top-down planar combat.
- Auto-attacking weapons.
- Level-up choices.
- Finite map exploration.
- Timed Page Events.
- 30:00 boss/finale.
- Meta progression between runs.
- Solo first, co-op later.

### Control Scheme

Required MVP input:

- **WASD / Left Stick** — Move.
- **Space / Gamepad Face Button** — Dash.
- **Mouse / Right Stick** — Optional UI navigation only. Combat does not require aiming.
- **Esc / Start** — Pause.
- **E / Confirm Button** — Interact with Page Events, hub objects, and menus if needed.

Combat must remain playable without precise aiming.

### Combat Feel

Weapons fire automatically. The player controls:

- where enemies are pulled,
- where marks are placed,
- when to dash through marks,
- which Page Events to prioritize,
- how to route around the finite map,
- when to greed for XP/Treats/Pigment,
- when to fight the boss directly or keep scaling.

---

## 5. Run Structure

### Standard Run Timeline

Standard victorious runs target approximately 30 minutes, with the boss/finale starting at 30:00.

| Time | Event |
|---:|---|
| 0:00 | Run starts. Player spawns on chapter page. |
| 1:00 | First horde density increase. |
| 2:30 | First elite/miniburst chance. |
| 5:00 | Page Event 1 spawns with 3:00 countdown. |
| 7:30 | Enemy family variation increases. |
| 10:00 | Page Event 2 spawns with 3:00 countdown. |
| 12:30 | Mid-run elite wave. |
| 15:00 | Page Event 3 spawns with 3:00 countdown. |
| 17:30 | Stronger chapter-specific enemy wave. |
| 20:00 | Page Event 4 spawns with 3:00 countdown. |
| 22:30 | Pre-boss pressure wave. |
| 25:00 | Page Event 5 spawns with 3:00 countdown. |
| 27:30 | Final pre-boss pressure wave. |
| 30:00 | Boss/finale starts. Standard Page Events stop. |
| 35:00 | First post-boss Endless Page Event if endless is active. |
| Boss defeated | Victory. Rewards shown. Endless option unlocked if applicable. |

### Boss Ending Rule

The run does **not** have to end exactly at 30 minutes.

- The boss appears at **30:00**.
- A strong normal run should have its core build online before the boss appears.
- A powerful run may defeat the boss quickly after the 30:00 spawn.
- If endless is selected or unlocked, Page Events continue every 5 minutes after the boss starts, beginning at 35:00.

### Page Event Rule

Major Page Events occur at:

- 5:00,
- 10:00,
- 15:00,
- 20:00,
- 25:00.

Each Page Event:

- appears in a reachable part of the finite map,
- has a visible **3-minute countdown**,
- can be completed for rewards,
- fails or corrupts into a hazard if ignored,
- should not require exact pathfinding perfection,
- should create a strong reason to move across the map.

### Finite Map Rule

Maps are not infinite.

A chapter map should feel large enough to support:

- kiting,
- routing,
- Page Event travel,
- boss movement,
- environmental landmarks,
- co-op spacing,
- spawn zones.

But it must have boundaries:

- torn page edges,
- storybook margins,
- forest borders,
- magical ink barriers,
- folded paper cliffs,
- deep water edges,
- blankness walls.

Recommended MVP arena size:

- **120m x 90m** gameplay space for Chapter 1.
- Expand later chapters up to **160m x 120m** if performance/readability allows.
- Player camera shows roughly **28m–40m** across depending on zoom and co-op state.

Spawns should occur inside finite bounds, generally outside camera view but not outside the map.

---

## 6. Power Fantasy Direction

### Combat Tuning Goal

The player should frequently think:

> “There are way too many enemies... but my build is ridiculous.”

The visual density should imply danger. The actual feel should reward power.

### Player Strength Expectations

By 5:00:

- Player has 2–3 weapons or early upgrades.
- Pets may be contributing minor attacks.
- The player can carve lanes through small hordes.

By 10:00:

- Player has 3–5 weapons/items.
- One or two Pagecraft combos should be possible.
- Damage numbers should start to stack.

By 15:00:

- The build should feel clearly online.
- Screen-filling effects begin appearing.
- Enemies should be more numerous, but waves should melt when the player routes well.

By 20:00:

- Player should be approaching at least one evolution.
- Pets should feel powerful.
- Pagecraft should cover a meaningful portion of the battlefield.

By 25:00:

- The final pre-boss Page Event should be active or recently resolved.
- Strong builds should have 5 weapons owned, 2 level 10 weapons, 4 level 5 items, and 1-2 evolutions within reach.
- Damage numbers and VFX become a major satisfaction driver.

By 30:00:

- Boss appears.
- Strong builds should feel dangerous to the boss immediately.
- Damage numbers and VFX become a major satisfaction driver.

### Avoid

Avoid tuning that makes the player feel weak for too long. Avoid long stretches where enemies absorb damage without feedback. Avoid underpowered pets. Avoid effects that are so subtle the player cannot tell their build is scaling.

### Do

Use:

- high enemy counts,
- low-to-moderate enemy individual health early,
- readable elite threats,
- frequent small damage ticks,
- occasional huge burst numbers,
- strong pet attacks,
- dramatic evolution effects,
- visible Pagecraft buildup,
- late-game number scaling.

---

## 7. Camera and 2.5D Rendering Direction

### Final Rendering Decision

Pagebound uses a **true 2.5D storybook diorama** approach.

The game world is built in 3D space and lit by real lights. Characters, enemies, weapons, and many effects retain hand-drawn 2D/illustrative appearances by being rendered as sprites, texture cards, or billboarded quads.

### Camera

Default camera:

- **Camera3D**.
- Perspective projection.
- Top-down angled view.
- Approximate pitch: **55–65 degrees downward**.
- FOV: **35–50 degrees**.
- Camera follows player with smoothing.
- Camera zooms out subtly during boss fights, co-op spread, and major Page Events.

Use perspective by default because it makes:

- shadows read better,
- paper folds feel dimensional,
- props feel physical,
- Pagecraft material height feel more real.

### Lighting

Core lighting:

- **DirectionalLight3D** as main light.
- **WorldEnvironment** for ambient/fill.
- Optional localized lights for magical effects.
- Real shadows for players, bosses, elites, and major props.
- Blob/contact shadows for most units to guarantee readability.

Lighting should support the fantasy rather than obscure gameplay.

### Material Feel

The page and marks should respond to light:

- Paper: soft, fibrous, matte.
- Waxlight/crayon-like marks: slightly glossy, uneven, thick in overlaps.
- Paint/watercolor: wet-to-dry transition, translucent edges, pigment blooms.
- Stickers: glossy coating, raised edges, specular glints.
- Dream trails: subtle emissive glow plus ground lighting.
- Blankness/corruption: absorbs color, dark matte/inky look, soft crawling edges.

---

## 8. Core Mechanic — Pagecraft

### Definition

**Pagecraft** is the system where attacks, pets, dashes, enemy corruption, and events leave persistent or semi-persistent marks on the storybook page.

These marks are both visual and mechanical.

The player does not just fight on the page. The player rewrites the page.

### Pagecraft Goals

Pagecraft should:

- make attacks feel physical,
- make movement matter,
- create terrain-like zones without complex building controls,
- let dashes activate marks,
- make the page visibly transform over time,
- support power-fantasy escalation,
- create co-op synergy later.

### Primary Player Materials

Use fantasy/storybook material categories instead of school supplies.

#### 1. Color Bloom

Paint-like magical color that spreads and pulses.

Effects:

- deals area damage,
- spreads through water and moonlit zones,
- mixes with other materials,
- creates blooming damage pulses when dashed through.

Visual:

- wet watercolor initially,
- drying edges,
- translucent pigment pooling,
- soft chromatic texture.

#### 2. Waxlight

Crayon-like luminous wax marks, but treated as magical storybook light rather than school supply.

Effects:

- leaves damaging trails,
- stacks thickness,
- resists water,
- becomes rainbow arcs when activated,
- creates high-value lanes.

Visual:

- rough wax grain,
- slight height/normal detail,
- warm specular highlights.

#### 3. Star Sticker

Raised glossy stickers and sticker spirits.

Effects:

- attach to enemies,
- orbit players/pets,
- become mines,
- bounce between targets,
- shield allies,
- reflect certain beams.

Visual:

- glossy raised quads,
- peel shadow,
- holographic shimmer at high levels.

#### 4. Dreamsap

Sticky magical sap/thread/glue-like material reframed as storybook dream residue, not school glue.

Effects:

- slows enemies,
- traps enemies,
- stretches into snare lines when dashed through,
- lets pets drag or pounce on targets,
- merges with Color Bloom into slowing puddles.

Visual:

- translucent glossy trails,
- stretchy strands,
- amber/moonlit highlights.

#### 5. Paperfold

Physical paper magic: folds, thorns, pop-up walls, torn edges.

Effects:

- blocks or redirects enemies,
- creates short-lived defensive structures,
- launches paper thorns,
- interacts with tears and Page Events.

Visual:

- folded paper geometry,
- raised edges,
- cast shadows,
- torn fibers.

#### 6. Moonlight

Soft luminous magic from moons, stars, lanterns, and fireflies.

Effects:

- piercing beams,
- damage amplification zones,
- reveal hidden enemies,
- energize stickers and pets,
- cleanse blankness.

Visual:

- cool glow,
- soft light shafts,
- readable beams.

#### 7. Storythread

Ribbon, thread, or path-line magic.

Effects:

- connects enemies,
- chains damage,
- creates dash rails,
- ties enemies together,
- supports pet-command builds.

Visual:

- glowing thread lines,
- ribbon trails,
- knot bursts.

#### 8. Clean Page

Healing/cleansing page magic that restores story color and removes corruption. This replaces eraser-centric identity.

Effects:

- clears enemy blankness,
- creates safe zones,
- bursts after cleansing corruption,
- increases pickup visibility,
- can sacrifice some player marks for a powerful pulse.

Visual:

- paper brightness returning,
- soft dust motes,
- glowing edges,
- no literal eraser dependency.

### Enemy Corruption Materials

Enemies can place hostile marks:

#### Blankness

Color-draining corruption that reduces player mark effectiveness and slowly grows.

#### Ink Shadow

Dark damaging zones that pulse or spawn wisps.

#### Torn Edge

Temporary rips in the page that spawn enemies or block routing.

#### Crooked Lines

Chaotic scribble paths that guide fast enemies or damage players.

### Dash Interactions

Dash is central. Dash should always feel like the player is interacting with the page.

Examples:

- Dash through Waxlight trail: triggers a rainbow slash along the trail.
- Dash through Color Bloom: splashes color outward.
- Dash over Dreamsap: stretches it into a snare line.
- Dash into Star Sticker: launches it as a projectile.
- Dash through Storythread: speeds along the thread and chains damage.
- Dash through Clean Page zone: sends a cleansing pulse.
- Dash across Paperfold line: raises a temporary fold wall.

### Pagecraft Simulation Implementation

Use a chunked 2D grid projected onto the X/Z plane.

Recommended MVP:

- Map bounds: 120m x 90m.
- Grid cell size: 1m or 0.5m after testing.
- Chunk size: 10m x 10m.
- Store material weights per cell.
- Store corruption separately from player materials.
- Renderer batches visual marks per chunk.
- Interactions query material density along dash path and enemy path.

Suggested data per cell:

```gdscript
class_name PagecraftCell
extends Resource

var waxlight: float = 0.0
var color_bloom: float = 0.0
var star_sticker: float = 0.0
var dreamsap: float = 0.0
var paperfold: float = 0.0
var moonlight: float = 0.0
var storythread: float = 0.0
var clean_page: float = 0.0
var blankness: float = 0.0
var ink_shadow: float = 0.0
var torn_edge: float = 0.0
var crooked_line: float = 0.0
var last_updated_time: float = 0.0
```

Do not instantiate `PagecraftCell` as a Resource per cell in production if that becomes expensive. The class above is conceptual. Production should use arrays or PackedFloat32Array structures.

---


## 9. Player Progression During a Run

This section is the canonical answer for what the player is leveling during a run.

The player has a temporary **Run Level** that resets every run. Enemies, elites, Page Events, destructibles, and boss phases drop XP called **Color Motes**. Collecting Color Motes fills the Run Level bar. When the bar fills, the game pauses or enters slow motion and presents a **3-choice upgrade draft**. The player chooses one card, then combat resumes.

The player is not directly leveling their character mastery during combat. Character mastery XP is earned after the run. During combat, the player is building a temporary loadout of weapons and passive items.

### Start-of-Run Loadout

At the start of a standard run, the player has:

- 1 character signature weapon at **weapon level 1**.
- 0 passive items by default.
- 1 equipped pet by default.
- Permanent meta progression may later unlock a pre-run starter item option, but MVP should begin with only the signature weapon and pet.

During the run, the player can carry:

| Loadout Type | Limit | Level Cap |
|---|---:|---:|
| Weapons | 5 | 10 |
| Passive Items | 5 | 5 |
| Equipped Pets | 1 by default | 5 tiers |
| Pet Warden Equipped Pets | 5 endgame maximum | 5 tiers each |

### XP and Run Levels

Standard runs use run levels **1-50**, and a normal strong run should reach level 50 by the 30:00 boss/finale start. Endless can continue past 50 while normal upgrades remain available, then switch to overflow drafts once weapon, item, and evolution choices are exhausted.

XP thresholds should remain multiples of 5.

```gdscript
func xp_required_for_next_level(current_level: int) -> int:
    var raw := 10 + (current_level * 5) + (floori(current_level / 5.0) * 10)
    return int(ceil(raw / 5.0) * 5)
```

Example thresholds:

| Current Level | XP to Next |
|---:|---:|
| 1 | 15 |
| 5 | 45 |
| 10 | 80 |
| 15 | 115 |
| 20 | 150 |
| 25 | 185 |
| 30 | 220 |
| 35 | 255 |
| 40 | 290 |
| 45 | 325 |
| 50 | Endless scaling |

Target pacing is:

| Time | Expected Run State |
|---:|---|
| 0:00 | Character weapon level 1, pet equipped. |
| 2:00 | Player has several level-ups and should usually see at least one new weapon. |
| 5:00 | First Page Event spawns. Player should have 2-3 weapons and 1-2 items. |
| 10:00 | Second Page Event. Player should be filling weapon/item slots. |
| 15:00 | Third Page Event. Build identity should be clear. |
| 20:00 | Fourth Page Event. First maxed items/weapons may appear for strong runs. |
| 25:00 | Fifth Page Event. Build should be near core-complete. |
| 30:00 | Boss/finale starts. Strong builds should have 5 weapons owned, 2 level 10 weapons, 4 level 5 items, and 1-2 evolutions. |

### Upgrade Drafts

Every upgrade draft shows exactly **3 choices**.

This is an intentional readability exception to the broader 5/10 structure. Five upgrade choices created too much friction for a fast action roguelite. Three choices is faster, clearer, and closer to the pace of the genre.

Upgrade drafts are used for:

- Run level-ups.
- Page Event rewards.
- Elite story chests.
- Boss/finale rewards.
- Rare treasure pickups.

### What Can Appear in a 3-Choice Draft

A draft card can be:

- A **new weapon** if the player has fewer than 5 weapons.
- A **new passive item** if the player has fewer than 5 items.
- A **+1 level upgrade** to an owned weapon below level 10.
- A **+1 level upgrade** to an owned item below level 5.
- An **evolution card** if requirements are met.
- A rare **heal**, **pickup magnet**, or **temporary super attack** when the player is under pressure or the upgrade pool is constrained.
- A rare **Pagecraft modifier** from Page Events or treasure rewards, not usually from normal level-ups.
- An **overflow reward** after level 50 only when no normal weapon, item, or evolution upgrades remain.

### Draft Composition Rules

Run levels 5, 10, 20, and 35 are **weapon-only acquisition drafts** when legal new weapons exist. These drafts show only new weapon cards, so the player must choose a new weapon but still chooses which one.

All other normal level-up drafts should use:

- 1 weapon-side card when legal,
- 1 item-side card when legal,
- 1 flex card drawn from weapon, item, evolution, utility, or fallback pools.

Page Event reward drafts use build-completion bias: item upgrades, catalyst fixes, eligible evolutions, and high-rarity upgrades are preferred over generic filler.

### New Weapon Rules

New weapons are primarily acquired from fixed weapon-only level-up drafts.

When the player chooses a new weapon:

- The weapon is added at level 1.
- It occupies one of the 5 weapon slots.
- It immediately begins auto-firing according to its behavior.
- It adds its material tags to the player's build profile.
- It can later be upgraded through level-up cards, Page Event cards, elite chests, or boss rewards.

Weapon-only drafts occur at run levels 5, 10, 20, and 35 while legal new weapons exist. Normal strong runs should own all 5 weapon slots before the 30:00 boss, but only about 2 weapons are expected to reach level 10 by then.

### Weapon Upgrade Rules

When the player chooses a weapon upgrade:

- The chosen weapon gains exactly +1 level.
- Weapons cannot exceed level 10.
- Every level must be a specific behavior/stat upgrade listed in the weapon table.
- Level 5 is always a meaningful mechanical breakpoint.
- Level 10 is always a capstone and evolution eligibility breakpoint.

### New Passive Item Rules

New passive items are acquired from the same reward drafts as weapons.

When the player chooses a new item:

- The item is added at level 1.
- It occupies one of the 5 passive item slots.
- It immediately applies its level 1 modifier.
- It adds its catalyst tags to the player's build profile.
- At level 5, its catalyst tags can enable eligible weapon evolutions.

Items are not just evolution keys. They must be generally useful even when the player does not have a matching weapon.

Item find rarity affects only new-item card appearance. Once an item is owned, item upgrade cards grant exactly +1 item level regardless of the item's initial find rarity.

### Passive Item Upgrade Rules

When the player chooses an item upgrade:

- The chosen item gains exactly +1 level.
- Items cannot exceed level 5.
- Level 5 is the capstone and unlocks the item's full catalyst value.
- Level 5 items are never consumed by evolutions.

### Evolution Draft Rules

When a weapon reaches level 10 and the player owns at least one level 5 item with a compatible catalyst tag, the weapon becomes **evolution eligible**.

Eligible evolutions can appear in any 3-choice upgrade draft.

Rules:

- Evolutions do not require Pagecraft conditions.
- Evolutions are not fixed 1:1 weapon-item recipes.
- Evolutions are determined by **weapon + catalyst tag**.
- A level 5 item can enable evolutions for multiple weapons if its tags match those weapons.
- The item is not consumed.
- An evolved weapon replaces the base weapon and remains level 10.
- A base weapon can only evolve once per run.
- If multiple evolution paths are eligible for the same weapon, the draft may show one or more paths over time, but selecting one locks that weapon's evolution for the run.

Example:

- The player has **Waxlight Comet level 10**.
- The player has **Candle Spark level 5**, which has the catalyst tags `Firelight` and `Waxlight`.
- Waxlight Comet has compatible evolution paths for `Firelight` and `Royal`.
- The next draft can offer **Evolve Waxlight Comet: Solar Wax Dragon** using the `Firelight` path.

### Page Event Reward Drafts

Page Events spawn at 5:00, 10:00, 15:00, 20:00, and 25:00. Each has a 3-minute countdown. In endless, Page Events continue every 5 minutes after the boss starts, beginning at 35:00.

Completing a Page Event grants a 3-choice reward draft. Page Event drafts should be stronger than normal level-up drafts and use build-completion bias. They may include:

- +1 weapon level.
- +1 item level.
- Catalyst-compatible item help.
- A new weapon.
- A new item.
- An eligible evolution.
- A pet quest reward.
- Pigment or Treats.
- A temporary Page Takeover attack.
- A map repair or safe-zone effect.

### Elite and Boss Rewards

Elite enemies can drop story chests. Story chests use the same 3-choice draft format but have higher odds for:

- weapon upgrades,
- item upgrades,
- healing,
- rare temporary attacks,
- evolution offers if eligible.

The boss spawns at 30:00. A strong normal run should reach level 50 by the boss start. If the player continues into endless after standard victory/finale, normal upgrades continue while available; once no weapon, item, or evolution upgrades remain, drafts switch to overflow rewards.

### Example Run Build Flow

A typical successful run might look like this:

| Time | Example Progression |
|---:|---|
| 0:00 | Waxlight Knight starts with Waxlight Comet Lv. 1 and Dog pet. |
| 5:00 | First Page Event spawns and run level 5 weapon-only draft has added a second weapon. |
| 10:00 | Second Page Event spawns and run level 10 weapon-only draft has added a third weapon. |
| 15:00 | Waxlight Comet approaches high level. Candle Spark or another item approaches level 5. |
| 20:00 | Fourth Page Event spawns and run level 20 weapon-only draft has added a fourth weapon. |
| 25:00 | Fifth Page Event spawns. First evolution should be possible or close. |
| 30:00 | Boss appears. Player has 5 weapons owned, 2 level 10 weapons, about 4 level 5 items, 1-2 evolutions, huge damage numbers, and dense Pagecraft coverage. |
| 32:00+ | Strong build kills the boss, or the run continues into endless rules if selected. |

## 10. Damage Numbers

### Design Requirement

Pagebound shows damage numbers by default.

The numbers should be:

- frequent,
- juicy,
- large,
- readable,
- increasingly satisfying late-game,
- tied to material and damage type,
- performance-managed.

### Damage Number Fantasy

By late game, the player should see cascades of numbers popping across the battlefield. Huge crits, combo bursts, boss chunks, pet strikes, and Pagecraft detonations should produce exaggerated feedback.

### Number Categories

| Type | Behavior |
|---|---|
| Normal Damage | Small-to-medium numbers. Fast pop/fade. |
| Tick Damage | Compact numbers that can aggregate. |
| Critical Damage | Bigger, sharper pop, stronger motion. |
| Combo Damage | Slightly larger, may include small label such as `BLOOM!` or `CHAIN!`. |
| Pet Damage | Paw/star accent or small pet icon. |
| Boss Damage | Larger and more persistent. |
| Overkill / Execute | Huge number or special burst. |
| Healing | Green/soft upward number. |
| Shield / Block | Icon or text, not too spammy. |

### Late-Game Scaling

Damage number size scales in bands:

| Damage Range | Display Style |
|---:|---|
| 1–99 | normal |
| 100–999 | medium pop |
| 1,000–9,999 | large pop |
| 10,000–99,999 | huge pop |
| 100,000+ | massive burst number with optional abbreviated format |

Use abbreviations after numbers become very large:

- 12.5K,
- 250K,
- 1.5M.

### Performance Rules

Damage numbers must be pooled.

Recommended limits:

- Max active standard numbers: **250**.
- Max active boss/critical numbers: **50**.
- Tick damage should aggregate per enemy per 0.25s when number spam becomes too high.
- Offscreen damage numbers should be suppressed or summarized.
- Accessibility option: Reduced Numbers.
- Accessibility option: Boss/crit only.
- Accessibility option: No damage numbers.

### Implementation

Use `DamageNumberManager` with object pooling.

```gdscript
class_name DamageNumberManager
extends Node3D

@export var max_standard_numbers: int = 250
@export var max_priority_numbers: int = 50

func spawn_damage_number(world_pos: Vector3, amount: int, damage_type: StringName, priority: int = 0) -> void:
    pass

func spawn_aggregated_tick(world_pos: Vector3, amount: int, damage_type: StringName) -> void:
    pass
```

Numbers should be rendered as camera-facing 3D text/quads or viewport-based UI projected from world positions. Use whichever is more performant and readable in Godot 4.6.x.

---


## 11. Weapons — MVP Shared Weapon Rules

MVP weapon roster rows and candidate counts live in `design/gdd/mvp-weapon-candidate-pool.md`. This root section defines only stable weapon design rules.

The theme has shifted away from school-supply fantasy, but the mechanical identity has not been removed. Every weapon still has a **type**, **material tags**, and **Pagecraft behavior**. Every attack should alter the page in some way.

### Weapon Design Rules

Each weapon must define:

- **Weapon type**: projectile, orbit, puddle, beam, terrain, summon, wave, chain, nova, trap, or hybrid.
- **Pagecraft material tags**: the material identity used by weapons, items, pets, enemies, map features, and evolutions.
- **Page alteration**: what mark/object/zone the weapon leaves on the page.
- **Dash interaction**: what happens when the player dashes through, across, or near the weapon's marks.
- **Maximum range**: how far the weapon can target or place its effect at the current level.
- **10 progression levels**: milestone levels and upgrade-card pools must be defined in the focused weapon sheet.
- **2 evolution catalyst tags**: the tags that can transform the weapon at level 10.

Weapons should be powerful and visually expressive. A weapon that only deals invisible damage is not acceptable for Pagebound.

### Page-Altering Weapon Rule

Every weapon must do at least one of these:

1. Create a persistent mark on the page.
2. Modify an existing mark.
3. Trigger a mark when the player dashes through it.
4. Consume a mark for a stronger effect.
5. Transform a portion of the finite map.
6. Create a temporary object that physically exists on the page.

### Weapon Level Rules

Each weapon has **10 levels**.

- Level 1: base behavior.
- Levels 2-4: one-stat upgrade cards from the weapon's upgrade pool.
- Level 5: major behavior breakpoint plus one upgrade card.
- Levels 6-9: one-stat upgrade cards from the weapon's upgrade pool.
- Level 10: capstone and evolution eligibility plus one upgrade card.
- Range can also be upgraded by separate one-stat draft cards. A range card must not bundle damage, projectile count, cooldown, or level increases.

### MVP Weapon Pool

The exact MVP weapon candidate roster, L1/L5/L10 milestones, upgrade-card pools, catalyst assignments, and per-weapon tuning live in `design/gdd/mvp-weapon-candidate-pool.md`. That focused sheet is the source for weapon rows and level details.

Root-GDD weapon invariants:

- The MVP target remains a readable shared weapon pool; the focused sheet may track extra candidates before final roster lock.
- Each weapon has 10 levels.
- L1 is base behavior, L5 is a major behavior breakpoint, and L10 is capstone plus evolution eligibility.
- Non-milestone levels use one-stat upgrade cards from that weapon's upgrade pool.
- Every weapon must visibly affect the page through marks, temporary objects, terrain effects, dash interactions, or Pagecraft state.
- Range upgrades are separate one-stat draft cards and must not bundle damage, projectile count, cadence, or level increases.

Do not duplicate weapon candidate rows or level tables in this root document. Update `design/gdd/mvp-weapon-candidate-pool.md` first, then adjust this section only when a stable rule changes.


## 12. Passive Items — MVP Item Rules

All passive items have **5 levels**.

Every item should be a magical keepsake, toy, natural object, storybook relic, or cozy childhood wonder object. Avoid school-supply identity.

Items are not 1:1 keys for specific weapons. Items have **catalyst tags**. At item level 5, those tags can enable any level 10 weapon with a matching compatible evolution path.

Items are build-shaping stat, behavior, pickup, survivability, draft, pet, or Pagecraft modifiers. They must not be hidden single-weapon upgrades. Normal passive item stat bonuses apply globally to player-owned sources unless the item explicitly names an eligible authored channel. Catalyst tags drive evolution eligibility and draft synergy; they do not limit normal passive item stat bonuses.

### Passive Item Pool

The exact 23-item passive roster, L1-L5 values, capstone bonuses, catalyst tags, and stat-channel definitions live in `design/gdd/mvp-item-candidate-pool.md`. That focused sheet is the source for item rows and numeric item tuning.

Root-GDD item invariants:

- The MVP passive pool has 23 active items.
- Each item has an initial find rarity; once owned, upgrade cards grant exactly +1 item level.
- Normal passive items have 2 catalyst tags.
- `Foundational Keepsake` is Legendary and has all 10 MVP catalyst families at level 5.
- Normal passive stat bonuses apply globally to player-owned sources unless an item explicitly names an eligible authored channel.
- Catalyst tags drive evolution eligibility and draft synergy; they do not limit normal passive stat bonuses.

Do not duplicate the item row table in this root document. Update `design/gdd/mvp-item-candidate-pool.md` first, then adjust this section only when a stable rule changes.

### Item Rarity Rules

| Find Rarity | Item Count | Initial Find Weight |
|---|---:|---:|
| Common | 8 | 60 |
| Uncommon | 6 | 25 |
| Rare | 5 | 9 |
| Epic | 3 | 5 |
| Legendary | 1 | 1 |

- Find rarity affects initial item finds only.
- Owned item upgrade cards grant fixed +1 item level.
- Normal passive items have 2 catalyst tags.
- `Foundational Keepsake` is Legendary and has all 10 MVP catalyst families at level 5.

### Item Catalyst Rules

- Items have catalyst tags from level 1, but only a **level 5 item** can enable evolutions.
- Catalyst tags are not consumed.
- A single item can enable multiple weapons if the tags match.
- If multiple level 5 items match a weapon, the player can choose between eligible evolution paths when offered.
- The evolved form belongs to the weapon, not the item.

### Item Level Pattern

Each item should use this 5-level pattern:

- Level 1: base effect.
- Level 2: stronger item effect.
- Level 3: stronger item effect or small secondary behavior.
- Level 4: stronger item effect.
- Level 5: normal stat maximum, modest capstone modifier, and full catalyst value.

Use multiples of 5 for values whenever possible.

Chance wording means additive `+X% chance`, not relative percent scaling. Exact item ladders, item-specific exceptions, HP-scale item values, and low-health ward values live in `design/gdd/mvp-item-candidate-pool.md`.

Crit chance is global and capped at 75%. Base crit multiplier is 2.0x. Crit damage adds to that multiplier, so +50% crit damage changes 2.0x to 2.5x. Final crit multiplier is capped at 4.0x.

Luck uses raffle math for draft rarity only: Common/basic weights stay unchanged, Uncommon-and-higher weights multiply by `1 + luck`, then the table is normalized.

### Broad Item Guardrails

`effect_count`, `active_cap`, `dash_count`, and `base_stat_boost` are intentionally bounded. Exact ladders live in `design/gdd/mvp-item-candidate-pool.md`.

- `effect_count` applies only to authored eligible count channels.
- `active_cap` applies only to authored eligible active-object channels.
- `dash_count` adds charges and does not change recharge time.
- `base_stat_boost` affects only damage, size, duration, range, cadence, and control_strength.
- `base_stat_boost` does not affect crit, XP, dash count, revive, effect_count, or active_cap.

---


## 13. Weapon Evolutions

Pagebound uses **tag-based branching evolutions**.

This replaces strict 1:1 weapon-item recipes. Vampire Survivors-style 1:1 recipes are readable, but they are too restrictive for Pagebound because this game is about material identity, Pagecraft interaction, and flexible build expression.

### Evolution Rule

A weapon can evolve when:

1. The weapon is **level 10**.
2. The player owns at least one passive item at **level 5**.
3. That level 5 item has a catalyst tag compatible with one of the weapon's evolution paths.
4. An evolution card appears in a 3-choice upgrade draft.

No other condition is required.

Removed requirements:

- No Pagecraft condition.
- No dash-count requirement.
- No enemy-count requirement.
- No exact 1:1 item recipe.
- No consuming the item.

### Why This System Fits Pagebound

Strict 1:1 recipes create failed builds when the player misses one exact passive. Tag-based evolutions keep the readability of "max weapon + max item" while giving the player more build flexibility.

Example:

- **Waxlight Comet** supports the `Firelight` and `Royal` evolution tags.
- **Candle Spark** has the `Firelight` and `Waxlight` catalyst tags.
- **Tiny Crown** has the `Royal` and `Command` catalyst tags.
- If Waxlight Comet is level 10 and either Candle Spark or Tiny Crown is level 5, Waxlight Comet can evolve.
- The chosen catalyst tag determines which evolved weapon appears.

### Evolution Draft Behavior

When multiple evolutions are eligible:

- The draft generator may show one evolution card and two normal upgrade cards.
- Rare chests may show up to two evolution cards.
- Normal level-up drafts should avoid showing three evolution cards at once unless the player has almost no remaining upgrade pool.
- Once a weapon evolves, it cannot choose its other evolution path in the same run.

### Evolved Weapon Rules

- The evolved weapon replaces the base weapon.
- It remains level 10.
- It should feel like a major power spike.
- It should keep the original weapon's identity but dramatically expand its area, visuals, damage cadence, or Pagecraft interaction.
- Most evolutions should create at least one **Page Takeover attack**.

### Page Takeover Attacks

Page Takeover attacks are late-game/evolved attacks that affect a huge portion of the visible page or a major region of the finite map.

They are the game's main power fantasy payoff.

Examples:

- Royal rainbow arcs sweeping across the screen.
- Sticker storms raining from above.
- Moonlit floods washing through the battlefield.
- Dragon doodles circling the arena.
- Threads wrapping entire enemy packs.
- Paper bastions erupting from the page.
- Firefly constellations drawing beam networks.
- Toy armies marching from the edge of the page.

Page Takeover attacks must be powerful but readable. They should have strong silhouettes, clear timing, and damage-number priority rules.

### MVP Evolution Table

Each MVP weapon has two evolution paths. That gives 20 base weapons and 40 possible evolved weapons without forcing 1:1 item recipes.

| Base Weapon | Required Catalyst Tag | Evolved Weapon | Effect Summary |
|---|---|---|---|
| Waxlight Comet | Firelight | Solar Wax Dragon | Comets become dragon-shaped solar strokes that burn long Waxlight lanes. |
| Waxlight Comet | Royal | Royal Rainbow Comet | Every 5th comet calls a royal rainbow sweep across the visible page. |
| Star Sticker Swarm | Star | Holographic Starfall | Hundreds of glossy stars fall, stick, and ricochet from enemies. |
| Star Sticker Swarm | Moon | Moon Sticker Eclipse | The page dims, then moon-stickers detonate in bright crescent waves. |
| Dreamsap Glob | Binding | Endless Snare Lagoon | Puddles connect into giant sticky lagoons that bind whole packs. |
| Dreamsap Glob | Water | Dreamsap River | Sap flows through wet channels and drags enemies downstream. |
| Color Bloom | Bloom | Garden of Everything | Bloom zones grow into massive chained flower explosions. |
| Color Bloom | Cloud | Cloudburst Bloom | Bloom clouds drift, burst, and rain color across enemy clusters. |
| Moonbeam Scribble | Moon | Full Moon Script | Moon-lines rotate around the player and carve huge arcs. |
| Moonbeam Scribble | Focus | Crescent Lens | Beams focus through priority targets and drill bosses with huge numbers. |
| Paper Thorn | Guard | Thornfold Bastion | Paper walls and thorns erupt into defensive fortress lanes. |
| Paper Thorn | Bloom | Briar Page Garden | Thorns grow into living brambles that spread across the page. |
| Clean Page Pulse | Clean | Pure Dawn Nova | Clean zones chain-detonate and erase corruption in huge circles. |
| Clean Page Pulse | Heart | Living Page Heart | Pulses heal allies, damage enemies, and create massive heart-shaped clean zones. |
| Watercolor Wave | Water | Moonlit Monsoon | Huge watercolor tides wash across the battlefield repeatedly. |
| Watercolor Wave | Moon | Tide of Stars | Waves carry moon-stars that explode at the end of their path. |
| Rainbow Thread | Thread | Storyweaver Spiral | Threads web entire enemy packs and pull them into a spiral detonation. |
| Rainbow Thread | Dream | Dreamweb Finale | Dream threads suspend enemies, then burst into overlapping dream sigils. |
| Crown Spark | Royal | Crown of Dawn | Crown marks call down royal beams and explode into smaller marks. |
| Crown Spark | Light | Firefly Court | Light sparks form a court of fireflies that executes weakened enemies. |
| Button Beetle | Pet | Familiar Stampede | Beetles become pet-like familiars that respond to pet commands and dash inputs. |
| Button Beetle | Swarm | Beetle Parade | Dense beetle formations march from page edges and shred hordes. |
| Ribbon Whip | Thread | Ribbon Cyclone | Ribbons spin around the player, pull enemies inward, and leave loops. |
| Ribbon Whip | Dash | Comet Ribbon Dash | Dashing creates huge ribbon slashes and afterimage whip strikes. |
| Lantern Wisp | Light | Firefly Constellation | Lanterns connect into constellation beams across the page. |
| Lantern Wisp | Firelight | Candlelit Lanterns | Wisps ignite into warm lantern flames that leave burning light pools. |
| Acorn Barrage | Bloom | Great Oak Burst | Acorns grow into giant tree bursts and thorn roots. |
| Acorn Barrage | Projectile | Seedshot Tempest | Acorns multiply into bouncing seed storms with massive projectile count. |
| Seashell Song | Echo | Ocean Hymn | Resonance rings echo repeatedly and stack huge slow/damage pulses. |
| Seashell Song | Water | Resonant Tide | Rings become water tides that carry enemies and spread wet channels. |
| Toy Soldier March | Command | Bannerstorm Legion | Soldier lanes respond to rally commands and create banner shockwaves. |
| Toy Soldier March | Royal | Royal Toy Army | Multiple royal formations march from every side of the page. |
| Dragon Doodle | Dragon | Paper Dragon King | The dragon grows huge and circles the arena with sweeping breath attacks. |
| Dragon Doodle | Firelight | Solar Wyrmling | Firelight breath becomes solar flame strokes that ignite marks and trails. |
| Fairy Ring | Dream | Sleepy Star Court | Rings lull enemies, then explode into dream-star bursts. |
| Fairy Ring | Moon | Moon Fairy Court | Rings overlap into a glowing moon court that melts enemy packs. |
| Marble Meteor | Giant | Giant's Marble | Massive marbles ricochet around the page and crush swarms. |
| Marble Meteor | Focus | Telescope Meteor | Meteors target elites/boss weakpoints and produce enormous damage numbers. |
| Paper Boat Fleet | Water | Armada of Dreams | Many boats sweep wet lanes and carry stickers, blooms, and wake damage. |
| Paper Boat Fleet | Story | Storybook Current | Boats follow story paths, collect pickups, and summon page-wide currents. |

### Implementation Pseudocode

```gdscript
func get_eligible_evolutions(loadout: RunLoadout) -> Array[EvolutionOffer]:
    var offers: Array[EvolutionOffer] = []

    var catalyst_tags: Dictionary = {}
    for item_state in loadout.items:
        if item_state.level >= 5:
            for tag in item_state.data.catalyst_tags:
                catalyst_tags[tag] = true

    for weapon_state in loadout.weapons:
        if weapon_state.level < 10:
            continue
        if weapon_state.is_evolved:
            continue

        for path in weapon_state.data.evolution_paths:
            if catalyst_tags.has(path.required_tag):
                offers.append(EvolutionOffer.new(weapon_state, path))

    return offers
```

### Evolution UX

Evolution cards should show:

- base weapon name,
- evolved weapon name,
- required catalyst tag,
- which owned item is enabling it,
- short power fantasy description,
- preview icon/animation,
- Page Takeover warning if relevant.

Example card:

> **Evolve Waxlight Comet -> Solar Wax Dragon**  
> Enabled by Candle Spark Lv. 5 (`Firelight`)  
> Comets become dragon-shaped solar strokes that burn long Waxlight lanes across the page.

## 14. Characters

### Character Structure

Each character has:

- unique identity,
- starter weapon,
- dash effect,
- passive trait,
- preferred material,
- stat profile,
- unlock condition,
- 10-level mastery track,
- gameplay reward at every mastery level,
- cosmetic bonus only as an addition to level 10, never as the only reward.

### Character Mastery XP

Character mastery has **10 levels**.

Recommended thresholds:

| Mastery Level | Total Character XP Required |
|---:|---:|
| 1 | 0 |
| 2 | 50 |
| 3 | 125 |
| 4 | 250 |
| 5 | 500 |
| 6 | 800 |
| 7 | 1,200 |
| 8 | 1,700 |
| 9 | 2,300 |
| 10 | 3,000 |

All values are multiples of 5.

Character XP sources:

- time survived,
- Page Events completed,
- boss defeated,
- Hard clear,
- Endless milestones,
- character-specific achievements.

---

### 14.1 Waxlight Knight

**Theme:** Brave tiny storybook knight with a glowing wax crown and rainbow blade.  
**Starter Weapon:** Waxlight Comet.  
**Preferred Material:** Waxlight.  
**Dash:** Leaves a short Waxlight trail.  
**Passive:** Waxlight marks last longer and stack thicker.  
**Role:** Beginner-friendly lane control and rainbow burst power fantasy.

#### Mastery Track

| Level | Reward |
|---:|---|
| 1 | Unlock Waxlight Knight with Waxlight Comet and Wax Trail Dash. |
| 2 | Waxlight marks last +5% longer. |
| 3 | Unlock alternate starter choice: Ribbon Whip. |
| 4 | Dash through Waxlight now triggers a small rainbow slash once every 5s. |
| 5 | Unlock exclusive evolution: **Royal Waxblade**. Waxlight Comet can evolve into a sweeping blade if normal evolution requirements are met. |
| 6 | Pre-run trait choice: thicker Waxlight trails, longer trails, or water-resistant trails. |
| 7 | Waxlight damage +10% against enemies standing on player-created marks. |
| 8 | Dash trail length +10% and dash trail applies light slow for 1s. |
| 9 | Unlock second exclusive evolution: **Crownfire Dragonline**, combining Waxlight Comet + Dragon Doodle synergies. |
| 10 | Max mastery: start each run with one free Waxlight upgrade choice after reaching level 5 in-run; bonus cosmetic: radiant crown skin. |

---

### 14.2 Sticker Mage

**Theme:** A playful wizard made of glossy sticker stars, moons, and peeling shapes.  
**Starter Weapon:** Star Sticker Swarm.  
**Preferred Material:** Star Sticker.  
**Dash:** Drops a sticker decoy that distracts enemies briefly.  
**Passive:** Stickers attach longer and can trigger delayed pops.  
**Role:** Orbitals, traps, decoys, and attachment detonations.

#### Mastery Track

| Level | Reward |
|---:|---|
| 1 | Unlock Sticker Mage with Star Sticker Swarm and Sticker Decoy Dash. |
| 2 | Sticker attachment duration +5%. |
| 3 | Unlock alternate starter choice: Fairy Ring. |
| 4 | Sticker Decoy drops 3 small sticker mines when it expires. |
| 5 | Unlock exclusive evolution: **Holographic Familiar Storm**. Star Sticker Swarm can become familiar-like orbitals. |
| 6 | Pre-run trait choice: extra orbit speed, stronger attachment pops, or sticker shield chance. |
| 7 | Attached stickers make enemies take +10% pet and projectile damage. |
| 8 | Dash decoy cooldown -10% after completing a Page Event. |
| 9 | Unlock second exclusive evolution: **Peeling Moon Court**, combining Star Sticker Swarm + Moonbeam/Fairy Ring. |
| 10 | Max mastery: first sticker-based weapon offered in-run appears at +1 level; bonus cosmetic: holographic robe skin. |

---

### 14.3 Dreamsap Goblin

**Theme:** Mischievous tiny goblin carrying a bottle of glowing dream sap, not school glue.  
**Starter Weapon:** Dreamsap Glob.  
**Preferred Material:** Dreamsap.  
**Dash:** Slides through Dreamsap and leaves a sticky trail.  
**Passive:** Dreamsap puddles merge into larger snare zones.  
**Role:** Trap-building, slow zones, sticky crowd control, strong safety.

#### Mastery Track

| Level | Reward |
|---:|---|
| 1 | Unlock Dreamsap Goblin with Dreamsap Glob and Sap Slide Dash. |
| 2 | Dreamsap slow strength +5%. |
| 3 | Unlock alternate starter choice: Button Beetle. |
| 4 | Dashing through Dreamsap creates a snare strand between dash start and end every 5s. |
| 5 | Unlock exclusive evolution: **Dreamsap Maw**. Dreamsap Glob can create pulsing sticky mouths. |
| 6 | Pre-run trait choice: wider puddles, stronger snare, or longer Dreamsap duration. |
| 7 | Enemies trapped in Dreamsap take +10% damage from pets and creatures. |
| 8 | Sap Slide Dash recharge -10% while standing on Dreamsap. |
| 9 | Unlock second exclusive evolution: **Golden Lagoon**, combining Dreamsap + Seashell Song/Watercolor. |
| 10 | Max mastery: start runs with Dreamsap zones immune to the first 5 seconds of enemy Blankness decay; bonus cosmetic: amber goblin skin. |

---

### 14.4 Mender Monk

**Theme:** A calm paper-spirit monk who restores torn and blank parts of the story.  
**Starter Weapon:** Clean Page Pulse.  
**Preferred Material:** Clean Page.  
**Dash:** Cleans a path through enemy corruption.  
**Passive:** Cleansed areas pulse after removing enough corruption.  
**Role:** Risk/reward cleanser, sustain, corruption control, defensive power.

#### Mastery Track

| Level | Reward |
|---:|---|
| 1 | Unlock Mender Monk with Clean Page Pulse and Clean Path Dash. |
| 2 | Clean Page zones last +5% longer. |
| 3 | Unlock alternate starter choice: Paper Thorn. |
| 4 | Clean Path Dash removes light Blankness and deals damage based on corruption cleared. |
| 5 | Unlock exclusive evolution: **Living Page Mandala**. Clean Page Pulse becomes a rotating cleansing glyph. |
| 6 | Pre-run trait choice: larger clean zones, stronger heal pulses, or corruption-damage bonus. |
| 7 | Cleansing corruption grants +10% damage for 5s, cooldown 10s. |
| 8 | Clean Page zones grant allies/pets +10% attack speed while inside. |
| 9 | Unlock second exclusive evolution: **White Lotus Fold**, combining Clean Page + Paperfold. |
| 10 | Max mastery: first failed Page Event each run converts into a partial reward instead of full hazard if Mender participates; bonus cosmetic: glowing paper halo. |

---

### 14.5 Paint Witch

**Theme:** A messy little witch who paints flowers, storms, and impossible colors into being.  
**Starter Weapon:** Color Bloom.  
**Preferred Material:** Color Bloom.  
**Dash:** Smears color into longer streaks.  
**Passive:** Color effects mix into stronger blooms.  
**Role:** Combo-heavy area control and screen-filling color power.

#### Mastery Track

| Level | Reward |
|---:|---|
| 1 | Unlock Paint Witch with Color Bloom and Color Smear Dash. |
| 2 | Color Bloom area +5%. |
| 3 | Unlock alternate starter choice: Watercolor Wave. |
| 4 | Dashing through Color Bloom causes a splash burst every 5s. |
| 5 | Unlock exclusive evolution: **Garden Witchstorm**. Color Bloom creates chained flowers. |
| 6 | Pre-run trait choice: larger blooms, faster pulses, or stronger water spread. |
| 7 | Color Bloom damage +10% against slowed or snared enemies. |
| 8 | Color Smear Dash leaves a longer streak and increases pickup visibility inside color. |
| 9 | Unlock second exclusive evolution: **Prismatic Cauldron**, combining Color Bloom + Waxlight/Moonlight. |
| 10 | Max mastery: first Color Bloom weapon upgrade each run also grants +5% Pagecraft duration for that run; bonus cosmetic: starry witch hat. |

---

### 14.6 Moonline Ranger

**Theme:** A swift storybook ranger who draws moonlit paths and luminous lines across the page.  
**Starter Weapon:** Moonbeam Scribble.  
**Preferred Material:** Moonlight.  
**Dash:** Creates a straight moonline between start and end points.  
**Passive:** Straight-line attacks pierce harder and scale with positioning.  
**Role:** Precision positioning without aiming; beam lanes and dash lines.

#### Mastery Track

| Level | Reward |
|---:|---|
| 1 | Unlock Moonline Ranger with Moonbeam Scribble and Moonline Dash. |
| 2 | Moonlight line length +5%. |
| 3 | Unlock alternate starter choice: Lantern Wisp. |
| 4 | Moonline Dash damages enemies crossing the created line for 5s. |
| 5 | Unlock exclusive evolution: **Silver Horizon Shot**. Moonbeam creates wide horizon beams. |
| 6 | Pre-run trait choice: longer lines, stronger pierce, or line echo chance. |
| 7 | Straight-line attacks deal +10% damage if they hit 5 or more enemies. |
| 8 | Moonline Dash creates a light pool at both endpoints. |
| 9 | Unlock second exclusive evolution: **Constellation Road**, combining Moonbeam + Star Sticker/Lantern. |
| 10 | Max mastery: every 5th dash casts a free weak Moonbeam along the dash path; bonus cosmetic: midnight cloak. |

---

### 14.7 Paper Prince

**Theme:** A tiny ruler of folded castles, paper thorns, and pop-up defenses.  
**Starter Weapon:** Paper Thorn.  
**Preferred Material:** Paperfold.  
**Dash:** Raises a short folded-paper wall.  
**Passive:** Paper structures last longer and block more enemies.  
**Role:** Defensive builder and battlefield shaper.

#### Mastery Track

| Level | Reward |
|---:|---|
| 1 | Unlock Paper Prince with Paper Thorn and Fold Wall Dash. |
| 2 | Paperfold structure duration +5%. |
| 3 | Unlock alternate starter choice: Toy Soldier March. |
| 4 | Fold Wall Dash blocks projectiles and light enemies for 5s. |
| 5 | Unlock exclusive evolution: **Pop-Up Royal Guard**. Paper Thorn summons guard walls. |
| 6 | Pre-run trait choice: wider folds, stronger thorns, or structure duration. |
| 7 | Enemies colliding with Paperfold structures take +10% damage for 5s. |
| 8 | Fold Wall Dash leaves a Crown Spark sigil at the wall center. |
| 9 | Unlock second exclusive evolution: **Castle in the Margin**, combining Paper Thorn + Crown Spark/Toy Soldiers. |
| 10 | Max mastery: Page Event defense objectives start with a small friendly paper wall if Paper Prince is present; bonus cosmetic: golden paper crown. |

---

### 14.8 Watercolor Kid

**Theme:** A soft, fluid doodle child who rides waves, puddles, and moonlit water.  
**Starter Weapon:** Watercolor Wave.  
**Preferred Material:** Water/Color Bloom.  
**Dash:** Turns briefly into a puddle and slips through enemies.  
**Passive:** Water carries other materials farther.  
**Role:** Fluid movement, spreading effects, and map-specific synergy.

#### Mastery Track

| Level | Reward |
|---:|---|
| 1 | Unlock Watercolor Kid with Watercolor Wave and Puddle Dash. |
| 2 | Water/Color spread distance +5%. |
| 3 | Unlock alternate starter choice: Seashell Song. |
| 4 | Puddle Dash creates a ripple that pushes small enemies. |
| 5 | Unlock exclusive evolution: **Moonlit Waterfall**. Watercolor Wave becomes a cascading wave series. |
| 6 | Pre-run trait choice: wider waves, longer wet channels, or stronger ripple push. |
| 7 | Water-spread materials deal +10% damage for 5s after spreading. |
| 8 | Puddle Dash grants 1s of contact immunity after passing through enemies, cooldown 10s. |
| 9 | Unlock second exclusive evolution: **Paper Boat Dreamsea**, combining Watercolor Wave + Paper Boat Fleet. |
| 10 | Max mastery: first water-related Page Event each run grants +5% run-wide pickup radius after completion; bonus cosmetic: moon pond skin. |

---

### 14.9 Pet Warden — Endgame Character

**Theme:** A late-game companion commander who fights primarily through pets.  
**Starter Weapon:** Rainbow Thread.  
**Preferred Material:** Storythread/Pet synergy.  
**Dash:** Commands equipped pets to perform coordinated attacks.  
**Passive:** Can equip multiple pets and scales through pet unlocks.  
**Role:** Endgame pet-build character requiring multiple pets.

#### Unlock Requirement

Pet Warden is intentionally endgame.

Unlock requires:

- 5 pets unlocked through quests or purchase,
- at least 3 pets at tier 5,
- completion of the Page Event chain **Gather the Lost Companions**,
- defeat any chapter boss on Hard after meeting the pet requirements.

#### Special Pet Rules

Pet Warden can equip:

- 2 pets at mastery level 1,
- 3 pets at mastery level 5,
- 5 pets at mastery level 10.

Non-Warden characters equip 1 active pet by default, with meta upgrades possibly previewing or supporting pet choice but not equipping multiple active pets.

#### Mastery Track

| Level | Reward |
|---:|---|
| 1 | Unlock Pet Warden with Rainbow Thread and Command Dash; can equip 2 active pets. |
| 2 | Pet attack damage +5%. |
| 3 | Unlock alternate starter choice: Button Beetle. |
| 4 | Command Dash causes all active pets to perform a weak bonus attack, cooldown 10s. |
| 5 | Can equip 3 active pets; unlock exclusive evolution: **Companion Constellation**. |
| 6 | Pre-run trait choice: pet attack speed, pet damage, or pet Pagecraft activation. |
| 7 | Pet attacks create small Storythread links between enemies. |
| 8 | Completing a Page Event refreshes Command Dash and gives pets +10% attack speed for 10s. |
| 9 | Unlock second exclusive evolution: **Doodle Stampede**, combining Button Beetle, Toy Bell, and pet attacks. |
| 10 | Max mastery: can equip 5 active pets; Command Dash triggers a full pet formation attack every 25s; bonus cosmetic: companion crown cloak. |

---

## 15. Pets / Companions

### Pet Philosophy

Pets are strong. They are not minor stat sticks.

Every pet:

- attacks enemies,
- has a distinct behavior,
- has 5 tiers,
- has a quest unlock path,
- can be purchased with Treats as a fallback,
- interacts with Pagecraft,
- should be visibly present and emotionally appealing.

### Unlock Philosophy

It should be heavily encouraged to unlock pets through quests instead of buying them outright.

Direct purchase exists so players are not permanently blocked, but it should feel pricey.

The current purchase prices are intentionally cut in half from the previous direction while still remaining meaningful.

### Pet Purchase Costs

| Pet Rarity | Direct Treat Cost | Notes |
|---|---:|---|
| Common | 50 Treats | early pets such as Dog, Cat, Bunny |
| Uncommon | 75 Treats | map/mechanic-specific pets |
| Rare | 100 Treats | stronger or more specialized pets |
| Legendary / Endgame | 125 Treats | pet-build-defining companions |

Quest unlocks are always preferred and should feel much more efficient.

### Pet Upgrade Costs

Each pet has 5 tiers.

| Tier | Cost | Rule |
|---:|---:|---|
| 1 | 0 | unlocked pet starts here |
| 2 | 10 Treats | basic improvement |
| 3 | 25 Treats | secondary effect |
| 4 | 50 Treats | strong combat improvement |
| 5 | 100 Treats | signature capstone |

All costs are multiples of 5.

### Pet List

MVP should include at least 5 pets. Full target includes 10.

#### 15.1 Dog

**Role:** pickup fetcher, biter, beginner-friendly support.  
**Unlock Quest:** Complete **Rescue the Loyal Pup** Page Event in Waxlight Castle.  
**Direct Cost:** 50 Treats.

| Tier | Behavior |
|---:|---|
| 1 | Dog bites nearby enemies every 2s and fetches XP within a small radius. |
| 2 | Bite damage +25%; fetch radius +25%. |
| 3 | Dog can fetch health hearts and Page Event objects. |
| 4 | Dog bite knocks enemies into Pagecraft marks. |
| 5 | Dog performs **Heroic Fetch** every 25s, dragging a valuable pickup or biting an elite for heavy damage. |

#### 15.2 Cat

**Role:** chaotic striker that bats enemies into danger.  
**Unlock Quest:** Complete **Find the Moon-Cat on the Roof Page**.  
**Direct Cost:** 50 Treats.

| Tier | Behavior |
|---:|---|
| 1 | Cat swipes nearby enemies every 2s. |
| 2 | Swipe damage +25% and can crit. |
| 3 | Cat bats small enemies into Pagecraft zones. |
| 4 | Cat occasionally bats stickers/pickups toward the player. |
| 5 | Cat performs **Midnight Pounce**, leaping across the screen and striking 5 enemies. |

#### 15.3 Cow

**Role:** sustain and slowing field pet.  
**Unlock Quest:** Restore the Buttonwood Meadow and complete **Guide the Gentle Cow**.  
**Direct Cost:** 75 Treats.

| Tier | Behavior |
|---:|---|
| 1 | Cow headbutts enemies and leaves soft milk-moon puddles that slow. |
| 2 | Headbutt damage +25%; puddles last +5s. |
| 3 | Puddles lightly heal the player/pets over time. |
| 4 | Cow charge pushes enemies through slowing puddles. |
| 5 | Cow performs **Moon-Milk Stampede**, charging in a wide lane and leaving a healing slow field. |

#### 15.4 Duck

**Role:** water synergy and projectile pecker.  
**Unlock Quest:** Complete **Restore the Moonlit Pond**.  
**Direct Cost:** 75 Treats.

| Tier | Behavior |
|---:|---|
| 1 | Duck pecks enemies and splashes water marks. |
| 2 | Peck damage +25%; splashes spread Color Bloom. |
| 3 | Duck puddles increase Watercolor Wave and Paper Boat speed. |
| 4 | Duck quacks, sending a ripple that pushes enemies every 10s. |
| 5 | Duck performs **Royal Quackwave**, a huge water ripple that carries all nearby materials. |

#### 15.5 Frog

**Role:** combo trigger and splash attacker.  
**Unlock Quest:** Catch the frog during **Leap Across the Lily Stars**.  
**Direct Cost:** 75 Treats.

| Tier | Behavior |
|---:|---|
| 1 | Frog leaps at enemies and creates splash damage. |
| 2 | Leap damage +25%; splash radius +25%. |
| 3 | Frog landing triggers nearby Color Bloom/Dreamsap effects. |
| 4 | Frog can leap to elites and briefly stun them. |
| 5 | Frog performs **Five-Hop Finale**, bouncing between 5 targets and detonating Pagecraft at each landing. |

#### 15.6 Bunny

**Role:** dash synergy and rapid melee attacks.  
**Unlock Quest:** Complete **Follow the Ribbon Bunny**.  
**Direct Cost:** 50 Treats.

| Tier | Behavior |
|---:|---|
| 1 | Bunny kicks enemies after the player dashes. |
| 2 | Kick damage +25%; dash recovery -5%. |
| 3 | Bunny leaves hop trails that damage enemies. |
| 4 | Bunny kicks trigger small Storythread links. |
| 5 | Bunny performs **Carrot Comet Hop**, making 5 explosive hops in the dash direction. |

#### 15.7 Snail

**Role:** slow trail, reflective utility, safe control.  
**Unlock Quest:** Complete **Protect the Tiny Snail Trail**.  
**Direct Cost:** 75 Treats.

| Tier | Behavior |
|---:|---|
| 1 | Snail bumps enemies and leaves shiny slow trail. |
| 2 | Trail lasts +5s and slow strength increases. |
| 3 | Trail merges with Dreamsap and Color Bloom. |
| 4 | Trail reflects Moonlight beams at reduced strength. |
| 5 | Snail performs **Silver Spiral**, drawing a large reflective spiral that slows and damages enemies. |

#### 15.8 Raccoon

**Role:** greedy combat looter with claw attacks.  
**Unlock Quest:** Catch Raccoon during **The Shiny Thing Heist**.  
**Direct Cost:** 100 Treats.

| Tier | Behavior |
|---:|---|
| 1 | Raccoon claws enemies and occasionally finds extra Pigment. |
| 2 | Claw damage +25%; Pigment find chance increases. |
| 3 | Raccoon can steal small pickups from elite enemies. |
| 4 | Stolen pickups can include rare Treats at low chance. |
| 5 | Raccoon performs **Treasure Ambush**, attacking an elite and dropping a burst of loot. |

#### 15.9 Fox

**Role:** evasive striker and illusion pet.  
**Unlock Quest:** Complete **Chase the Firefly Fox**.  
**Direct Cost:** 100 Treats.

| Tier | Behavior |
|---:|---|
| 1 | Fox dashes through enemies and leaves a firefly trail. |
| 2 | Dash damage +25%; trail duration +5s. |
| 3 | Fox creates a brief illusion decoy after dashing. |
| 4 | Firefly trail activates Moonlight and Color Bloom marks. |
| 5 | Fox performs **Lantern Mirage**, creating 5 fox illusions that dash outward. |

#### 15.10 Dragonling

**Role:** rare high-damage attack pet.  
**Unlock Quest:** Complete the chain **Hatch the Paper Dragon Egg**.  
**Direct Cost:** 125 Treats.

| Tier | Behavior |
|---:|---|
| 1 | Dragonling breathes small flame/color arcs. |
| 2 | Breath damage +25%; arc width +25%. |
| 3 | Breath ignites Waxlight/Color Bloom marks. |
| 4 | Dragonling circles elites and applies vulnerability. |
| 5 | Dragonling performs **Storyflame Nova**, a large circular breath attack that detonates nearby marks. |

---

## 16. Maps / Storybook Chapters

### Chapter Structure

Each chapter is a finite storybook page/spread with:

- unique visual identity,
- unique environmental mechanics,
- 2 unique enemies,
- a boss/finale at 30:00,
- chapter-specific Page Event variants,
- unique restoration nodes,
- pet unlock opportunities.

### Chapter 1 — Waxlight Castle

**Theme:** A glowing hand-drawn castle kingdom made of waxy color, paper banners, soft moonlit walls, and tiny towers.  
**Gameplay Focus:** Waxlight trails, simple folds, starter-friendly lanes.  
**Map Bounds:** 120m x 90m.

Environmental features:

- castle paths,
- folded paper walls,
- waxlit bridges,
- little towers,
- crown sigils,
- torn gates.

Unique enemies:

1. **Crownless Knight** — small armored doodle that charges in straight lines.
2. **Moat Mote** — floating sticky mote that leaves slowing Dreamsap droplets.

Boss:

- **The Crooked Crown** — a corrupted crown creature that summons knight waves and blank royal sigils.

Pet opportunity:

- Dog.

### Chapter 2 — Moonlit Watercolor Pond

**Theme:** A soft moonlit pond painted into the page, with lily stars, paper boats, ripples, and glowing reflections.  
**Gameplay Focus:** water spreading materials, ripples, Color Bloom propagation.

Environmental features:

- pond zones,
- lily pads,
- moon reflections,
- paper boat lanes,
- wet pigment channels.

Unique enemies:

1. **Lily Blot** — stationary blot that fires slow water-ink pulses.
2. **Soggy Sprite** — quick enemy that becomes faster in wet zones but takes more Moonlight damage.

Boss:

- **The Ink-Well Moonfish** — a giant fish-shaped blot that dives through wet channels.

Pet opportunity:

- Duck or Frog.

### Chapter 3 — Ribbon Road

**Theme:** A winding road of ribbons, thread, stars, and stitched paths through a dreamy story landscape.  
**Gameplay Focus:** Storythread connections, dash rails, chain damage.

Environmental features:

- ribbon lanes,
- knot gates,
- spools as landmarks,
- thread bridges,
- crossing paths.

Unique enemies:

1. **Knot Imp** — ties the player’s Pagecraft marks into temporary hazards.
2. **Thread Serpent** — long segmented enemy that follows ribbon lanes.

Boss:

- **The Tangled Tailor-Wyrm** — a giant thread serpent that knots sections of the arena.

Pet opportunity:

- Bunny.

### Chapter 4 — Buttonwood Forest

**Theme:** A fairy-tale forest of doodle trees, buttons, acorns, mushrooms, fireflies, and tiny creature homes.  
**Gameplay Focus:** creature weapons, pet unlocks, nature/paper interactions.

Environmental features:

- button flowers,
- acorn groves,
- firefly lanterns,
- hollow logs,
- mushroom rings.

Unique enemies:

1. **Hollow Acorn** — armored acorn enemy that cracks into smaller husks.
2. **Bark Scribbler** — tree-bark doodle that roots and fires thorn lines.

Boss:

- **The Hollow Story-Oak** — a corrupted tree that spawns roots, acorns, and blank leaves.

Pet opportunity:

- Cow, Raccoon, Fox.

### Chapter 5 — Pop-Up Kingdom

**Theme:** A dimensional pop-up book spread with folding bridges, rising castles, paper hills, and moving structures.  
**Gameplay Focus:** Paperfold structures, blocking, terrain changes.

Environmental features:

- fold lines,
- pop-up ramps,
- paper towers,
- folding bridges,
- hidden doors.

Unique enemies:

1. **Folded Gremlin** — hides inside paper folds and ambushes.
2. **Paper Jester** — flips fold lines into hazards and throws paper confetti bombs.

Boss:

- **The Upside-Down Castle** — a moving pop-up fortress with multiple weakpoints.

Pet opportunity:

- Snail or Dragonling quest chain begins.

### Chapter 6 — Torn Margin

**Theme:** The edge of the storybook where the page is torn, unstable, and eaten by blankness.  
**Gameplay Focus:** dangerous boundaries, tears, corruption cleansing, high-pressure events.

Environmental features:

- torn page cliffs,
- blankness walls,
- rips that spawn enemies,
- unstable bridges,
- drifting scraps.

Unique enemies:

1. **Margin Maw** — mouth-like tear that lunges from page edges.
2. **Ragged Dragonling** — corrupted dragon doodle that breathes Blankness.

Boss:

- **The Tear That Learned to Walk** — a giant animated rip that splits the arena.

Pet opportunity:

- Dragonling continuation.

### Chapter 7 — The Blank Page

**Theme:** A nearly empty final page where the player-created marks matter most. The story is almost gone.  
**Gameplay Focus:** Pagecraft mastery, high enemy density, final systems.

Environmental features:

- mostly blank terrain,
- player marks highly visible,
- corruption spreading from edges,
- hidden story fragments,
- final restoration glyphs.

Unique enemies:

1. **Blank Husk** — colorless humanoid that weakens nearby player marks.
2. **Unfinished Giant** — large incomplete doodle that gains abilities over time if not killed.

Boss:

- **The Unwritten King** — final boss that drains color, rewrites the page, and forces the player to reclaim territory.

Pet opportunity:

- Pet Warden unlock chain finale.

---

## 17. Enemy Design

### Enemy Philosophy

Enemies should feel like corrupted storybook drawings, living scribbles, torn-page monsters, faded creatures, and blankness nightmares.

Avoid enemies that are literally school supplies.

### Common Enemy Families

| Enemy | Behavior |
|---|---|
| Scribble Imp | basic chaser, high count |
| Ink Wisp | drifting ranged enemy |
| Tornling | fast zig-zag enemy from tears |
| Smudge Slime | slow, leaves corruption trail |
| Crooked Knight | charges in straight lines |
| Faded Fox | evasive flanker |
| Nightmare Bunny | fast hopping enemy |
| Paper Bat | flying sprite-card enemy crossing lanes |
| Hollow Star | explodes into small projectiles |
| Weeping Cloud | rains small damaging puddles |
| Thorn Doodle | root/line hazard enemy |
| Folded Gremlin | hides in folds, ambushes |
| Color-Eater | consumes player marks to heal |
| Blot Beast | elite heavy enemy |
| Blank Husk | reduces material effectiveness nearby |

### Death Effects

Enemy deaths should use art/storybook destruction, not gore:

- scribbles unravel,
- paper monsters tear into scraps,
- ink wisps pop into droplets,
- blank husks refill with color then dissolve,
- sticker-like enemies peel away,
- clouds puff into mist,
- dragon doodles scatter sparks.

### Enemy Density

Enemy density should be high enough to visually overwhelm, but individual enemies should often die quickly once the player has a build.

Use elites and map enemies for actual threat. Use basic enemies as satisfying horde fuel.

---

## 18. Page Events / Quests

### Page Event Rules

- Spawn at 5:00, 10:00, 15:00, 20:00, 25:00.
- In endless, continue every 5 minutes after the boss starts, beginning at 35:00.
- Each has a visible 3-minute countdown.
- Completing events gives strong rewards.
- Failing events creates a hazard, enemy wave, corruption spread, or reduced reward.
- Events should be completable in solo without perfect movement.
- Events should encourage the player to move around the finite map.

### Reward Types

Page Events can reward:

- Pigment,
- Treats,
- weapon upgrade,
- passive item upgrade,
- eligible evolution card,
- pet quest progress,
- pet unlock,
- Pagecraft modifier,
- temporary super attack,
- map feature repair,
- Sticker Album entry.

### Event List

#### Repair the Tear

A rip opens and enemies pour out.

Objective:

- Stand near 5 anchor points or defeat enemies near the tear.

Timer:

- 3 minutes.

Reward:

- Paperfold upgrade choice or Pigment.

Failure:

- Tear remains as a spawn point for 5 minutes.

#### Rescue the Lost Star

A friendly star sticker is trapped under Blankness.

Objective:

- Clear corruption and dash across the star.

Reward:

- Star Sticker upgrade or pet quest progress.

Failure:

- Star becomes a Hollow Star elite.

#### Fill the Color Well

A blank drawing needs color.

Objective:

- Kill enemies inside the circle or bring Color Bloom/Waxlight marks into it.

Reward:

- Color-based upgrade, weapon/item upgrade, or eligible evolution card.

Failure:

- The well spills Blankness.

#### Defend the Paper Crown

A tiny crown appears and enemies try to destroy it.

Objective:

- Defend the crown for 90 seconds within the 3-minute window.

Reward:

- Crown Spark/Tiny Crown reward, Pigment, or character mastery bonus.

Failure:

- Crownless Knight elite wave.

#### Wake the Pop-Up Bridge

A flat paper bridge must be unfolded.

Objective:

- Dash through 5 fold lines and defeat enemies at each fold.

Reward:

- Opens shortcut and grants Paperfold reward.

Failure:

- Bridge becomes a folded hazard.

#### Guide the Fireflies

Fireflies need to be guided to lanterns.

Objective:

- Move through 5 glowing checkpoints while enemies swarm.

Reward:

- Firefly Jar, Lantern Wisp, or Fox quest progress.

Failure:

- Darkness zone grows temporarily.

#### Calm the Storm Cloud

A doodle cloud begins raining corruption.

Objective:

- Damage cloud fragments and cleanse rain puddles.

Reward:

- Water/Moonlight reward.

Failure:

- Weeping Cloud elite spawns.

#### Gather the Lost Companions

Endgame pet chain event.

Objective:

- Use active pets to defeat enemies around companion glyphs.

Reward:

- Pet Warden unlock progress.

Failure:

- No permanent penalty, but event chain must be attempted again.

---

## 19. Boss Design

### Boss Spawn Rule

At 30:00, the boss/finale starts.

Page Events stop spawning. Normal waves continue but become boss-support waves.

### Boss Fight Requirements

Bosses should:

- be readable from the top-down 2.5D camera,
- have large silhouettes,
- cast real shadows,
- interact with Pagecraft,
- spawn adds,
- have weakpoints or phases,
- produce huge damage numbers,
- be vulnerable to strong builds,
- end the run when defeated.

### Boss Health Tuning

Boss health should support:

- strong builds killing in 1.5-3 minutes after boss spawn,
- average winning builds killing in 4-6 minutes after boss spawn,
- weak builds struggling into post-30:00 boss pressure.

### Post-30:00 Pressure

After the boss starts at 30:00:

- boss attack frequency can increase over time,
- support wave density can increase over time,
- endless Page Events can continue if endless is active,
- player can still win.

This preserves the 30-minute target without forcing a hard fail at exactly 30:00.

---

## 20. Meta Progression

### Currency System

Keep currencies simple.

#### Pigment

Main progression currency.

Used for:

- Storybook Restoration,
- permanent upgrades,
- character unlock nodes,
- art supply unlock nodes,
- chapter unlocks.

Earned from:

- runs,
- Page Events,
- bosses,
- Sticker Album milestones,
- chapter clears.

#### Treats

Pet-focused currency.

Used for:

- direct pet fallback purchases,
- pet tier upgrades,
- pet habitat features,
- pet cosmetics.

Earned from:

- rare in-run pickups,
- pet quests,
- Page Events,
- Sticker Album pet milestones,
- Hard/Endless milestones.

#### Stickers

Collection entries, not normal spendable currency.

Used for:

- Sticker Album completion,
- lore snippets,
- cosmetics,
- small milestone rewards.

### Storybook Restoration

The hub is a magical storybook being restored.

Each chapter restoration path has **5 tiers**.

Example Chapter Restoration Track:

| Tier | Cost | Unlock |
|---:|---:|---|
| 1 | 50 Pigment | reveal chapter page |
| 2 | 100 Pigment | unlock chapter Page Events |
| 3 | 150 Pigment | unlock character/pet quest |
| 4 | 250 Pigment | unlock Hard mode for chapter |
| 5 | 500 Pigment | unlock chapter boss sticker/cosmetic/meta bonus |

Costs are multiples of 5 and can be tuned.

### Permanent Upgrade Tree — The Wonder Box

Rename the permanent upgrade system from a school/art-supply-coded tree into **The Wonder Box**.

The Wonder Box contains keepsakes, stars, buttons, ribbons, little crowns, moons, and story charms.

Each node has **5 ranks**.

Branches:

1. Movement.
2. Collection.
3. Pagecraft.
4. Luck / Run Control.
5. Survival.
6. Pets.
7. Loadout.

Example node:

**Pickup Radius**

| Rank | Cost | Effect |
|---:|---:|---|
| 1 | 25 Pigment | +5% pickup radius |
| 2 | 50 Pigment | +10% pickup radius total |
| 3 | 100 Pigment | +15% pickup radius total |
| 4 | 200 Pigment | +20% pickup radius total |
| 5 | 400 Pigment | +25% pickup radius total |

Wonder Box stat-node details live in `design/gdd/mvp-item-candidate-pool.md` under the long-term meta progression section. That focused sheet is the source for exact Wonder Box stat tracks and rank values.

Root-GDD Wonder Box invariants:

- Wonder Box stat nodes should stay below in-run item strength so draft choices still matter.
- Wonder Box uses 5 ranks per stat node.
- Wonder Box does **not** include `base_stat_boost`, `revive`, `effect_count`, `active_cap`, or `dash_count` stat tracks. Those remain item-only or explicit content effects.
- The pickup-radius table above is an example cost/effect pattern, not the full stat-track roster.

Do not duplicate the Wonder Box stat-track table in this root document. Update `design/gdd/mvp-item-candidate-pool.md` first, then adjust this section only when a stable rule changes.

### Character Progression

Each character has 10 mastery levels and gameplay rewards at every level. Cosmetics only appear as bonus rewards at max mastery or milestones.

### Art Supply / Wonder Unlocks

Because the theme is no longer school supplies, call this system **Wonder Unlocks** or **Storybook Keepsakes** rather than Art Supply Collection.

This system unlocks:

- weapons,
- passives,
- evolution hints,
- Page Events,
- character alternates,
- pets,
- cosmetics.

Unlock philosophy:

- early unlocks are reliable and readable,
- late unlocks are weird, strong, and combo-heavy,
- unlocks should expand playstyles, not just increase raw power.

---

## 21. Hub Design

### Hub Concept

The hub is the restored storybook itself.

Players turn pages, restore illustrations, visit pets, inspect stickers, adjust builds, and choose chapters.

### Hub Areas

#### Storybook Table of Contents

Chapter selection.

#### Wonder Box

Permanent upgrades.

#### Doodle Den

Pet habitat.

#### Sticker Album

Collection log.

#### Character Pages

Character mastery and alternate starter choices.

#### Keepsake Shelf

Weapon/passive unlocks and evolution hints.

### Doodle Den

The Doodle Den is where pets roam.

Functions:

- view pets,
- equip active pet,
- upgrade pet tiers,
- inspect pet quests,
- buy pets with Treats as fallback,
- see pet attacks,
- assign cosmetics.

Pet Warden unlock requirements are visible here once the player has at least 3 pets.

---

## 22. UI / UX

### In-Run HUD

Must show:

- timer,
- player health,
- XP bar,
- current level,
- weapon slots 1–5,
- passive slots 1–5,
- pet icon and tier,
- Page Event countdown if active,
- boss health after 30:00,
- Pigment/Treat pickup feedback,
- damage numbers.

### Page Event UI

When event spawns:

- show banner,
- show location indicator,
- show 3:00 countdown,
- show objective steps,
- show reward preview if appropriate.

### Level-Up UI

The 3 choices should be large cards with:

- icon,
- name,
- level indicator,
- material tag,
- short gameplay description,
- evolution hint if relevant,
- synergy badges with character/pet/current build.

### Damage Number UI

Damage numbers should not be hidden behind optional advanced settings. They are part of the default juice.

Accessibility options:

- Full numbers.
- Reduced numbers.
- Boss/crit only.
- Off.
- Scale slider.
- High contrast option.

---

## 23. Art Direction

### High-Level Look

Pagebound should look like:

> A hand-drawn storybook fantasy battle taking place on a physical 3D page under real light.

### Visual Split

Hand-drawn / illustrative:

- characters,
- enemies,
- pets,
- spell shapes,
- stickers,
- icons,
- UI,
- storybook buildings,
- fantasy props.

Physically tactile / lit:

- paper surface,
- page edges,
- folds,
- shadows,
- glossy stickers,
- wet color,
- waxy marks,
- dream sap,
- raised paper structures,
- table/background props.

### Do Not Drift Into School Theme

Avoid making the visual world about:

- classrooms,
- school supplies,
- homework,
- lunch trays,
- rulers,
- scissors,
- pencil cases.

The page can be on a table or in a book, but the story should feel timeless and fantasy-driven.

### Character Art

Characters should be:

- small but readable,
- cute,
- bold silhouettes,
- simple color palettes,
- strong idle animations,
- frame-animated or cutout-animated,
- rendered as Sprite3D/quad cards.

### Enemy Art

Enemies should be:

- readable at high count,
- slightly crooked or corrupted,
- not too detailed,
- designed with distinct silhouettes,
- color-coded by threat type.

### Pet Art

Pets should be:

- very appealing,
- larger than purely realistic scale,
- readable in combat,
- animated with strong personality,
- equipped pet should be easy to identify.

### Effects Art

Effects should be big and satisfying but layered carefully.

VFX hierarchy:

1. Player danger and enemy telegraphs.
2. Boss attacks.
3. Page Event objectives.
4. Player attack/evolution effects.
5. Pet effects.
6. Damage numbers.
7. Ambient effects.

Late-game should be visually intense, but telegraphs and player position must remain readable.

---

## 24. Audio Direction

### Audio Identity

Audio should feel:

- magical,
- storybook-like,
- cozy but energetic,
- tactile,
- playful,
- powerful late-game.

Avoid school/recess sound identity.

### Music

Music layers:

- calm chapter start,
- growing mid-run rhythm,
- Page Event motif,
- 25:00 final Page Event tension,
- 30:00 boss theme,
- endless escalation layer,
- victory flourish.

Instrumentation inspiration:

- bells,
- music box,
- soft strings,
- hand percussion,
- toy-like percussion,
- choir pads,
- whimsical woodwinds,
- deep boss drums.

### SFX

Weapon SFX should be material-specific:

- Waxlight: soft scrape, warm sparkle, glowing swish.
- Sticker: peel, pop, glossy snap.
- Dreamsap: sticky stretch, plop, elastic snap.
- Color Bloom: wet bloom, splash, magical pulse.
- Moonlight: shimmer, beam hum, bell tone.
- Paperfold: fold, flap, tear, pop-up snap.
- Pets: cute vocalizations plus attack sounds.
- Damage numbers: subtle ticks for normal hits, bigger crunch/spark for crits.

### Late-Game Mix

Because many attacks happen at once, audio must be mixed by priority.

Priority:

1. Player hurt/death warning.
2. Boss telegraphs.
3. Page Event completion/failure.
4. Evolution activation.
5. Pet capstone attacks.
6. Weapon loops.
7. Ambient.

Use audio limiting and cooldowns so weapon spam does not become painful.

---

## 25. Technical Architecture — Godot 4.6.x

### Root Scene

Recommended scene tree:

```text
Main.tscn
├── GameBootstrap
├── RunRoot
│   ├── LevelRoot
│   │   ├── PageGround
│   │   ├── EnvironmentProps
│   │   ├── Boundaries
│   │   ├── SpawnZones
│   │   └── QuestLocations
│   ├── Actors
│   │   ├── Players
│   │   ├── Pets
│   │   ├── Enemies
│   │   └── Bosses
│   ├── Projectiles
│   ├── Pagecraft
│   │   ├── PagecraftGrid
│   │   └── PagecraftRenderer
│   ├── Pickups
│   ├── VFX
│   ├── DamageNumbers
│   ├── CameraRig
│   │   └── Camera3D
│   ├── Lighting
│   │   ├── DirectionalLight3D
│   │   └── OptionalLocalLights
│   └── WorldEnvironment
└── UI
    ├── HUD
    ├── LevelUpScreen
    ├── PauseMenu
    ├── VictoryScreen
    └── DebugOverlay
```

### Core Managers

Use these systems:

- `RunDirector`
- `RunClock`
- `EnemyDirector`
- `BossDirector`
- `QuestDirector`
- `WeaponSystem`
- `PassiveSystem`
- `PetManager`
- `PagecraftGrid`
- `PagecraftRenderer`
- `DamageNumberManager`
- `PickupManager`
- `XPManager`
- `MetaProgressionManager`
- `SaveGameManager`
- `AudioManager`
- `SettingsManager`

### Player Controller

Player controller responsibilities:

- movement input,
- dash input,
- planar velocity,
- health and hurt events,
- notifying dash path to Pagecraft,
- holding references to loadout systems.

Player controller should not:

- contain weapon-specific behavior,
- directly spawn all projectiles,
- directly handle level-up card generation,
- directly manage pets beyond issuing command signals.

### Data Resources

#### EvolutionPathData

```gdscript
class_name EvolutionPathData
extends Resource

@export var id: StringName
@export var required_catalyst_tag: StringName
@export var evolved_weapon_id: StringName
@export_multiline var description: String
@export var preview_icon: Texture2D
@export var behavior_scene: PackedScene
@export var creates_page_takeover: bool = false
```

#### WeaponData

```gdscript
class_name WeaponData
extends Resource

@export var id: StringName
@export var display_name: String
@export var icon: Texture2D
@export var weapon_type: StringName
@export var material_tags: Array[StringName]
@export_multiline var page_alteration: String
@export_multiline var dash_interaction: String
@export var max_level: int = 10
@export var base_cooldown: float
@export var base_damage: int
@export var behavior_scene: PackedScene
@export var evolution_paths: Array[EvolutionPathData]
@export var description_by_level: Array[String] # exactly 10 entries
```

#### PassiveItemData

```gdscript
class_name PassiveItemData
extends Resource

@export var id: StringName
@export var display_name: String
@export var icon: Texture2D
@export var max_level: int = 5
@export var catalyst_tags: Array[StringName]
@export var modifier_tags: Array[StringName]
@export var modifiers_by_level: Array[Dictionary] # exactly 5 entries
@export var description_by_level: Array[String] # exactly 5 entries
```

#### CharacterData

```gdscript
class_name CharacterData
extends Resource

@export var id: StringName
@export var display_name: String
@export var character_scene: PackedScene
@export var starter_weapon_id: StringName
@export var alternate_starter_weapon_ids: Array[StringName]
@export var preferred_material: StringName
@export var base_max_health: int
@export var base_move_speed: float
@export var base_dash_recharge: float
@export var mastery_track: Array[Dictionary]
```

#### PetData

```gdscript
class_name PetData
extends Resource

@export var id: StringName
@export var display_name: String
@export var pet_scene: PackedScene
@export var rarity: StringName
@export var direct_treat_cost: int
@export var tier_upgrade_costs: Array[int] = [0, 10, 25, 50, 100]
@export var attack_behavior_id: StringName
@export var tier_descriptions: Array[String]
@export var quest_unlock_id: StringName
```

#### EnemyData

```gdscript
class_name EnemyData
extends Resource

@export var id: StringName
@export var display_name: String
@export var enemy_scene: PackedScene
@export var family: StringName
@export var base_health: int
@export var base_damage: int
@export var move_speed: float
@export var xp_value: int
@export var tags: Array[StringName]
@export var spawn_weight: int
```

#### PageEventData

```gdscript
class_name PageEventData
extends Resource

@export var id: StringName
@export var display_name: String
@export var event_scene: PackedScene
@export var duration_seconds: int = 180
@export var reward_table_id: StringName
@export var failure_effect_id: StringName
@export var allowed_chapters: Array[StringName]
@export var unlock_requirements: Dictionary
```

---

## 26. Movement, Physics, and Navigation

### Movement Plane

All ground actors move on X/Z.

- Y is controlled separately.
- Character cards hover slightly above ground.
- Shadows anchor actors to page.

### Collision

Use simple collision shapes:

- players: capsule or cylinder-like collision,
- enemies: cylinder/sphere/box,
- projectiles: area checks or manual overlap,
- boundaries: static collision,
- pop-up structures: static or temporary collision.

### Enemy Navigation

MVP can use steering rather than full navigation:

- enemies move toward player,
- avoid hard obstacles with simple repulsion,
- respect map bounds,
- special enemies use custom movement.

Later:

- use NavigationRegion3D or custom 2D grid on X/Z for chapters with complex obstacles.

### Dash

Dash must:

- provide a burst of speed,
- sample path through Pagecraft grid,
- trigger material activations,
- provide brief safety depending on character/upgrades,
- have clear VFX and SFX.

---

## 27. Enemy Director and Finite Spawning

### Spawn Philosophy

Because maps are finite, enemies cannot spawn from an infinite void.

Spawn methods:

- edge tears,
- blankness pools,
- behind large landmarks,
- outside camera view within map bounds,
- boss portals,
- Page Event failure points.

### Spawn Rules

- Never spawn directly on the player.
- Prefer spawn zones outside camera frustum.
- If all valid zones are visible, spawn from distant tears or blocked landmarks.
- Elite spawns should be telegraphed.
- Page Event enemies can spawn around the event but must not instantly hit objectives without warning.

### Spawn Budgets

Spawn budgets and difficulty curves are exempt from multiples-of-5 restrictions because they are tuning variables.

Use a director with:

- time-based wave definitions,
- chapter-specific enemy pools,
- elite budgets,
- current enemy cap,
- performance cap,
- co-op scaling later.

---

## 28. Save Data

Save data should track:

- Pigment,
- Treats,
- unlocked chapters,
- chapter restoration tiers,
- unlocked characters,
- character mastery XP/levels,
- unlocked weapons/passives,
- discovered evolutions,
- pets unlocked,
- pet tiers,
- pet quests,
- permanent upgrades,
- Sticker Album entries,
- settings,
- best clears,
- Hard/Endless milestones.

Use versioned save format.

```gdscript
const SAVE_VERSION := 1

var save_data := {
    "version": SAVE_VERSION,
    "pigment": 0,
    "treats": 0,
    "unlocked_chapters": [],
    "chapter_restoration": {},
    "characters": {},
    "weapons_unlocked": [],
    "passives_unlocked": [],
    "evolutions_discovered": [],
    "pets": {},
    "permanent_upgrades": {},
    "sticker_album": {},
    "settings": {},
    "best_runs": {}
}
```

---

## 29. Co-op Direction

### Co-op Fantasy

Co-op should not just be more players. It should be more material synergy.

Examples:

- One player lays Dreamsap, another dashes through it to stretch snares.
- Sticker Mage attaches stickers, Waxlight Knight detonates lanes.
- Mender Monk clears corruption around a Page Event while Paint Witch fills the Color Well.
- Pet Warden commands pets while others create Pagecraft marks for pets to trigger.

### Implementation Priority

Do not build Steam co-op first.

Order:

1. Solo systems.
2. Local debug multi-player simulation.
3. LAN/ENet host-authoritative prototype.
4. Steam integration behind the same multiplayer abstraction.

### Network Model

Host authoritative:

- host controls enemy simulation,
- host controls Pagecraft grid truth,
- host controls drops/rewards,
- clients send input,
- clients predict local movement lightly if needed.

Replicate:

- player positions,
- dash events,
- weapon cast events,
- pet attack events,
- enemy spawn/death events,
- pickup collection,
- Pagecraft material events, not every cell every frame,
- boss phases,
- Page Event state.

---

## 30. Performance Targets

### Desktop MVP Target

- 60 FPS on reasonable mid-range desktop.
- 300+ enemies visible in intense late-game if simplified.
- 250 active damage numbers max by default.
- 5 active weapons + 5 passives + 1 pet per normal player.
- Pagecraft renderer chunked and batched.

### Steam Deck Target

Later optimization target:

- 40–60 FPS.
- reduced shadow settings,
- reduced number density option,
- simpler VFX mode,
- lower decal density.

### Performance Rules

- Pool everything frequent.
- Limit dynamic shadow casters.
- Use blob shadows for high-count enemies.
- Use batched decals/mesh overlays.
- Aggregate tick damage numbers.
- Cull offscreen VFX and numbers.
- Use LOD-style simplified effects for huge late-game builds.

---

## 31. MVP Vertical Slice

### MVP Goal

Prove the core game is fun and visually distinct.

The MVP should answer:

- Is 2.5D paper diorama rendering worth it?
- Does Pagecraft make movement interesting?
- Does the power fantasy feel strong by 20–25 minutes?
- Are Page Events worth routing to?
- Are damage numbers satisfying?
- Do pets feel strong?
- Can the finite map support a full run?

### MVP Content

MVP includes:

- Godot 4.6.x project.
- One complete chapter: Waxlight Castle.
- One boss: Crooked Crown.
- Five Page Events at 5/10/15/20/25.
- Boss spawn at 30.
- Victory on boss defeat.
- 30-minute target.
- Full 20 weapons as functional placeholder behaviors.
- Full 23 passives as functional modifiers.
- At least 5 pets implemented.
- At least 3 characters fully implemented.
- Character mastery framework.
- Pet tier framework.
- Save/load.
- Damage numbers.
- Pagecraft grid with Waxlight, Color Bloom, Dreamsap, Star Sticker, Clean Page, Blankness.
- Basic hub screens.

### MVP Characters

Implement first:

1. Waxlight Knight.
2. Paint Witch.
3. Sticker Mage.

Then:

4. Dreamsap Goblin.
5. Mender Monk.

Endgame later:

- Pet Warden.

### MVP Pets

Implement first:

1. Dog.
2. Cat.
3. Duck.
4. Frog.
5. Bunny.

---

## 32. Codex Task Breakdown

### Phase 1 — Project Setup

Tasks:

- Create Godot 4.6.x project structure.
- Create root scene with Node3D runtime.
- Add Camera3D, DirectionalLight3D, WorldEnvironment.
- Create placeholder paper arena mesh.
- Create player planar movement on X/Z.
- Add dash with charge recharge.
- Add camera follow.

Acceptance:

- Player moves and dashes on a lit paper plane.
- Shadows and camera angle show 2.5D direction.

### Phase 2 — Core Combat

Tasks:

- Enemy base class.
- EnemyDirector spawning inside finite map bounds.
- Health/damage system.
- XP drops.
- Level-up UI.
- WeaponSystem with data-driven weapon loading.
- Implement first 5 weapons.
- Implement damage numbers.

Acceptance:

- Player can survive, level, choose upgrades, kill enemies, and see damage numbers.

### Phase 3 — Pagecraft

Tasks:

- PagecraftGrid.
- Material stamping API.
- Dash path sampling.
- Waxlight, Color Bloom, Dreamsap, Star Sticker, Clean Page, Blankness.
- Basic PagecraftRenderer.
- Enemy interactions with materials.

Acceptance:

- Weapons leave marks.
- Dash activates marks.
- Enemies respond mechanically to marks.

### Phase 4 — Full MVP Weapon/Passive Pool

Tasks:

- Implement all 20 weapons.
- Implement all 23 passives.
- Add level 1–10 weapon scaling.
- Add level 1–5 passive scaling.
- Add evolution framework.
- Implement at least 5 evolutions for vertical slice.

Acceptance:

- All MVP weapons/passives appear in level-up choices and function.

### Phase 5 — Page Events and Boss

Tasks:

- RunClock timeline.
- QuestDirector.
- Event spawn at 5/10/15/20/25.
- 3-minute countdown UI.
- Complete/fail logic.
- Boss spawn at 30.
- Boss health bar and victory screen.

Acceptance:

- A full timed run can complete.

### Phase 6 — Pets

Tasks:

- PetData Resources.
- PetManager.
- Pet follow/attack logic.
- 5-tier upgrade framework.
- Dog/Cat/Duck/Frog/Bunny.
- Doodle Den prototype.

Acceptance:

- Pets attack and feel strong.
- Pet tiers can be upgraded with Treats.

### Phase 7 — Meta Progression

Tasks:

- SaveGameManager.
- Pigment/Treats.
- Wonder Box upgrades.
- Storybook Restoration.
- Character mastery.
- Sticker Album flags.

Acceptance:

- Run rewards persist and unlock future power/options.

### Phase 8 — 2.5D Art Polish

Tasks:

- Sprite3D/quad character rendering.
- Blob shadows.
- Wax/gloss/wet/paper shaders.
- Better Pagecraft visuals.
- Lighting presets.
- Damage number polish.

Acceptance:

- Vertical slice visually communicates the desired style.

---


## 33. Production Completeness Audit — Restored From Earlier Specs

v1.4 correctly fixed the theme and restored weapon specificity, but it became shorter because it compressed or removed several production-spec sections that were useful for Codex implementation.

### What v1.4 intentionally removed and should stay removed

The following older content should **not** be restored:

- School/classroom/lunchbox/ruler/scissors/eraser-centered theming as a core identity.
- Strict 1:1 weapon-item evolution recipes.
- Extra Pagecraft evolution conditions.
- Five-choice upgrade drafts.
- Infinite maps.
- Untimed Page Events.
- Boss spawning before the player can complete a core build.
- Pets as mostly passive/cosmetic followers.

### What v1.4 compressed too aggressively and is restored below

The following sections are necessary for a Codex-ready production document:

- Player experience beats for the first 30 seconds, 5 minutes, 10 minutes, 20 minutes, and victory.
- Genre positioning and player-facing loop clarity.
- Detailed input, movement, dash, player state, and player scene architecture.
- Run XP economy, level pacing, upgrade draft weighting, and slot-fill rules.
- Detailed Page Event data model, lifecycle, reward tables, and failure behavior.
- Enemy and boss data schemas, wave director behavior, and boss phase rules.
- Chapter/map construction rules beyond the high-level chapter list.
- Detailed UI screen list and HUD requirements.
- Art production pipeline, placeholder/final asset sourcing, and shader/material breakdown.
- Audio pipeline, music layering, and sound-priority rules.
- Godot folder architecture and resource/schema contracts.
- Multiplayer authority model and replication boundaries.
- Performance budgets, stress tests, and debug overlays.
- Balance framework, tutorialization, content matrix, milestones, Codex prompt templates, AGENTS.md guidance, risk register, quality bar, and open design questions.

### v1.5 doctrine

v1.5 should be treated as the new canonical design document. When older versions conflict with v1.5, use v1.5.

---

## 34. Player Experience Goals

### 34.1 First 30 Seconds

The player must understand immediately:

- They are a tiny hand-drawn hero on a physically lit storybook page.
- The game plays like a top-down action roguelite even though it renders in 3D.
- Enemies approach automatically.
- The player attacks automatically.
- Movement and dash are the only core combat controls.
- Attacks leave marks on the page.
- Damage numbers appear on hit.
- The page is not flat decoration; it responds to combat.

Acceptance criteria:

- A new player can move, dash, and survive the first wave without reading a manual.
- The first weapon visibly deposits a Pagecraft mark within the first 10 seconds.
- The first dash demonstrates a visible movement burst and a contact shadow shift.
- The first damage number is large enough to be satisfying but not distracting.

### 34.2 First 5 Minutes

By the first Page Event at 5:00, the player should have experienced:

- Several level-ups.
- At least one new weapon or passive item draft.
- At least one Pagecraft dash interaction.
- One elite/miniburst enemy.
- XP collection and pickup magnet behavior.
- Pet attack behavior if a pet is equipped.
- Visible transformation of at least one local area of the page.

Target build state at 5:00:

| Element | Target |
|---|---:|
| Player run level | 5-10 |
| Weapons | 2-3 |
| Items | 1-2 |
| Pet tier effect | Tier 1 active |
| Pagecraft materials seen | 2-3 |
| Damage number density | Frequent but readable |

### 34.3 First 10 Minutes

By the second Page Event at 10:00, the player should understand the run-building loop:

- New weapons occupy weapon slots.
- New passive items occupy item slots.
- Owned weapons/items can be leveled.
- Weapons have specific material tags.
- Items have catalyst tags.
- A level 10 weapon plus a level 5 compatible item enables an evolution draft.
- Page Events are worth chasing because rewards can accelerate power.

Target build state at 10:00:

| Element | Target |
|---|---:|
| Player run level | 10-20 |
| Weapons | 3 |
| Items | 2-4 |
| First item near max | Possible |
| First weapon near high level | Possible |
| Enemy density | Visually threatening |
| Player feeling | Stronger than the horde if building coherently |

### 34.4 First 20 Minutes

By the fourth Page Event at 20:00, the build should feel defined.

The player should have:

- A clear material identity.
- At least one high-level weapon.
- One or more level 5 items in strong runs.
- At least one evolution close to appearing.
- Multiple pets attacks or pet-enhanced interactions if invested.
- Pagecraft marks covering important lanes.
- Large damage numbers appearing regularly.

The game should feel crowded. It should not feel weak.

### 34.5 Boss Window: 30:00+

At 30:00, the boss/finale starts.

Design intent:

- Strong builds can kill the boss quickly after it appears.
- Average successful builds win shortly after the 30:00 boss start.
- Weak builds may lose to boss pressure or timeout escalation.
- Boss attacks should force movement and dash decisions.
- Boss damage intake should produce large, satisfying numbers.

The player should feel like the boss is a test of whether their page takeover has become strong enough.

### 34.6 Victory Screen Experience

The victory screen should celebrate the power fantasy.

Required displayed stats:

- Time survived.
- Boss defeated.
- Enemies defeated.
- Page Events completed.
- Evolutions created.
- Highest single damage number.
- Total damage dealt.
- Favorite weapon by damage.
- Favorite pet by damage or utility.
- Pigment earned.
- Treats earned.
- Character mastery XP gained.
- Pet quest progress.
- New Sticker Album entries.
- Storybook restoration unlock prompts.

---

## 35. Genre Positioning and Product Identity

### 35.1 Comparable Structure

Pagebound uses familiar survivors-like systems:

- Auto-attacking weapons.
- XP drops.
- Level-up drafts.
- Weapon/item slots.
- Evolutions.
- 25-30 minute standard run cadence.
- Boss/finale endpoint.
- Meta progression.
- Endless mode after victory.

### 35.2 Differentiators

Pagebound must not feel like a generic survivor clone.

Its differentiators are:

- True 2.5D storybook diorama rendering.
- Pagecraft marks that alter the battlefield.
- Dash as a mark-activation tool.
- Pets as powerful attacking build pieces.
- A finite page rather than an endless void.
- Timed Page Events that create objective pressure.
- Storybook restoration as the meta hub.
- Huge default-on damage numbers as part of the late-game spectacle.

### 35.3 Target Audience

Primary audience:

- Players who enjoy Vampire Survivors-style run construction.
- Players who like power-fantasy scaling.
- Players who want low-control-complexity combat.
- Players who enjoy cute, hand-drawn, cozy-but-chaotic aesthetics.
- Players who like pets, collection logs, and meta unlocks.

Secondary audience:

- Co-op groups looking for approachable chaos.
- Steam Deck players.
- Godot/indie game fans.
- Players drawn to tactile material rendering and diorama worlds.

---

## 36. Input, Player Runtime, and Movement Detail

### 36.1 Keyboard Controls

| Action | Default Key | Notes |
|---|---:|---|
| Move Up | W | Rebindable |
| Move Left | A | Rebindable |
| Move Down | S | Rebindable |
| Move Right | D | Rebindable |
| Dash | Space | Core skill button |
| Confirm | Enter / Space | UI |
| Cancel | Esc / Backspace | UI |
| Pause | Esc | Run pause |
| Interact | E | Hub, Page Event prompts, co-op ready |
| Debug Panel | F3 | Dev builds only |
| Debug Spawn | F6/F7/F8 | Dev builds only |

### 36.2 Controller Controls

| Action | Default Control |
|---|---|
| Move | Left Stick / D-pad |
| Dash | South face button |
| Confirm | South face button |
| Cancel | East face button |
| Pause | Start/Menu |
| Interact / Ready | West face button |

### 36.3 Input Rules

- Dash buffers for 0.12 seconds.
- Dash can be queued shortly before recharge completes.
- Dash direction comes from current movement input.
- If no movement input is active, dash uses last non-zero movement direction.
- Combat does not require aiming.
- Mouse and right stick are optional for UI and future accessibility targeting only.

### 36.4 Player Scene Structure

Recommended Godot scene:

```text
Player.tscn
├── PlayerRoot (CharacterBody3D)
│   ├── VisualRoot (Node3D)
│   │   ├── BodyCard (Sprite3D or MeshInstance3D textured quad)
│   │   ├── FaceCard (optional Sprite3D overlay)
│   │   ├── AccessoryCards (Node3D)
│   │   └── SquashStretchRig (Node3D)
│   ├── ContactShadow (MeshInstance3D flat transparent blob)
│   ├── RealShadowProxy (optional simplified shadow caster)
│   ├── AnimationPlayer
│   ├── Hurtbox (Area3D)
│   │   └── CollisionShape3D
│   ├── PickupMagnetArea (Area3D)
│   │   └── CollisionShape3D
│   ├── DashTrailEmitter (Node3D)
│   ├── WeaponAnchor (Node3D)
│   ├── PetAnchor (Node3D)
│   ├── DamageNumberAnchor (Marker3D)
│   ├── HealthComponent (Node)
│   ├── MovementComponent (Node)
│   ├── DashComponent (Node)
│   ├── LoadoutComponent (Node)
│   ├── StatusEffectReceiver (Node)
│   ├── PagecraftInteractor (Node)
│   └── NetworkReplicator (Node)
```

### 36.5 Base Player Stats

| Stat | Default | Notes |
|---|---:|---|
| Max HP | 1000 | Survivability baseline |
| Move speed | 4.5 m/s | Tuning range 4.0-5.0 |
| Dash distance | 2.1 m | Modified by upgrades |
| Dash duration | 0.15 s | Main movement burst |
| Dash charges | 1 | Modified by items/characters |
| Dash recharge | 2.0 s per charge | If a charge is available, the player can dash without waiting for recharge |
| Dash invulnerability | 0.15 s | Very brief i-frame window; do not make full dash safe |
| Pickup radius | 1.4 m | Modified by items/pets |
| Damage multiplier | 1.0 | Global outgoing damage |
| Cooldown multiplier | 1.0 | Lower is faster |
| Area multiplier | 1.0 | Affects weapon area |
| Duration multiplier | 1.0 | Affects Pagecraft duration |
| Amount multiplier | 1.0 | Affects projectiles/summons |
| Pet power | 1.0 | Affects pet damage/frequency |
| Luck | 0 | Draft rarity modifier only |

### 36.6 Player States

| State | Meaning | Can Move | Can Dash | Can Take Damage |
|---|---|---:|---:|---:|
| Normal | Standard control | Yes | Yes | Yes |
| DashWindup | Short pre-dash cue | Limited | No | Yes |
| Dashing | Burst movement | Forced | No | Usually no |
| DashRecover | Post-dash recovery | Yes | No | Yes |
| Hurt | Knockback/blink | Limited | No | No during i-frames |
| Downed | Co-op revive state | No | No | No |
| Dead | Solo fail/co-op spectate | No | No | No |
| LevelUpPaused | Solo draft pause | No | No | No |
| EventChanneling | Objective capture | Yes | Yes | Yes |
| PetCommand | Endgame pet-class command burst | Yes | Yes | Yes |

### 36.7 Movement Implementation

Movement occurs on the X/Z plane.

Implementation rules:

- Convert input vector to camera-relative X/Z direction.
- Use acceleration and deceleration, not instant velocity snaps.
- Use `CharacterBody3D.move_and_slide()`.
- Avoid rigidbody player control for MVP.
- Collision should not let enemies pin the player permanently.
- During dash, movement should use a forced dash vector and sample Pagecraft along the dash path.
- Y position should remain locked to page height plus visual offset unless jumping/knockup is explicitly implemented as a visual-only effect.

---

## 37. Run XP, Level Pacing, and Upgrade Draft Rules

### 37.1 XP Currency

XP drops are called **Color Motes**.

XP values should use multiples of 5:

| Drop | Value | Visual |
|---|---:|---|
| Tiny Color Mote | 5 | Small blue-white speck |
| Bright Color Mote | 10 | Yellow/gold mote |
| Sticker Shard Mote | 25 | Pink glossy shard |
| Rainbow Drop | 50 | Rainbow prism drop |
| Boss Color Cache | 250 | Large reward burst |

### 37.2 XP Curve

Use a rounded multiple-of-5 curve:

```gdscript
func xp_required_for_level(level: int) -> int:
    var raw := 20.0 + pow(float(level), 1.45) * 8.0
    return int(ceil(raw / 5.0) * 5.0)
```

Expected run-level pacing:

| Time | Expected Player Level Band |
|---:|---:|
| 5:00 | 5-10 |
| 10:00 | 10-20 |
| 15:00 | 20-30 |
| 20:00 | 30-40 |
| 25:00 | 40-48 |
| 30:00 | 50 |
| 35:00 | 55-60 if endless continues |

These are tuning targets, not hard caps.

### 37.3 Upgrade Draft Count

Every normal upgrade draft shows exactly **3 choices**.

This applies to:

- run level-ups,
- Page Event rewards,
- elite story chests,
- boss rewards,
- rare treasure pickups.

Three choices is an explicit exception to the 5/10 structure because five choices slows down a fast run.

### 37.4 What Can Appear in Drafts

A draft card can be:

- new weapon if fewer than 5 weapons are owned,
- new passive item if fewer than 5 items are owned,
- +1 level to an owned weapon below level 10,
- +1 level to an owned item below level 5,
- evolution card if requirements are met,
- rare heal,
- rare pickup magnet,
- temporary Page Takeover attack,
- Pagecraft modifier from events/chests,
- character-specific run upgrade,
- pet-synergy upgrade.

### 37.5 Slot Rules

| Slot Type | Limit | Level Cap |
|---|---:|---:|
| Weapons | 5 | 10 |
| Passive Items | 5 | 5 |
| Equipped Pets | 1 normally | 5 tiers |
| Equipped Pets for endgame pet class | more than 1 | gated by class mastery |

### 37.6 Draft Weighting

The draft generator should weight toward useful build construction.

Weapon-only acquisition drafts:

- Run levels 5, 10, 20, and 35 show only legal new-weapon cards.
- If no legal new weapon cards exist, the draft falls back to normal composition.

Normal non-weapon-only drafts:

- Show 1 weapon-side card when legal.
- Show 1 item-side card when legal.
- Show 1 flex card from weapon, item, evolution, utility, or fallback pools.

Page Event reward drafts:

- Use build-completion bias.
- Prefer item upgrades, catalyst fixes, eligible evolutions, and high-rarity upgrades.

Late and endless:

- Prioritize evolution cards if requirements are met.
- Offer capstone upgrades and big-effect choices.
- Avoid dead cards for maxed equipment.
- After level 50, continue normal upgrades while available.
- Once no normal weapon, item, or evolution upgrades remain, switch to overflow drafts.

### 37.7 Evolution Eligibility Rule

A weapon is eligible to evolve when:

```text
Owned weapon is level 10
+ player owns at least one level 5 passive item
+ that item has a catalyst tag compatible with the weapon's evolution paths
= evolution draft can appear
```

No additional Pagecraft condition is required.

The catalyst item is **not consumed**.

### 37.8 Evolution Draft Rules

- Evolution cards may appear in level-up drafts, Page Event rewards, elite chests, and boss rewards.
- If multiple evolution paths are eligible, the draft may show one path at a time based on weighting.
- If a weapon has evolved, it should keep its slot and replace the base behavior.
- Evolved weapons still use the weapon's original material identity plus the evolution catalyst identity.

---

## 38. Run Director, Waves, and Finite Spawn Rules

### 38.1 Standard Timeline

| Time | Director Behavior |
|---:|---|
| 0:00 | Spawn basic horde, low density, high XP clarity. |
| 2:30 | First elite/miniburst chance. |
| 5:00 | Page Event 1 spawns, 3-minute countdown. |
| 7:30 | Add secondary enemy family. |
| 10:00 | Page Event 2 spawns, 3-minute countdown. |
| 12:30 | Mid-run elite wave. |
| 15:00 | Page Event 3 spawns, 3-minute countdown. |
| 17:30 | Map-unique enemies increase. |
| 20:00 | Page Event 4 spawns, 3-minute countdown. |
| 22:30 | Pre-event pressure wave. |
| 25:00 | Page Event 5 spawns, 3-minute countdown. |
| 29:30 | Boss warning. |
| 30:00 | Boss/finale starts. Standard Page Events stop. |
| 35:00 | First Endless Page Event if endless is active. |

### 38.2 Spawn Philosophy

The horde should look overwhelming but mostly be killable.

Enemy pressure should come from:

- many weak enemies,
- medium enemies that create lane pressure,
- elites with clear telegraphs,
- map-unique enemies that change movement decisions,
- boss attacks that force dash timing.

Avoid making every enemy a sponge. The player should feel strong.

### 38.3 Finite Map Spawn Rules

- All spawns occur inside the finite chapter bounds.
- Spawn points should be outside the current camera view when possible.
- If the player reaches the page edge, enemies can spawn from tears, margins, folds, or blankness gates rather than outside the world.
- Spawn positions must avoid appearing directly on top of the player.
- Bosses spawn from a chapter-specific dramatic anchor.

### 38.4 Director Data Contract

```gdscript
class_name SpawnDirectorData
extends Resource

@export var chapter_id: String
@export var difficulty_id: String
@export var timeline_events: Array[DirectorTimelineEntry]
@export var base_spawn_budget: float
@export var budget_growth_curve: Curve
@export var enemy_pools_by_time: Array[EnemyPoolEntry]
@export var elite_pools_by_time: Array[EnemyPoolEntry]
@export var map_unique_enemy_weights: Dictionary
@export var max_active_enemies: int
@export var max_active_elites: int
@export var spawn_margin_from_camera: float
@export var spawn_margin_from_player: float
```

### 38.5 Spawn Budget Notes

Enemy spawn costs and difficulty curves are exempt from the multiples-of-5 rule. They are tuning variables and should be adjusted through testing.

---

## 39. Page Event Production Spec

### 39.1 Page Event Data Contract

```gdscript
class_name PageEventData
extends Resource

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var eligible_chapters: Array[String]
@export var unlock_condition_id: String
@export var scheduled_slots_minutes: Array[int]
@export var time_limit_seconds: int = 180
@export var difficulty_weight: float = 1.0
@export var objective_scene: PackedScene
@export var reward_table: PageEventRewardTable
@export var failure_consequence_id: String
@export var material_tags: Array[String]
@export var pet_unlock_id: String
@export var co_op_scaling_id: String
@export var damage_number_reward_profile: String
```

### 39.2 Event Lifecycle

1. Director selects an eligible event for the next 5-minute slot.
2. Ten-second warning appears.
3. Event anchor appears on the map with edge-of-screen guidance.
4. Countdown starts at 180 seconds.
5. Objective logic starts.
6. Event-specific enemies or hazards spawn.
7. Progress UI displays.
8. Success or failure resolves.
9. Reward draft, chest, or immediate reward appears on success.
10. Failure creates a hazard, enemy burst, or missed unlock.
11. Sticker Album, pet quest, mastery, and meta progress update.

### 39.3 Event Reward Types

Page Events can reward:

- immediate Pigment,
- Treat chance,
- new weapon draft,
- item draft,
- +1 weapon level,
- +1 item level,
- evolution card if eligible,
- temporary Page Takeover attack,
- Pagecraft modifier,
- pet rescue progress,
- character mastery XP,
- map change,
- Sticker Album entry.

### 39.4 Event Failure Rules

Failure should hurt, but not instantly end the run.

Failure examples:

- Blankness spreads from the failed zone.
- An elite enemy spawns.
- The next Page Event has a lower reward tier.
- The player loses a pet-rescue opportunity for that run.
- A map hazard remains until cleansed.

### 39.5 MVP Page Events

MVP should include at least these 10 Page Events:

| Event | Core Objective | Reward Identity |
|---|---|---|
| Patch the Torn Path | Stand near tear / collect paper patches | Paperfold reward |
| Rescue the Lost Sticker | Clear enemies and dash over sticker | Star Sticker reward |
| Fill the Color Well | Kill enemies inside zone / bring Color Bloom | Color Bloom reward |
| Chase the Runaway Moon | Stay near moving moon doodle | Moonlight reward |
| Defend the Tiny Crown | Protect objective | Royal reward |
| Clean the Blank Spot | Clear corruption nodes | Clean Page reward |
| Wake the Pop-Up Tower | Dash across fold lines | Paperfold map change |
| Save the Pet Doodle | Escort/rescue pet | Pet unlock/progress |
| Light the Firefly Jar | Collect light motes under pressure | Dreamlight reward |
| Bind the Storythread | Connect three anchor points | Storythread reward |

---

## 40. Enemy and Boss Production Spec

### 40.1 Enemy Data Contract

```gdscript
class_name EnemyData
extends Resource

@export var id: String
@export var display_name: String
@export var family: String
@export var max_hp: float
@export var move_speed: float
@export var contact_damage: float
@export var radius: float
@export var xp_drop_table: DropTable
@export var pigment_drop_chance: float
@export var behavior_script_id: String
@export var attack_scene: PackedScene
@export var pagecraft_materials_created: Array[String]
@export var resist_tags: Array[String]
@export var weakness_tags: Array[String]
@export var is_elite_allowed: bool
@export var death_vfx_id: String
@export var damage_number_profile: String
```

### 40.2 Enemy Family Roles

| Family | Purpose |
|---|---|
| Swarm | High count, low HP, makes player feel powerful. |
| Bruiser | Slower, higher HP, creates body pressure. |
| Skirmisher | Moves diagonally or circles to break kiting. |
| Ranged | Forces movement with visible projectiles. |
| Corrupter | Places hostile Pagecraft marks. |
| Objective Hunter | Targets Page Event objects. |
| Elite | Clear telegraph, higher reward, short-term danger. |
| Boss Add | Supports boss phase without stealing focus. |

### 40.3 Boss Data Contract

```gdscript
class_name BossData
extends Resource

@export var id: String
@export var display_name: String
@export var chapter_id: String
@export var max_hp: float
@export var phase_thresholds: Array[float] = [0.75, 0.50, 0.25]
@export var attack_patterns: Array[BossAttackPattern]
@export var add_spawn_pools: Array[EnemyPoolEntry]
@export var arena_modifier_id: String
@export var enrage_time_seconds: int = 300
@export var reward_table: BossRewardTable
@export var victory_unlocks: Array[String]
@export var damage_number_profile: String
```

### 40.4 Boss Fight Rules

- Boss appears at 30:00.
- Boss entrance should clear or push normal spawn clutter briefly.
- Boss must have strong silhouette and visible shadow.
- Boss attacks should be telegraphed on top of Pagecraft marks.
- Boss damage numbers should be larger and more legible than normal enemy numbers.
- Boss phases can modify the page but should not erase the player's build fantasy.
- Strong builds can delete boss phases quickly; this is allowed and celebrated.

### 40.5 MVP Bosses

Each chapter should eventually have one boss. MVP needs one fully implemented boss.

| Chapter | Boss | Core Mechanics |
|---|---|---|
| Waxlight Castle | The Crownless Scribble | charges, crown marks, Blankness pools |
| Moonlit Watercolor Pond | The Soggy Moon Serpent | ripples, water lanes, slow zones |
| Buttonwood Forest | The Hollow Stag | thorn charges, minion trails |
| Cloud Garden | The Weeping Cloud Giant | lightning/moonbeam telegraphs |
| Pop-Up Kingdom | The Folded Dragon | folding walls, line breath |
| Torn Margin | The Margin Maw | tear spawns, corruption zones |
| Blank Page | The Unfinished Giant | adaptive attacks based on player materials |

---

## 41. Chapter and Map Construction Rules

### 41.1 Chapter Anatomy

Every chapter must define:

- finite playable bounds,
- visual page boundary,
- lighting preset,
- primary material interaction,
- environmental hazards,
- safe routing landmarks,
- Page Event anchor points,
- spawn gates,
- two map-unique enemies,
- one boss/finale,
- restoration unlocks,
- Sticker Album entries.

### 41.2 Map Size Targets

| Scope | Target Size |
|---|---:|
| MVP Chapter 1 | 120m × 90m |
| Later standard chapter | 120m × 90m to 160m × 120m |
| Boss arena comfort zone | at least 40m × 30m equivalent |
| Camera visible width | 28m-40m depending zoom |

### 41.3 Boundary Types

Use flavorful boundaries:

- torn page edge,
- painted forest wall,
- moonlit pond edge,
- folded paper cliff,
- ribbon barrier,
- blankness wall,
- pop-up castle wall,
- storybook margin.

Do not use invisible walls without visual explanation.

### 41.4 Page Event Anchor Rules

- Place anchors far enough apart to encourage movement.
- Avoid placing anchors in corners every time.
- Never spawn an event in an unreachable pocket.
- Ensure events are reachable within the 3-minute countdown.
- On Hard mode, routes can be more dangerous but still fair.

---

## 42. Pet Quest and Treat Economy Detail

### 42.1 Unlock Philosophy

Pets should be primarily unlocked through quests, rescue events, and chapter restoration.

Direct Treat purchase is a fallback path, not the intended first path.

### 42.2 Direct Purchase Costs

Direct purchase costs remain expensive enough to encourage quests, but not so expensive that missed pets feel impossible.

| Pet Rarity | Direct Treat Cost |
|---|---:|
| Common | 50 |
| Uncommon | 75 |
| Rare | 100 |
| Legendary / Endgame | 125 |

### 42.3 Pet Upgrade Costs

| Tier | Treat Cost | Meaning |
|---:|---:|---|
| 1 | 0 | Pet unlocked. |
| 2 | 10 | Basic improvement. |
| 3 | 25 | Secondary behavior. |
| 4 | 50 | Strong combat improvement. |
| 5 | 100 | Signature capstone. |

### 42.4 Pet Quest Examples

| Pet | Quest Unlock |
|---|---|
| Dog | Rescue during Patch the Torn Path or first hub restoration. |
| Cat | Complete 3 ambush events without taking lethal damage. |
| Cow | Restore a cozy pasture page in the Doodle Den. |
| Duck | Complete Moonlit Watercolor Pond event chain. |
| Frog | Trigger 50 puddle/splash combos. |
| Bunny | Complete dash challenge Page Event. |
| Snail | Slow 500 enemies with Pagecraft zones. |
| Raccoon | Find 5 hidden story chests. |
| Owl | Defeat a boss after completing all Page Events in a run. |
| Tiny Dragon | Endgame quest requiring multiple rescued pets. |

### 42.5 Pet Combat Rule

Every pet must attack.

Pet attacks can be:

- bite/pounce/charge,
- projectile,
- aura pulse,
- pickup-triggered burst,
- command burst,
- Pagecraft-triggered attack,
- boss-targeting special.

No pet may be purely cosmetic or purely a stat stick.

---

## 43. UI / UX Complete Screen List

### 43.1 Main Menus

Required screens:

- Title screen.
- Profile/save select.
- Storybook Hub.
- Chapter select.
- Difficulty select: Normal, Hard, Endless.
- Character select.
- Character mastery view.
- Pet select / Doodle Den.
- Weapon/item collection book.
- Sticker Album.
- Wonder Box permanent upgrades.
- Storybook Restoration map.
- Settings.
- Accessibility.
- Credits.

### 43.2 In-Run HUD

Required HUD elements:

- Player HP.
- Run timer.
- XP bar.
- Run level.
- Dash charges/recharge.
- Weapon slots, levels, and evolved state.
- Item slots and levels.
- Pet icon, tier, and special/attack feedback.
- Current Page Event timer and objective.
- Boss HP bar when active.
- Edge markers for objectives, boss, elites, and offscreen co-op allies.
- Damage numbers in world space.
- Pigment/Treat pickups as reward feedback.

### 43.3 Level-Up Draft UI

Each draft card must show:

- name,
- icon,
- category: weapon/item/evolution/modifier/heal,
- current level and next level,
- material/catalyst tags,
- concise effect text,
- whether it fills a new slot,
- evolution requirement hints when relevant.

### 43.4 Damage Number UX

Damage numbers are on by default.

Number hierarchy:

| Number Type | Treatment |
|---|---|
| Tiny tick | Smaller, quick fade, can stack/merge if accessibility mode enabled. |
| Normal hit | Readable pop, slight bounce. |
| Critical hit | Larger, brighter, stronger bounce. |
| Evolution hit | Oversized, dramatic, slight screen-space linger. |
| Boss chunk | Very large and centered near boss weakpoint. |
| Pet hit | Animal-accented pop style, still readable. |
| Page Event reward hit | Celebratory burst number. |

Late-game numbers should become huge and satisfying without hiding the player.

---

## 44. Art Production Pipeline

### 44.1 Production Style

Final look:

- Hand-drawn characters and enemies.
- Sprite3D/cards in 3D space.
- Physically lit paper diorama.
- Real shadows plus controlled contact shadows.
- Tactile material shaders.
- Storybook fantasy content, not school/classroom content.

### 44.2 Asset Source Strategy

MVP placeholder sources:

- Original sketches made quickly by the developer/team.
- Simple vector or raster doodles made in Krita/Procreate/Photoshop/Aseprite.
- Procedural placeholder meshes in Blender or Godot.
- CC0 placeholder sounds and textures only with license tracking.
- Kenney-style placeholder icons only when license-compatible.

Final asset direction:

- Original character and enemy art.
- Original page textures scanned or painted by the team.
- Original material splats/marks where possible.
- External assets only for placeholders unless license is clean and permanent.

### 44.3 Required Texture/Material Families

| Material | Required Maps / Inputs |
|---|---|
| Paper | albedo, normal/fiber, roughness variation |
| Waxlight | albedo, roughness, height/normal, edge mask |
| Color Bloom | albedo, wetness, drying mask, splatter mask |
| Dreamsap | transparent albedo, specular, thickness/edge mask |
| Star Sticker | albedo, normal/raised edge, roughness, optional holographic mask |
| Paperfold | albedo, edge fiber, normal, shadow support |
| Moonlight | emissive mask, soft edge, pulse curve |
| Blankness | dark albedo, crawling edge mask, matte roughness |

### 44.4 Sprite/Card Rules

- Characters should have strong silhouettes.
- Enemies must be readable under VFX.
- Bosses need larger proxy shadows.
- Sprite cards may billboard toward camera but should retain a grounded storybook cutout feel.
- Use slight vertical offset for visual layering, not gameplay collision.

---

## 45. Audio Direction and Implementation

### 45.1 Audio Pillars

Audio should feel:

- tactile,
- cozy,
- magical,
- playful,
- increasingly chaotic,
- readable during combat.

### 45.2 Sound Families

| System | Sound Palette |
|---|---|
| Waxlight | soft wax scrape, bright swish, rainbow shimmer |
| Color Bloom | wet splat, pigment bloom, soft pulse |
| Dreamsap | sticky stretch, glossy pop, elastic snap |
| Star Sticker | peel, slap, sparkle, glossy glint |
| Paperfold | fold, crinkle, tear, pop-up snap |
| Moonlight | chime, hum, soft beam, bell tone |
| Storythread | thread pull, twang, knot pop |
| Clean Page | airy wipe, dust shimmer, gentle bell |
| Blankness | muffled ink, low crawl, paper drain |
| Pets | distinctive cute attack sounds per pet |

### 45.3 Music Layers

Each chapter track should have layers:

- base calm loop,
- combat layer,
- Page Event layer,
- high-density layer,
- boss warning layer,
- boss combat layer,
- evolution sting,
- victory sting,
- failure sting.

### 45.4 Audio Priority

Highest priority sounds:

1. Player hurt/downed.
2. Dash used/ready.
3. Level-up.
4. Evolution.
5. Boss warning/attack telegraph.
6. Page Event success/failure.
7. Rare pickup.
8. Pet special attack.
9. Normal weapon hits.
10. Ambient props.

---

## 46. Godot Project Architecture

### 46.1 Folder Structure

```text
res://
├── autoload/
│   ├── GameState.gd
│   ├── SaveManager.gd
│   ├── RunManager.gd
│   ├── AudioManager.gd
│   ├── InputManager.gd
│   ├── EventBus.gd
│   └── NetworkManager.gd
├── core/
│   ├── damage/
│   ├── stats/
│   ├── pooling/
│   ├── targeting/
│   ├── resources/
│   └── utils/
├── gameplay/
│   ├── player/
│   ├── enemies/
│   ├── bosses/
│   ├── weapons/
│   ├── items/
│   ├── pets/
│   ├── pickups/
│   ├── pagecraft/
│   ├── director/
│   ├── events/
│   └── damage_numbers/
├── levels/
│   ├── chapters/
│   ├── props/
│   ├── lighting_presets/
│   └── navigation/
├── ui/
│   ├── hud/
│   ├── menus/
│   ├── drafts/
│   ├── hub/
│   └── accessibility/
├── art/
│   ├── characters/
│   ├── enemies/
│   ├── pets/
│   ├── weapons/
│   ├── materials/
│   └── ui/
├── audio/
│   ├── music/
│   ├── sfx/
│   └── snapshots/
├── data/
│   ├── characters/
│   ├── weapons/
│   ├── items/
│   ├── evolutions/
│   ├── pets/
│   ├── enemies/
│   ├── bosses/
│   ├── chapters/
│   ├── page_events/
│   ├── upgrades/
│   └── balance/
└── tests/
    ├── unit/
    ├── integration/
    └── stress/
```

### 46.2 Autoload Responsibilities

| Autoload | Responsibility |
|---|---|
| GameState | Global app state, current profile, current run metadata. |
| SaveManager | Save/load, version migration, profile data. |
| RunManager | Run start/end, timer, victory/failure state. |
| AudioManager | Music layers, SFX routing, snapshots. |
| InputManager | Input mapping and rebinding. |
| EventBus | Global signals for damage, pickup, level-up, evolution, events. |
| NetworkManager | Multiplayer abstraction, not gameplay logic. |

### 46.3 Resource-Driven Rule

All content should be defined as Resources where possible:

- characters,
- weapons,
- item passives,
- evolution paths,
- pet tiers,
- enemies,
- bosses,
- chapters,
- Page Events,
- permanent upgrades,
- audio metadata.

Do not hard-code content tables in player/enemy scripts.

---

## 47. Resource Schemas and Data Examples

### 47.1 WeaponData

```gdscript
class_name WeaponData
extends Resource

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var weapon_scene: PackedScene
@export var weapon_type: String
@export var material_tags: Array[String]
@export var page_mark_type: String
@export var compatible_evolution_tags: Array[String]
@export var max_level: int = 10
@export var level_upgrades: Array[WeaponLevelUpgrade]
@export var base_cooldown: float
@export var base_damage: float
@export var base_area: float
@export var target_rule: String
@export var damage_number_profile: String
```

### 47.2 PassiveItemData

```gdscript
class_name PassiveItemData
extends Resource

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var catalyst_tags: Array[String]
@export var max_level: int = 5
@export var level_upgrades: Array[PassiveLevelUpgrade]
@export var stat_modifiers: Array[StatModifier]
@export var special_effect_ids: Array[String]
```

### 47.3 EvolutionPathData

```gdscript
class_name EvolutionPathData
extends Resource

@export var id: String
@export var base_weapon_id: String
@export var required_weapon_level: int = 10
@export var required_item_level: int = 5
@export var required_catalyst_tag: String
@export var evolved_weapon_id: String
@export var display_name: String
@export_multiline var description: String
@export var evolution_vfx_scene: PackedScene
@export var evolution_sfx_id: String
@export var damage_number_profile: String
```

### 47.4 PetData

```gdscript
class_name PetData
extends Resource

@export var id: String
@export var display_name: String
@export var rarity: String
@export var direct_treat_cost: int
@export var tier_upgrade_costs: Array[int] = [0, 10, 25, 50, 100]
@export var unlock_quest_id: String
@export var visual_scene: PackedScene
@export var attack_scene: PackedScene
@export var tiers: Array[PetTierData]
@export var material_tags: Array[String]
@export var damage_number_profile: String
```

### 47.5 ChapterData

```gdscript
class_name ChapterData
extends Resource

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var level_scene: PackedScene
@export var bounds_size: Vector2
@export var lighting_preset: Resource
@export var primary_materials: Array[String]
@export var enemy_pool: Array[EnemyPoolEntry]
@export var map_unique_enemies: Array[String]
@export var boss_id: String
@export var page_event_pool: Array[String]
@export var restoration_branch_id: String
@export var sticker_album_entries: Array[String]
```

### 47.6 DamageEvent

```gdscript
class_name DamageEvent
extends RefCounted

var source_id: String
var source_type: String
var attacker: Node
var target: Node
var amount: float
var is_critical: bool
var is_evolution: bool
var is_pet_damage: bool
var material_tags: Array[String]
var world_position: Vector3
var damage_number_profile: String
```

Every damage event should emit a signal consumed by the damage-number pool.

---

## 48. Multiplayer Architecture

### 48.1 Multiplayer Priority

Build order:

1. Solo offline.
2. Local/LAN debug co-op.
3. Steam co-op.

Do not design core gameplay scripts around a specific Steam plugin.

### 48.2 Authority Model

Use host-authoritative simulation.

Host owns:

- enemy spawning,
- enemy AI,
- boss AI,
- Page Events,
- Pagecraft authoritative state,
- pickups,
- reward generation,
- damage resolution,
- run timer,
- victory/failure.

Clients own:

- input prediction for their player,
- local camera,
- local UI,
- local VFX interpolation,
- local audio.

### 48.3 Replication Units

Replicate events, not every visual mark.

Replicate:

- player input/state snapshots,
- weapon fire events if needed,
- damage events or summarized damage,
- enemy spawn/despawn,
- enemy important state,
- Pagecraft deposit/activation events,
- pickup spawn/collect,
- Page Event progress,
- boss phase/attack selection,
- level-up draft choices,
- pet attack events.

Do not replicate every individual damage number. Clients can generate numbers from replicated damage events.

### 48.4 Co-op Level-Up Handling

Online co-op should not hard-pause the whole game by default.

Options:

- personal draft window with slowed local input,
- short global slow-motion if all players are choosing,
- host-configurable pause mode for casual co-op.

### 48.5 Co-op Scaling

Co-op should scale:

- enemy spawn budget,
- boss HP,
- Page Event objective requirements,
- elite frequency,
- reward distribution.

Co-op should also add synergy rewards:

- combo damage for multiple material tags,
- shared Page Event reward picks,
- pet assist bonuses,
- revive mechanics.

---

## 49. Performance Budgets, Pooling, and Debug Tools

### 49.1 Target Performance

| Target | Budget |
|---|---:|
| Desktop 1080p | 60 FPS |
| Steam Deck target | 40-60 FPS |
| Active enemies MVP | 300+ stress target |
| Active damage numbers | 500+ pooled visual entries |
| Active Pagecraft chunks | dirty-chunk updated only |
| Active projectiles/VFX | pooled, capped by category |

### 49.2 Pool These Objects

Always pool:

- enemies,
- projectiles,
- pickups,
- damage numbers,
- pet attacks,
- VFX bursts,
- decals/mark visuals,
- page event indicators,
- boss telegraphs.

### 49.3 Pagecraft Performance Rules

- Do not create per-cell Node3D objects.
- Use arrays/grids for simulation.
- Use dirty chunks for visual updates.
- Use batched mesh overlays, decals, or shader textures for visuals.
- Decay or compress old marks if performance drops.
- Visual clutter reduction may merge damage ticks, but default mode should show all meaningful damage.

### 49.4 Required Debug Panels

Create debug panels for:

- FPS/frame time,
- active enemies,
- active projectiles,
- active damage numbers,
- object pool usage,
- spawn budget,
- Pagecraft chunk count,
- dirty chunks,
- material sample under player,
- dash path sample,
- Page Event state,
- boss phase,
- network ping/desync checks later.

---

## 50. Balancing Framework

### 50.1 Balance Goals

Pagebound should be generous but not mindless.

Balance should make:

- early game approachable,
- mid game build-defining,
- late game explosive,
- boss fight threatening but shred-able by strong builds,
- pets visibly useful,
- Page Events worth the travel risk.

### 50.2 Balance Axes

Tune the game along these axes:

- enemy count,
- enemy HP,
- enemy speed,
- enemy contact damage,
- elite frequency,
- XP drop rate,
- level-up pacing,
- weapon cooldown,
- weapon damage,
- Pagecraft duration,
- mark density,
- item scaling,
- pet damage/frequency,
- evolution availability,
- boss HP and phase pressure.

### 50.3 Power-Fantasy Guideline

If a build has:

- 5 weapons,
- 5 items,
- at least one evolution,
- a tier 3+ pet,
- and completed 2+ Page Events,

then by 20-25 minutes it should look extremely strong.

Do not make the boss immune to that feeling. Let strong builds chunk the boss.

### 50.4 Failure Sources

Fair failure should come from:

- poor routing,
- failed Page Events,
- weak draft choices,
- ignoring boss telegraphs,
- getting boxed into finite-map edges,
- greedily chasing pickups at the wrong time,
- not using dash/Pagecraft interactions.

Unfair failure includes:

- invisible hazards,
- enemies spawning on the player,
- props blocking view,
- damage numbers hiding danger,
- boss attacks without telegraphs,
- long periods of underpowered play.

---

## 51. Tutorialization and First-Time User Experience

### 51.1 Tutorial Philosophy

Teach through play, not a long tutorial.

The first chapter should naturally introduce:

- movement,
- dash,
- auto-attacks,
- XP and level-ups,
- weapons vs items,
- Pagecraft marks,
- dash activation,
- pets,
- Page Events,
- boss finale,
- meta progression.

### 51.2 First-Run Tutorial Beats

| Beat | Teaching Goal |
|---|---|
| Spawn | Move with WASD / stick. |
| First wave | Weapons auto-fire. |
| First hit | Damage numbers show impact. |
| First XP | Collect Color Motes to level. |
| First draft | Choose 1 of 3 upgrades. |
| First mark | Attacks alter the page. |
| First dash prompt | Dash through a mark to activate it. |
| 5:00 event | Page Events have timers and rewards. |
| First pet cue | Pets attack automatically. |
| Boss warning | Boss appears at 30:00. |
| Victory | Spend Pigment/Treats in hub. |

### 51.3 Hint Style

Use short, storybook-style hints:

- “Dash through your own color to wake it up.”
- “This page remembers your marks.”
- “A pet doodle is nearby. Save it before the timer runs out.”
- “A level 10 weapon and a level 5 matching catalyst can evolve.”
- “The boss arrives at 30:00.”

---

## 52. Story, World, and Hub Narrative Detail

### 52.1 Story Premise

A magical storybook is being consumed by Blankness. The drawings inside the book are losing color, memory, and shape. Tiny doodle heroes wake up inside the pages and fight to restore the story before it disappears.

The story should be light, emotional, and flexible. It should not overwhelm the roguelite loop.

### 52.2 Story Tone

Tone:

- childlike wonder,
- cozy mystery,
- magical danger,
- gentle humor,
- triumphant power fantasy.

Avoid:

- school assignment framing,
- heavy lore dumps,
- grimdark apocalypse,
- realistic violence.

### 52.3 Hub Structure

The hub is a partially restored storybook.

Hub areas:

- Chapter spread / map select.
- Wonder Box permanent upgrades.
- Doodle Den pet habitat.
- Character pages / mastery tracks.
- Sticker Album.
- Art supply / magic collection shelf.
- Restoration tree.

### 52.4 Narrative Progression

Each chapter restored should:

- add color to the hub,
- unlock a new page spread,
- reveal a pet or character clue,
- add a new material/combat idea,
- unlock new Sticker Album entries.

---

## 53. MVP Content Matrix

### 53.1 MVP Must Include

| Category | MVP Count / Requirement |
|---|---:|
| Shared weapons | 20 fully data-defined, placeholder visuals acceptable |
| Passive items | 20 fully data-defined |
| Evolution paths | 40 data-defined, at least 8 fully polished early |
| Characters | 5 playable minimum recommended for first full MVP, all planned listed |
| Pets | 5 playable minimum recommended, all planned listed |
| Chapters | 1 complete vertical slice, others data/planning ready |
| Page Events | 10 implemented or placeholder-functional |
| Bosses | 1 fully implemented |
| Map-unique enemies | 2 for MVP chapter |
| Standard enemies | 8-12 shared enemies |
| Damage numbers | fully implemented and pooled |
| Pagecraft | at least Waxlight, Color Bloom, Dreamsap, Star Sticker, Clean Page MVP support |
| Meta progression | Pigment, Treats, Wonder Box, Doodle Den, mastery save data |
| Save/load | profile persistence with versioning |

### 53.2 Vertical Slice Definition

A true vertical slice is not just a combat test. It must include:

- chapter select,
- character select,
- pet select,
- a full 30:00 boss run target,
- 5 timed Page Events,
- at least one evolution,
- victory screen,
- hub return,
- spendable Pigment,
- at least one pet quest,
- readable 2.5D lighting and shadows.

---

## 54. Development Milestones

### 54.1 Milestone 0 — Project Skeleton

Deliverables:

- Godot 4.6.x project.
- 3D root scene.
- Camera3D.
- DirectionalLight3D.
- WorldEnvironment.
- placeholder finite page mesh.
- player movement on X/Z.
- dash.
- debug overlay.

Acceptance:

- Player moves and dashes on a lit page at stable FPS.

### 54.2 Milestone 1 — Combat Loop

Deliverables:

- enemy spawning,
- basic enemy AI,
- health/damage system,
- XP drops,
- level-up drafts,
- damage numbers,
- 5 weapon prototypes,
- 5 item prototypes.

Acceptance:

- Player can survive a 5-minute test and level up multiple times.

### 54.3 Milestone 2 — Pagecraft MVP

Deliverables:

- Pagecraft grid,
- Waxlight deposits,
- Dreamsap deposits,
- Color Bloom deposits,
- dash sampling,
- material activation,
- debug visualization.

Acceptance:

- Attacks visibly alter the page and dash activates marks.

### 54.4 Milestone 3 — Full MVP Weapon/Item Data

Deliverables:

- all 20 weapons implemented functionally,
- all 23 items implemented functionally,
- 40 evolution paths data-defined,
- at least 8 evolved weapons implemented,
- draft weighting.

Acceptance:

- Multiple complete builds are possible.

### 54.5 Milestone 4 — Full Run Structure

Deliverables:

- 30:00 boss spawn,
- level 50 target by boss start,
- 5 Page Events at 5-minute marks before boss,
- run rewards,
- victory/failure screen.

Acceptance:

- A full standard run can be completed.

### 54.6 Milestone 5 — Meta and Hub

Deliverables:

- Storybook Hub,
- Wonder Box,
- Doodle Den,
- character mastery,
- pet tiers,
- Pigment/Treat economy,
- save/load.

Acceptance:

- Run rewards persist and can unlock/upgraded content.

### 54.7 Milestone 6 — Visual/Audio Vertical Slice

Deliverables:

- polished Chapter 1 lighting,
- sprite/card art pass,
- material shaders,
- SFX pass,
- music layers,
- UI polish.

Acceptance:

- The slice communicates the intended screenshot-inspired 2.5D lighting style.

### 54.8 Milestone 7 — Co-op Prototype

Deliverables:

- host-authoritative local/LAN build,
- player replication,
- enemy/damage/pickup replication,
- Pagecraft event replication,
- co-op reward flow.

Acceptance:

- Two players can complete a short test run without desync-critical failures.

---

## 55. Codex Task Templates and AGENTS.md

### 55.1 Feature Task Template

```markdown
Goal:
Implement [feature name] for Pagebound.

Context:
Use PAGEBOUND_CODEX_GDD_v1_5.md as the canonical spec.
This is a Godot 4.6.x 2.5D game using the 3D runtime.
Gameplay occurs on X/Z; Y is visual height.

Requirements:
- Keep implementation data-driven with Resources.
- Do not hard-code content into Player.gd.
- Use typed GDScript.
- Add debug visualization if gameplay-facing.
- Pool runtime objects when many instances are expected.

Files likely involved:
- res://gameplay/[system]/
- res://data/[content]/
- res://core/[shared]/
- res://ui/[if needed]/

Acceptance Criteria:
- [specific player-visible result]
- [debug/testing result]
- [performance/readability result]
```

### 55.2 Bug Task Template

```markdown
Problem:
[Observed behavior]

Expected:
[Expected behavior from GDD]

Reproduction:
1. Start run with [character/build].
2. Reach [state].
3. Observe [bug].

Investigation Hints:
- Check relevant Resource data.
- Check EventBus signals.
- Check object pool reuse state.
- Check Pagecraft chunk dirty updates.

Acceptance Criteria:
- Bug no longer occurs.
- No regression to core loop.
- Debug overlay confirms expected state.
```

### 55.3 Recommended AGENTS.md

```markdown
# Pagebound Agent Instructions

## Project
Pagebound is a Godot 4.6.x 2.5D storybook action roguelite.
Use PAGEBOUND_CODEX_GDD_v1_5.md as the canonical design spec.

## Coding Standards
- Use typed GDScript.
- Prefer composition over inheritance.
- Keep Player.gd, Enemy.gd, and RunManager.gd small.
- Put content in Resources, not hard-coded dictionaries.
- Name files and classes after the GDD terms.

## Architecture
- Gameplay is 3D runtime, X/Z plane.
- Y is visual height.
- Use Resources for weapons, items, pets, enemies, bosses, chapters, and events.
- Pool high-count objects.
- Do not create one node per Pagecraft cell.

## Godot
- Target Godot 4.6.x.
- Avoid beta/dev-only APIs.
- Use CharacterBody3D for player/enemy movement unless a task says otherwise.
- Keep 2D art as Sprite3D/textured quads in the 3D scene.

## Testing
- Add debug panels for new systems.
- Include acceptance criteria in commits/PR notes.
- Stress test enemy count, Pagecraft marks, and damage numbers.

## Multiplayer
- Do not add transport-specific code to gameplay systems.
- Use NetworkManager/event replication abstractions.
- Host owns enemies, drops, Page Events, boss state, and Pagecraft authority.
```

---

## 56. Concrete First Codex Prompts

### 56.1 Initial Project Architecture Prompt

```markdown
Create the initial Godot 4.6.x project architecture for Pagebound.

Use PAGEBOUND_CODEX_GDD_v1_5.md.

Important:
- This is a 2.5D game using Godot's 3D runtime.
- Do not create a pure Node2D/CanvasItem gameplay scene.
- Gameplay movement is planar on X/Z.
- Y is visual height.
- Use Camera3D, DirectionalLight3D, and WorldEnvironment.

Implement:
1. Folder structure from the technical architecture section.
2. Main.tscn with WorldRoot, LevelRoot, PlayerRoot, CameraRig, LightingRoot, UIRoot.
3. Placeholder finite paper mesh arena.
4. Player CharacterBody3D with movement and dash.
5. Camera follow.
6. Basic debug overlay showing FPS, player position, dash charges/recharge.

Acceptance:
- Project runs in Godot 4.6.x.
- Player moves on X/Z plane.
- Dash works and has charge recharge.
- Camera follows player.
- Directional light casts visible shadows.
```

### 56.2 Pagecraft MVP Prompt

```markdown
Implement the first Pagecraft MVP for Pagebound.

Use PAGEBOUND_CODEX_GDD_v1_5.md.

Implement:
1. PagecraftGrid resource/runtime system with chunked cells.
2. Material layers for Waxlight, Dreamsap, and Color Bloom.
3. deposit_circle, deposit_line, sample_materials, sample_line, activate_dash_path.
4. Debug overlay that visualizes material cells above the 3D paper mesh.
5. Placeholder Waxlight projectile weapon that deposits Waxlight at impact.
6. Placeholder Dreamsap puddle weapon that slows enemies.
7. Dash through Waxlight triggers line damage.
8. Dash through Dreamsap creates a sticky strand line.
9. Every Pagecraft damage event emits a damage_dealt signal and produces a pooled damage number.

Acceptance:
- Marks are visible in debug overlay.
- Enemy speed changes in Dreamsap.
- Dash through Waxlight damages enemies.
- Dash through Dreamsap creates a visible strand.
- Damage numbers appear for every Pagecraft damage tick.
- No per-cell Node3D objects are created.
```

---

## 57. Risk Register, Quality Bar, and Open Questions

### 57.1 Risk Register

| Risk | Severity | Mitigation |
|---|---:|---|
| Pagecraft performance too slow | High | chunked arrays, dirty chunks, low-frequency updates, profile early |
| Visual clutter unreadable | High | hierarchy, outlines, reduced clutter mode, strong silhouettes |
| Damage numbers tank performance | High | pooling, batching/merging options, cap visual-only entries |
| Co-op desync | High | host authority, event replication, checksums |
| Scope creep | High | vertical slice first, data hooks for later content |
| Art production burden | High | placeholders first, original key assets second, reusable material shaders |
| Theme drift back to school supplies | Medium | enforce storybook fantasy guardrail |
| Evolution system too confusing | Medium | tag hints, UI compatibility previews |
| Pets overcomplicate balance | Medium | pet power budget, strong but readable attacks |
| Permanent upgrades trivialize game | Medium | favor flexibility/convenience over raw damage |
| Steam networking friction | Medium | LAN/ENet prototype first, abstract transport |
| Colorblind readability | Medium | shape/texture coding, accessibility settings |

### 57.2 Quality Bar

Minimum feel requirements:

- Dash feels responsive.
- Weapon hits have clear impact.
- Enemy contact is readable.
- Damage numbers are satisfying.
- Pagecraft marks are visible and meaningful.
- Page Events are worth chasing.
- Pets feel strong.
- Evolutions feel like major power spikes.
- Boss attacks are fair and visible.
- 2.5D lighting enhances, not harms, readability.

### 57.3 Open Design Questions

These should be answered through prototypes:

1. How long should Pagecraft marks persist before decay?
2. Should dash activation trigger during dash, at dash end, or both by material?
3. How many active enemies are readable with full damage numbers?
4. How much camera perspective is too much for fair collision?
5. Should co-op XP be global or personal? Current recommendation: global.
6. Should online level-up pause everyone? Current recommendation: no hard pause.
7. How many evolutions should a normal successful run usually reach?
8. How large can Page Takeover attacks be before they obscure boss telegraphs?
9. How strong can pets be before they feel mandatory? Current answer: strong is acceptable, but each pet should support a different playstyle.
10. How much direct pet purchase should be used versus quest unlocking? Current answer: quest unlocks are primary; Treat purchase is fallback.

---

## 58. External Reference Links for Developers

Use these as implementation reference links. Verify exact class APIs against installed Godot 4.6.x docs.

- Godot official site: https://godotengine.org/
- Godot download archive: https://godotengine.org/download/archive/
- Godot high-level multiplayer docs: https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html
- Godot 3D lights and shadows docs: https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html
- Godot 3D environment and post-processing docs: https://docs.godotengine.org/en/stable/tutorials/3d/environment_and_post_processing.html
- Godot spatial shader docs: https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html
- Godot Decal class docs: https://docs.godotengine.org/en/stable/classes/class_decal.html
- Godot Sprite3D class docs: https://docs.godotengine.org/en/stable/classes/class_sprite3d.html
- Godot CharacterBody3D class docs: https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html
- Steam Multiplayer Peer for Godot 4: https://github.com/expressobits/steam-multiplayer-peer
- Godot Asset Library Steam Multiplayer Peer page: https://godotengine.org/asset-library/asset/2258
- Kenney placeholder assets: https://kenney.nl/assets
- Freesound placeholder audio: https://freesound.org/
- OpenGameArt placeholder assets: https://opengameart.org/

---

## 52. Naming Glossary

Use these names consistently.

| Concept | Name |
|---|---|
| Game | Pagebound |
| Core battlefield mechanic | Pagecraft |
| Main currency | Pigment |
| Pet currency | Treats |
| Collection system | Sticker Album |
| Pet hub | Doodle Den |
| Permanent upgrade system | Wonder Box |
| Map progression | Storybook Chapters |
| Timed objectives | Page Events |
| Sticky material | Dreamsap |
| Cleansing material | Clean Page |
| Crayon-like material | Waxlight |
| Paint-like material | Color Bloom |
| Line/ribbon material | Storythread |
| Light material | Moonlight |
| Paper material | Paperfold |
| Enemy corruption | Blankness |

---

## 53. Design Guardrails

### Always Do

- Make the player feel powerful.
- Keep the page physically present.
- Use childlike fantasy, not school theming.
- Give pets real attacks.
- Use visible damage numbers.
- Make Page Events worth chasing.
- Let strong builds kill the boss early.
- Keep progression tracks in 5/10 structures.
- Maintain readability even with high effects.

### Never Do

- Do not make cosmetics the only character mastery reward.
- Do not make pets minor passive stats only.
- Do not turn the game into a classroom/school-supply theme.
- Do not make maps infinite.
- Do not hide damage numbers by default.
- Do not start the boss before the player can complete a core build.
- Do not make Page Events untimed.
- Do not hard-code content into player scripts.
- Do not render every page mark as an individual physics object.

---

## 54. Final Creative Summary

Pagebound is a magical storybook power fantasy.

The player is a tiny doodle hero on a real, physically lit page. Living scribbles, blankness, torn-page monsters, and corrupted story creatures flood the world. The player fights back with glowing waxlight comets, sticker stars, moonbeams, paper thorns, dream sap, color blooms, ribbons, pets, and huge cascading damage numbers.

The page is finite, physical, and alive. Every attack leaves marks. Every dash can reshape those marks. Every pet attacks. Every run builds toward a 25-minute boss finale, where a strong build can end the story early by overwhelming the boss with color, companions, and chaos.

The game should feel cute, magical, tactile, readable, and absurdly powerful.

The core feeling is:

> The story is almost gone, but I am strong enough to redraw the ending.
