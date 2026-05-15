# MVP Weapon Candidate Pool

> Status: Draft candidate archive  
> Owner: Design  
> Source beads: pagebound-5ip, pagebound-j92  
> Last updated: 2026-05-12

## Purpose

This document owns the active MVP weapon candidate details after the upgrade-model revision. The root GDD references this sheet for roster rows, weapon milestones, upgrade pools, catalyst assignments, and base numeric weapon tuning.

Design source consulted: `PAGEBOUND_CODEX_GDD_v1_5.md` sections 11-13; `design/gdd/weapons-and-auto-attacks.md`; `design/gdd/xp-leveling-and-upgrade-drafts.md`; `design/gdd/passive-items-and-drafts.md`; `design/gdd/evolution-system.md`; `design/gdd/pagecraft-materials-and-grid.md`; `design/gdd/damage-and-status-model.md`; `design/gdd/resource-data-schemas.md`.

## Active Pool Summary

- Active weapon candidates: 30
- Removed candidates retained in appendix: 3
- Active catalyst families: 10
- Each active weapon has fixed L1, L5, and L10 milestones.
- Non-milestone weapon levels grant one selected card from that weapon's upgrade pool.
- L5 and L10 grant their fixed feature plus one selected upgrade card.
- Final roster selection should preserve at least 5 close-range or melee-style weapons and at least 5 distinct DoT weapons.

## Catalyst Families

Catalysts are broad item/evolution families. Each active weapon has exactly two catalyst families. The 30 active candidates are balanced so each catalyst appears on 6 weapons.

| Catalyst | Active Weapon Count | Family Use |
|---|---:|---|
| Firelight | 6 | Heat, ignition, solar force, warm light |
| Moon | 6 | Lunar arcs, reflection, tides, shadow |
| Star | 6 | Star nodes, shards, sky objects, sparks |
| Dream | 6 | Dream haze, memory, gates, reverie |
| Thread | 6 | Lines, rails, seams, woven paths |
| Bloom | 6 | Growth, briars, seeds, clouds, living marks |
| Water | 6 | Washes, tides, sap flow, wells, wake |
| Light | 6 | Cleanse, beacons, afterglow, radiant marks |
| Echo | 6 | Resonance, bells, repeated pulses, memory replay |
| Wonder | 6 | Grand objects, parade, wells, castles, rails |

## Upgrade Model

Weapon levels still run from 1 to 10, but level is upgrade-count progress only. Level never grants hidden baseline damage, cadence, size, or range.

- L1: base weapon behavior only.
- L2-L4: one card from the weapon's upgrade pool.
- L5: fixed feature plus one card from the weapon's upgrade pool.
- L6-L9: one card from the weapon's upgrade pool.
- L10: capstone feature plus one card from the weapon's upgrade pool.

Weapon resources expose one editable base stat set: base damage, base cooldown, base mark/effect radius, and base targeting/placement range. Runtime stats start from those values and change only through selected upgrade cards, passive items, evolutions, or explicit authored effects.

Base cadence bands:

| Band | Interval | Use |
|---|---:|---|
| Fast | 0.6-0.9s | Small hits, close pulses, trails, repeat pressure |
| Medium | 1.0-1.4s | Mainline projectiles, beams, waves, traps |
| Slow | 1.5-2.2s | Strong zones, larger constructs, heavy bursts |
| Heavy Construct | 2.5-4.0s | Big-object attacks and page-crossing events |

Upgrade stat channels:

| Stat | Rarity Values | Meaning |
|---|---|---|
| damage | Common +10%, Uncommon +20%, Rare +35%, Epic +50%, Legendary +75% | Offensive damage for the scoped effect |
| size | Common +10%, Uncommon +20%, Rare +35%, Epic +50%, Legendary +75% | Radius, width, arc, splash, footprint |
| duration | Common +10%, Uncommon +20%, Rare +35%, Epic +50%, Legendary +75% | How long marks, zones, constructs, or effects remain |
| range | Common +10%, Uncommon +20%, Rare +35%, Epic +50%, Legendary +75% | Target, placement, link, reach, travel, or homing distance |
| cadence | Common +10%, Uncommon +20%, Rare +35%, Epic +50%, Legendary +75% | How frequently the scoped effect acts |
| proc_chance | +10/+20/+35/+50/+75% chance | Additive chance for an optional special effect, capped per row if needed |
| control_strength | Common +10%, Uncommon +20%, Rare +35%, Epic +50%, Legendary +75% | Slow, pull, push, snare, or knockback strength |
| effect_count | Common +1, Uncommon +1, Rare +2, Epic +2, Legendary +3 | Extra projectiles, pulses, echoes, links, sparks, or repeated effects |
| active_cap | Common +1, Uncommon +1, Rare +2, Epic +2, Legendary +3 | Extra living wells, gates, sentries, summons, zones, or constructs |

Dash and Pagecraft upgrades use scope plus normal stat. Example: `Scope: dash payoff`, `Stat: damage`. There is no separate dash or Pagecraft stat channel.

## Crit Policy

- Crit chance is global, not a weapon upgrade-pool stat.
- Crit chance and crit damage come from items and evolutions only.
- Player-owned damage sources can crit: weapons, dash payoffs, Pagecraft marks, evolutions, pets, and summons.
- Global crit chance cap: 75%.
- Default crit multiplier: 2x.
- Final crit multiplier cap: 4x.
- All player-owned damage can crit.
- Full crit popups are allowed by design, including high-frequency damage.

## 1. Waxlight Comet

Status: Strong Candidate  
Role: Reliable starter lane-painter  
Weapon type: Homing projectile and trail  
Base cadence band: Medium  
Catalyst tags: Firelight, Light  
Gameplay purpose: Gives new runs a readable auto-fire weapon that paints wax roads through enemy flow.  
Pagecraft verb: Seals glowing Waxlight trails and impact splats onto the page.  
Dash payoff: Dashing across a wax trail ignites a straight slash along the trail.  
Range intent: Medium homing range; trail length grows before target range does.

| Level | Fixed Milestone |
|---:|---|
| L1 | Fires 1 glowing comet toward the nearest enemy position; comet leaves a Waxlight trail. |
| L5 | Impact forks into Waxlight sparks that travel along nearby enemy flow; also grants one random upgrade card. |
| L10 | Capstone: large comets can carve a wide Waxlight highway across the visible page; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Comet Hit | base projectile | damage | Scales direct comet hit. |
| Impact Splat | impact mark | size | Scales splat footprint. |
| Wax Trail | Pagecraft trail | duration | Trails remain longer. |
| Trail Width | Pagecraft trail | size | Trails are wider and easier to dash across. |
| Trail Burn | Pagecraft trail | damage | Scales crossing damage. |
| Spark Release | impact proc | proc_chance | Chance to release extra sparks; cap 100%. |
| Spark Count | impact proc | effect_count | Adds more sparks. |
| Spark Reach | impact proc | range | Sparks can travel farther from impact. |
| Wax Slow | layered trail | control_strength | Layered trails slow harder. |
| Dash Ignition | dash payoff | damage | Scales dash-triggered trail slash. |

## 2. Star Sticker Swarm

Status: Needs Review  
Role: Ricochet-anchor network  
Weapon type: Orbit, attach, ricochet  
Base cadence band: Medium  
Catalyst tags: Star, Moon  
Gameplay purpose: Builds clustered damage through placed glossy star anchors instead of raw projectile count.  
Pagecraft verb: Sticks raised star nodes to enemies and page cells.  
Dash payoff: Dashing near star nodes launches them as bank-shot projectiles.  
Range intent: Short orbit range at first; ricochet reach expands with levels.

| Level | Fixed Milestone |
|---:|---|
| L1 | Creates orbiting stars that strike nearby enemies and may leave small star nodes. |
| L5 | Star nodes ricochet damage to nearby star nodes; also grants one random upgrade card. |
| L10 | Capstone: star-node constellations can rain extra ricochets around the player; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Star Strike | orbit star | damage | Scales star contact hit. |
| Orbit Reach | orbit star | range | Stars reach farther from player. |
| Star Node | Pagecraft node | duration | Nodes remain longer. |
| Node Pop | Pagecraft node | size | Node pop footprint increases. |
| Ricochet Hit | node ricochet | damage | Scales ricochet hit. |
| Ricochet Reach | node ricochet | range | Ricochets can find farther nodes. |
| Extra Stars | orbit star | effect_count | Adds orbiting stars. |
| Node Spawn | star hit proc | proc_chance | Chance to leave node; cap 75%. |
| Dash Launch | dash payoff | damage | Scales launched node damage. |

## 3. Dreamsap Glob

Status: Strong Candidate  
Role: Snare and pack compression  
Weapon type: Puddle and area control  
Base cadence band: Slow  
Catalyst tags: Dream, Water  
Gameplay purpose: Slows enemy flow, compresses crowds, and gives other weapons time to work.  
Pagecraft verb: Pools sticky Dreamsap that merges into larger snare patches.  
Dash payoff: Dashing through sap stretches it into a sticky line between dash start and end.  
Range intent: Short-to-medium placement range near dense enemy flow.

| Level | Fixed Milestone |
|---:|---|
| L1 | Drops 1 Dreamsap glob near dense enemy flow; puddle slows and damages. |
| L5 | Overlapping puddles merge into a larger Dreamsap pool; also grants one random upgrade card. |
| L10 | Capstone: merged pools pulse in waves that hold major lanes; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Sap Damage | puddle | damage | Scales puddle damage. |
| Sap Pool | puddle | size | Puddles cover more ground. |
| Sap Hold | puddle | duration | Puddles remain longer. |
| Throw Reach | placement | range | Globs can place farther away. |
| Glob Count | cast | effect_count | Adds more globs per cast. |
| Sap Slow | puddle | control_strength | Slow gets stronger. |
| Snare Pulse | merged pool | control_strength | Periodic snare gets stronger. |
| Dash Snare | dash payoff | damage | Scales stretched line damage. |
| Active Pools | puddle network | active_cap | Allows more living pools. |

## 4. Color Bloom

Status: Needs Review  
Role: Kill-chain propagation  
Weapon type: Burst and growing zone  
Base cadence band: Medium  
Catalyst tags: Bloom, Wonder  
Gameplay purpose: Rewards dense fights by spreading bloom zones when enemies fall inside them.  
Pagecraft verb: Seeds color blooms that pollinate nearby page cells and marks.  
Dash payoff: Dashing through a bloom splashes pollen outward to start smaller blooms.  
Range intent: Medium placement range around dense enemy positions.

| Level | Fixed Milestone |
|---:|---|
| L1 | Creates a small Color Bloom under dense enemy flow. |
| L5 | Enemy defeats inside a bloom seed smaller blooms nearby; also grants one random upgrade card. |
| L10 | Capstone: bloom chains can propagate across clustered enemy flow; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Bloom Burst | bloom | damage | Scales initial burst. |
| Bloom Footprint | bloom | size | Blooms cover more space. |
| Bloom Hold | bloom | duration | Blooms remain longer. |
| Bloom Reach | placement | range | Blooms can appear farther away. |
| Pollen Chance | defeat proc | proc_chance | Chance to seed bloom on defeat; cap 75%. |
| Pollen Count | defeat proc | effect_count | Adds more small blooms. |
| Bloom Spread | propagation | range | Seeded blooms can spread farther. |
| Dash Splash | dash payoff | size | Dash splash covers more space. |
| Bloom Field | bloom network | active_cap | Allows more living bloom zones. |

## 5. Moonbeam

Status: Strong Candidate  
Role: Precision line and lens beam  
Weapon type: Piercing line and beam  
Base cadence band: Medium  
Catalyst tags: Moon, Light  
Gameplay purpose: Gives builds a deliberate long-line damage pattern that rewards positioning.  
Pagecraft verb: Draws lunar sight-lines and lens streaks onto the page.  
Dash payoff: Dashing across a moon-line fires a reflected beam along the line.  
Range intent: Long linear range; narrow width until late upgrades.

| Level | Fixed Milestone |
|---:|---|
| L1 | Draws 1 piercing Moonbeam line in the nearest enemy-flow direction. |
| L5 | Enemies hit by the beam become Moonlit and can reflect a beam fragment; also grants one random upgrade card. |
| L10 | Capstone: rotating moon scripts sweep huge arcs around the player; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Beam Cut | main beam | damage | Scales beam damage. |
| Beam Length | main beam | range | Beam reaches farther. |
| Beam Width | main beam | size | Beam is wider. |
| Moon-Line | Pagecraft line | duration | Lines linger longer. |
| Moonlit Fragment | Moonlit effect | damage | Reflected fragments hit harder. |
| Fragment Reach | Moonlit effect | range | Reflected fragments reach farther. |
| Fork Chance | Moonlit effect | proc_chance | Chance to fork from Moonlit enemies; cap 75%. |
| Script Sweep | capstone | size | Rotating script arcs grow. |
| Dash Reflection | dash payoff | damage | Reflected dash beam hits harder. |

## 6. Briar Fold

Status: Strong Candidate  
Role: Offensive line trap hybrid  
Weapon type: Armed trap line and terrain burst  
Base cadence band: Medium  
Catalyst tags: Bloom, Thread  
Gameplay purpose: Prepares folded-briar traps that impale enemies when crossed.  
Pagecraft verb: Folds thorny briar seams into the page.  
Dash payoff: Dashing along a seam primes it instantly and increases its next eruption.  
Range intent: Medium placement range; seam length grows with range upgrades.

| Level | Fixed Milestone |
|---:|---|
| L1 | Places 1 folded briar seam near enemy flow; seam erupts when crossed. |
| L5 | Crossed seams root enemies at the center of the eruption; also grants one random upgrade card. |
| L10 | Capstone: seam eruptions can create a temporary briar maze pattern; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Eruption Hit | seam eruption | damage | Scales eruption damage. |
| Seam Length | armed seam | range | Seams extend farther. |
| Eruption Width | seam eruption | size | Eruption footprint grows. |
| Armed Hold | armed seam | duration | Seams wait longer before fading. |
| Seam Count | cast | effect_count | Adds more seams. |
| Root Grip | seam root | control_strength | Root effect is stronger. |
| Chain Eruption | seam proc | proc_chance | Chance nearby seams erupt too; cap 50%. |
| Dash Prime | dash payoff | damage | Dash-primed eruption hits harder. |
| Active Seams | armed seam | active_cap | Allows more living seams. |

## 7. Dawn Halo

Status: Strong Candidate  
Role: Constant cleansing ring  
Weapon type: Player ring and cleanse ticks  
Base cadence band: Fast  
Catalyst tags: Light, Echo  
Gameplay purpose: Creates a steady close safety ring that cleanses hostile space while ticking damage.  
Pagecraft verb: Draws a clean halo ring around the player and leaves short-lived clean traces.  
Dash payoff: Dashing through the ring sends a clean pulse outward from the dash path.  
Range intent: Self-centered ring; size upgrades widen the ring footprint.

| Level | Fixed Milestone |
|---:|---|
| L1 | Creates a constant halo ring around the player that operates on damage and cleanse ticks. |
| L5 | Halo ticks convert minor hostile marks into small damage bursts; also grants one random upgrade card. |
| L10 | Capstone: the halo can detonate after absorbing enough hostile material; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Halo Tick | constant ring | damage | Scales ring tick damage. |
| Halo Radius | constant ring | size | Ring footprint grows. |
| Clean Trace | Pagecraft trace | duration | Clean traces remain longer. |
| Clean Pulse | cleanse burst | size | Converted-mark burst is wider. |
| Pushback | constant ring | control_strength | Ring push is stronger. |
| Ring Cadence | constant ring | cadence | Ring acts more often. |
| Absorb Chance | hostile-mark proc | proc_chance | Chance to convert hostile marks; cap 75%. |
| Dash Pulse | dash payoff | damage | Dash clean pulse hits harder. |

## 8. Moonwash Breaker

Status: Strong Candidate  
Role: Out-and-back wave cleave  
Weapon type: Directional wave and return hit  
Base cadence band: Medium  
Catalyst tags: Water, Moon  
Gameplay purpose: Delivers a readable forward wave that returns as a backwash, rewarding directional movement.  
Pagecraft verb: Paints moonlit wash streaks along the outgoing and returning path.  
Dash payoff: Dashing through a wash streak causes the returning wave to widen.  
Range intent: Medium directional range; return path is the main scaling surface.

| Level | Fixed Milestone |
|---:|---|
| L1 | Sends 1 moonwashed wave in the player's movement direction; the wave returns along its path. |
| L5 | Return waves create ripple hits along their path; also grants one random upgrade card. |
| L10 | Capstone: breakers can cross the page twice, once outward and once as heavy backwash; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Outgoing Wave | outgoing wave | damage | Forward wave hits harder. |
| Backwash | return wave | damage | Return wave hits harder. |
| Breaker Width | wave path | size | Wave path is wider. |
| Wave Reach | wave path | range | Wave travels farther. |
| Wash Streak | Pagecraft streak | duration | Streaks remain longer. |
| Ripple Count | return wave | effect_count | Adds ripple hits. |
| Push Force | wave hit | control_strength | Wave push is stronger. |
| Dash Widen | dash payoff | size | Dash-widened return grows. |

## 9. Rainbow Thread

Status: Strong Candidate  
Role: Tether network and dash rails  
Weapon type: Chain, tether, rail  
Base cadence band: Medium  
Catalyst tags: Thread, Dream  
Gameplay purpose: Shares damage across linked enemies and turns links into movement routes.  
Pagecraft verb: Connects enemies and page nodes with glowing thread lines.  
Dash payoff: Dashing along a thread line accelerates the player and triggers shared damage.  
Range intent: Medium link reach; effect_count controls link quantity.

| Level | Fixed Milestone |
|---:|---|
| L1 | Links nearby enemies; linked enemies share small damage pulses. |
| L5 | Thread lines become dash rails that damage enemies crossed during dash. |
| L10 | Capstone: thread webs can pull linked packs into a detonation; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Thread Pulse | linked enemies | damage | Shared pulses hit harder. |
| Link Reach | link network | range | Links reach farther. |
| Thread Hold | Pagecraft line | duration | Thread lines remain longer. |
| Link Count | link network | effect_count | Adds more linked enemies. |
| Web Pull | web detonation | control_strength | Pull gets stronger. |
| Shared Cadence | linked enemies | cadence | Shared pulses occur more often. |
| Rail Burst | dash payoff | damage | Dash rail burst hits harder. |
| Active Threads | link network | active_cap | Allows more living thread lines. |

## 10. Pocket Parade

Status: Needs Review  
Role: Swarm coverage summon  
Weapon type: Creature-like swarm and charge command  
Base cadence band: Slow  
Catalyst tags: Wonder, Star  
Gameplay purpose: Provides decentralized coverage through many small temporary helpers.  
Pagecraft verb: Leaves dotted stitch paths where the parade travels.  
Dash payoff: Dashing commands nearby parade helpers to charge along the dash vector.  
Range intent: Short personal zone with helpers spreading outward as count grows.

| Level | Fixed Milestone |
|---:|---|
| L1 | Summons pocket sprites that ram nearby enemies. |
| L5 | Sprites can leap in short bursts through enemy flow; also grants one random upgrade card. |
| L10 | Capstone: parade waves march inward from page edges during heavy combat; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Sprite Ram | sprite hit | damage | Sprite hits harder. |
| Sprite Count | summon group | effect_count | Adds sprites. |
| Sprite Reach | summon group | range | Sprites roam farther. |
| Sprite Stay | summon group | duration | Sprites remain longer. |
| Ram Cadence | summon group | cadence | Sprites act more often. |
| Stitch Trail | Pagecraft trail | duration | Stitch paths remain longer. |
| Trail Damage | Pagecraft trail | damage | Stitch paths hurt more. |
| Dash Charge | dash payoff | damage | Commanded charge hits harder. |
| Active Parade | summon group | active_cap | Allows more living parade groups. |

## 11. Lumen Reliquary

Status: Strong Candidate  
Role: Stand-placed light beacon  
Weapon type: Placed beacon and pulse DoT  
Base cadence band: Slow  
Catalyst tags: Light, Firelight  
Gameplay purpose: Rewards movement decisions by leaving luminous damage beacons where the player stood.  
Pagecraft verb: Places reliquary light circles that pulse from fixed positions.  
Dash payoff: Dashing through a reliquary links it to the next reliquary with a light beam.  
Range intent: Placement occurs at or near player position; pulse radius scales.

| Level | Fixed Milestone |
|---:|---|
| L1 | Places 1 Lumen Reliquary at the player's position; it pulses light damage. |
| L5 | Two living reliquaries connect with a flickering light beam; also grants one random upgrade card. |
| L10 | Capstone: linked reliquaries can form a glowing chapel pattern; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Beacon Pulse | placed beacon | damage | Beacon pulse hits harder. |
| Beacon Radius | placed beacon | size | Beacon footprint grows. |
| Beacon Hold | placed beacon | duration | Beacons remain longer. |
| Pulse Cadence | placed beacon | cadence | Beacons pulse more often. |
| Beam Hit | linked beam | damage | Linked beam hits harder. |
| Beam Reach | linked beam | range | Reliquaries can link farther apart. |
| Beacon Count | placed beacon | active_cap | Allows more living beacons. |
| Dash Link | dash payoff | damage | Dash-linked beam hits harder. |

## 12. Starseed Vigil

Status: Strong Candidate  
Role: Projectile-spawned temporary turrets  
Weapon type: Projectile into limited-life sentry  
Base cadence band: Medium  
Catalyst tags: Bloom, Star  
Gameplay purpose: Converts impact points into temporary sentries that shape local space.  
Pagecraft verb: Plants luminous starseed circles that open into watcher blooms.  
Dash payoff: Dashing over a starseed bloom causes it to fire a final stronger volley.  
Range intent: Medium projectile range; sentry fire range grows with range upgrades.

| Level | Fixed Milestone |
|---:|---|
| L1 | Fires starseeds; each impact grows a sentry bloom. |
| L5 | Sentries fire arcing volleys instead of single shots; also grants one random upgrade card. |
| L10 | Capstone: starseeds can create a temporary vigil garden of firing blooms; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Sentry Shot | sentry | damage | Sentry shots hit harder. |
| Seed Impact | projectile impact | size | Impact footprint grows. |
| Sentry Hold | sentry | duration | Sentries remain longer. |
| Sentry Reach | sentry | range | Sentries fire farther. |
| Seed Count | cast | effect_count | Adds starseeds. |
| Volley Count | sentry | effect_count | Adds shots per volley. |
| Sentry Cadence | sentry | cadence | Sentries fire more often. |
| Dash Volley | dash payoff | damage | Final volley hits harder. |
| Active Sentries | sentry | active_cap | Allows more living sentries. |

## 13. Resonant Hymn

Status: Strong Candidate  
Role: Close-range echo pulse DoT  
Weapon type: Player-centered pulse and resonance spread  
Base cadence band: Fast  
Catalyst tags: Echo, Water  
Gameplay purpose: Gives close builds a rhythmic damage field that spreads resonance as it upgrades.  
Pagecraft verb: Draws expanding resonance rings from the player.  
Dash payoff: Harmonic Wake: dashing while a pulse is active stretches the ring along the dash path and replays it at dash end.  
Range intent: Short self-centered radius; cadence and spread scale before raw range.

| Level | Fixed Milestone |
|---:|---|
| L1 | Emits close resonance pulses from the player. |
| L5 | Resonance can spread from one hit enemy to another nearby enemy once; also grants one random upgrade card. |
| L10 | Capstone: overlapping hymn rings can spread resonance through dense enemy flow; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Pulse Hit | player pulse | damage | Pulse hits harder. |
| Pulse Ring | player pulse | size | Ring grows. |
| Resonance Hold | resonance mark | duration | Resonance remains longer. |
| Pulse Cadence | player pulse | cadence | Pulses occur more often. |
| Echo Count | resonance echo | effect_count | Adds echo repeats. |
| Spread Reach | resonance spread | range | Resonance spreads farther. |
| Slow Hum | resonance mark | control_strength | Resonance slow gets stronger. |
| Harmonic Wake | dash payoff | damage | Dash replay hits harder. |

## 14. Emberwrit Wyrm

Status: Strong Candidate  
Role: Burn-stroke DoT and ignition  
Weapon type: Summoned breath stroke and burning line  
Base cadence band: Medium  
Catalyst tags: Firelight, Bloom  
Gameplay purpose: Provides a fire DoT weapon that writes burning strokes rather than puddles or auras.  
Pagecraft verb: Draws ember script and breath strokes onto the page.  
Dash payoff: Dashing through an ember stroke reignites it and forks flame along the dash path.  
Range intent: Medium breath range; stroke length and burn duration scale.

| Level | Fixed Milestone |
|---:|---|
| L1 | Summons a small Emberwrit Wyrm that breathes a short fire stroke. |
| L5 | Fire strokes ignite compatible marks for bonus damage; also grants one random upgrade card. |
| L10 | Capstone: the wyrm circles the player and writes huge burning lanes; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Breath Stroke | fire stroke | damage | Breath hits harder. |
| Stroke Width | fire stroke | size | Stroke is wider. |
| Stroke Hold | Pagecraft stroke | duration | Burn line remains longer. |
| Breath Reach | fire stroke | range | Breath reaches farther. |
| Bite Hit | close bite | damage | Wyrm bite hits harder. |
| Breath Cadence | wyrm | cadence | Wyrm breathes more often. |
| Ignite Chance | compatible marks | proc_chance | Chance to ignite compatible marks; cap 75%. |
| Dash Reignite | dash payoff | damage | Dash reignition hits harder. |

## 15. Mooncourt Ring

Status: Needs Review  
Role: Delayed circular ritual trap  
Weapon type: Trap circle and delayed burst  
Base cadence band: Slow  
Catalyst tags: Moon, Dream  
Gameplay purpose: Preserves a moon-circle trap concept with a clear delayed detonation identity.  
Pagecraft verb: Places mooncourt rings that arm and detonate.  
Dash payoff: Dashing through a ring collapses it early into a larger burst.  
Range intent: Medium placement range around dense enemy flow.

| Level | Fixed Milestone |
|---:|---|
| L1 | Places mooncourt rings that detonate after a delay. |
| L5 | Enemies inside a ring when it detonates become Moonlit; also grants one random upgrade card. |
| L10 | Capstone: overlapping rings create a persistent court zone; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Ring Burst | ring detonation | damage | Detonation hits harder. |
| Court Circle | ring | size | Ring footprint grows. |
| Ring Hold | armed ring | duration | Rings remain armed longer. |
| Ring Reach | placement | range | Rings can be placed farther away. |
| Ring Count | cast | effect_count | Adds rings. |
| Moonlit Hold | Moonlit mark | duration | Moonlit state remains longer. |
| Court Slow | dream circle | control_strength | Dream circle slow gets stronger. |
| Dash Collapse | dash payoff | damage | Early collapse hits harder. |
| Active Rings | armed ring | active_cap | Allows more living rings. |

## 16. Astral Marblefall

Status: Needs Review  
Role: Heavy delayed impact and rolling hazard  
Weapon type: Falling impact and roll  
Base cadence band: Slow  
Catalyst tags: Wonder, Star  
Gameplay purpose: Adds a chunky delayed hit that turns into a rolling page hazard.  
Pagecraft verb: Creates crater rings and rolling marble lanes.  
Dash payoff: Dashing through a crater ring releases shards or redirects a rolling marble.  
Range intent: Medium placement range using enemy density; roll reach scales.

| Level | Fixed Milestone |
|---:|---|
| L1 | Drops an astral marble on dense enemy flow. |
| L5 | Rolling marbles knock back small enemies; also grants one random upgrade card. |
| L10 | Capstone: giant marbles ricochet around the visible page; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Marble Impact | falling impact | damage | Impact hits harder. |
| Crater Ring | impact mark | size | Impact footprint grows. |
| Crater Hold | Pagecraft ring | duration | Crater rings remain longer. |
| Drop Reach | placement | range | Marble can land farther away. |
| Roll Reach | rolling marble | range | Marble rolls farther. |
| Knockback | rolling marble | control_strength | Push gets stronger. |
| Shard Burst | dash payoff | effect_count | Adds shards from crater dash. |
| Giant Marble | cast proc | proc_chance | Chance cast becomes giant; cap 50%. |

## 17. Dreamwake Armada

Status: Needs Review  
Role: Dynamic wake-band sweep  
Weapon type: Fleet construct and wake stripe  
Base cadence band: Heavy Construct  
Catalyst tags: Water, Wonder  
Gameplay purpose: Sends spectral ships across the page in current movement direction, leaving temporary wake bands.  
Pagecraft verb: Paints dreamwake stripes behind spectral ships.  
Dash payoff: Dashing through a wake launches a flagship surge along dash direction.  
Range intent: Long page-crossing travel, with wake width as main scaling.

| Level | Fixed Milestone |
|---:|---|
| L1 | Launches a spectral ship in the player's movement direction and leaves a wake. |
| L5 | Wake bands ripple once before fading; also grants one random upgrade card. |
| L10 | Capstone: armada bands sweep across the visible page in parallel; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Ship Hit | spectral ship | damage | Ship contact hits harder. |
| Wake Stripe | Pagecraft wake | damage | Wake stripe hurts more. |
| Wake Width | Pagecraft wake | size | Wake bands are wider. |
| Wake Hold | Pagecraft wake | duration | Wake remains longer. |
| Ship Reach | ship path | range | Ship crosses farther. |
| Fleet Count | cast | effect_count | Adds ships. |
| Wake Ripple | fade ripple | damage | Ripple hits harder. |
| Flagship Surge | dash payoff | damage | Dash-launched flagship hits harder. |

## 18. Vesper Thread

Status: Strong Candidate  
Role: Weave-through projectile  
Weapon type: Serpentine piercing projectile  
Base cadence band: Medium  
Catalyst tags: Thread, Star  
Gameplay purpose: Satisfies the weave-through-enemies role with a distinct stitch path.  
Pagecraft verb: Leaves luminous stitch lines after weaving through enemy flow.  
Dash payoff: Dashing across a stitch line tightens it into a snap pulse.  
Range intent: Medium-to-long serpentine path; effect_count controls number of weave points.

| Level | Fixed Milestone |
|---:|---|
| L1 | Sends a Vesper Thread through a serpentine path across nearby enemy flow. |
| L5 | Stitch lines snap once after a delay for bonus damage; also grants one random upgrade card. |
| L10 | Capstone: Vesper Threads can weave a full lattice across dense enemy flow; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Thread Hit | weave path | damage | Thread hit scales. |
| Thread Path | weave path | range | Thread path reaches farther. |
| Stitch Line | Pagecraft stitch | duration | Stitch lines remain longer. |
| Stitch Width | Pagecraft stitch | size | Stitch line footprint grows. |
| Weave Points | weave path | effect_count | Adds weave points. |
| Snap Pulse | stitch snap | damage | Snap pulse hits harder. |
| Snap Reach | stitch snap | size | Snap pulse grows. |
| Dash Tighten | dash payoff | damage | Dash snap hits harder. |

## 19. Afterglow

Status: Strong Candidate  
Role: Player walking trail DoT  
Weapon type: Movement trail and kiting hazard  
Base cadence band: Fast  
Catalyst tags: Light, Firelight  
Gameplay purpose: Turns the player's movement path into a lingering damage route.  
Pagecraft verb: Paints fading afterglow along the player's footsteps.  
Dash payoff: Dashing braids the recent trail into a brighter burst line behind the player.  
Range intent: Trail reach comes from player movement; duration and width scale.

| Level | Fixed Milestone |
|---:|---|
| L1 | The player leaves a faint Afterglow trail while moving. |
| L5 | Afterglow trails slow enemies when crossed; also grants one random upgrade card. |
| L10 | Capstone: sustained movement can weave a broad afterglow path across the visible page; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Trail Burn | movement trail | damage | Trail damage scales. |
| Trail Width | movement trail | size | Trail is wider. |
| Trail Hold | movement trail | duration | Trail remains longer. |
| Trail Cadence | movement trail | cadence | Trail acts more often. |
| Bright Path | continuous movement | proc_chance | Chance to brighten current trail; cap 75%. |
| Trail Slow | movement trail | control_strength | Slow gets stronger. |
| Radiant Loop | dash proc | proc_chance | Chance to leave loop at dash end; cap 50%. |
| Dash Braid | dash payoff | damage | Burst line hits harder. |

## 20. Umbral Crescent

Status: Strong Candidate  
Role: Close melee crescent slashes  
Weapon type: Close-range arc and full-circle dash slash  
Base cadence band: Fast  
Catalyst tags: Moon, Thread  
Gameplay purpose: Gives close builds a direct melee-feeling weapon without hand-aiming.  
Pagecraft verb: Etches shadow crescent cuts into the page.  
Dash payoff: Dashing after a sweep turns the next arc into an extended, stronger full circular slash.  
Range intent: Short close range; capstone reaches medium with full-circle bursts.

| Level | Fixed Milestone |
|---:|---|
| L1 | Sweeps an umbral crescent around the player. |
| L5 | Sweeps alternate left and right arcs for better close coverage; also grants one random upgrade card. |
| L10 | Capstone: dash-enhanced slashes can cover a broad circle around the player; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Crescent Cut | close arc | damage | Slash damage scales. |
| Crescent Arc | close arc | size | Arc covers more area. |
| Crescent Reach | close arc | range | Arc reaches farther. |
| Cut Trace | Pagecraft cut | duration | Lingering cuts remain longer. |
| Sweep Cadence | close arc | cadence | Sweeps happen more often. |
| Double Sweep | sweep proc | proc_chance | Chance for a second sweep; cap 50%. |
| Full Circle | dash payoff | size | Dash-enhanced circle grows. |
| Dash Cut | dash payoff | damage | Dash-enhanced slash hits harder. |

## 21. Solar Mantle

Status: Strong Candidate  
Role: Fixed-radius close aura DoT  
Weapon type: Persistent aura and dash flare  
Base cadence band: Fast  
Catalyst tags: Firelight, Light  
Gameplay purpose: Gives close-range builds steady DoT around the player.  
Pagecraft verb: Draws a warm solar corona ring around the player.  
Dash payoff: Dashing briefly expands the mantle into a huge solar flare radius.  
Range intent: Fixed close radius with short flare bursts; size upgrades widen it.

| Level | Fixed Milestone |
|---:|---|
| L1 | Creates a constant solar mantle around the player that acts repeatedly. |
| L5 | Dash creates a brief solar flare with much larger radius; also grants one random upgrade card. |
| L10 | Capstone: solar flares can briefly cover a large visible area around the player; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Mantle Burn | constant aura | damage | Aura damage scales. |
| Mantle Radius | constant aura | size | Aura grows. |
| Mantle Cadence | constant aura | cadence | Aura acts more often. |
| Corona Trace | Pagecraft trace | duration | Movement trace remains longer. |
| Flare Radius | dash payoff | size | Dash flare grows. |
| Flare Burn | dash payoff | damage | Dash flare hits harder. |
| Flare Hold | dash payoff | duration | Flare remains longer. |
| Solar Ring | dash proc | proc_chance | Chance to leave corona ring; cap 50%. |

## 22. Dream Veil

Status: Strong Candidate  
Role: Drifting dream-mist DoT  
Weapon type: Haze patches and slow DoT  
Base cadence band: Medium  
Catalyst tags: Dream, Bloom  
Gameplay purpose: Provides a soft DoT field that drifts near player path and slowly weakens enemy flow.  
Pagecraft verb: Releases dream haze patches onto the page.  
Dash payoff: Dashing tears active haze into a wide crescent mist trail.  
Range intent: Short-to-medium drifting patches; duration and patch count scale.

| Level | Fixed Milestone |
|---:|---|
| L1 | Releases Dream Veil patches near the player. |
| L5 | Enemies inside haze build drowsy stacks that burst at threshold; also grants one random upgrade card. |
| L10 | Capstone: dream haze can blanket major routes around the player; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Haze Damage | dream haze | damage | Haze damage scales. |
| Haze Cloud | dream haze | size | Haze patches grow. |
| Haze Hold | dream haze | duration | Haze remains longer. |
| Patch Count | cast | effect_count | Adds haze patches. |
| Haze Drift | dream haze | range | Haze can drift farther. |
| Drowsy Burst | drowsy stacks | damage | Stack burst hits harder. |
| Haze Slow | dream haze | control_strength | Haze slow gets stronger. |
| Dash Tear | dash payoff | damage | Torn mist trail hits harder. |
| Active Veils | dream haze | active_cap | Allows more living haze patches. |

## 23. Starglass Shower

Status: Needs Review  
Role: Scattered prismatic coverage  
Weapon type: Random shard rain and refracting splinters  
Base cadence band: Medium  
Catalyst tags: Star, Echo  
Gameplay purpose: Adds broad screen coverage through small readable prismatic hits.  
Pagecraft verb: Leaves starglass splinters where shards land.  
Dash payoff: Dashing gathers nearby splinters into a short rainbow burst around the player.  
Range intent: Wide visible-page scatter; density improves more than damage.

| Level | Fixed Milestone |
|---:|---|
| L1 | Drops small starglass shards across random visible positions. |
| L5 | Splinters refract the next nearby hit into a tiny glint; also grants one random upgrade card. |
| L10 | Capstone: starglass can rain across much of the visible page; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Shard Hit | shard rain | damage | Shards hit harder. |
| Shard Splash | shard impact | size | Shard impact grows. |
| Splinter Hold | Pagecraft splinter | duration | Splinters remain longer. |
| Shower Count | cast | effect_count | Adds shards. |
| Shower Reach | visible scatter | range | Shower can cover farther visible space. |
| Glint Hit | splinter glint | damage | Refracted glint hits harder. |
| Glint Chance | splinter proc | proc_chance | Chance for glint; cap 75%. |
| Dash Gather | dash payoff | damage | Gathered burst hits harder. |

## 24. Mirror Waltz

Status: Strong Candidate  
Role: Delayed movement-path replay  
Weapon type: Recorded path afterimage  
Base cadence band: Slow  
Catalyst tags: Dream, Echo  
Gameplay purpose: Rewards movement routing by replaying the player's recent path as delayed damage.  
Pagecraft verb: Leaves mirror traces along replayed movement.  
Dash payoff: If the recorded path includes a dash, that segment replays wider and brighter.  
Range intent: Reach comes from player movement in the recorded time window.

| Level | Fixed Milestone |
|---:|---|
| L1 | Records recent player movement and replays it as a damaging mirror afterimage. |
| L5 | Dash segments inside the recording replay wider; also grants one random upgrade card. |
| L10 | Capstone: Mirror Waltz can replay a long movement phrase across a large page route; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Replay Hit | mirror replay | damage | Replay hits harder. |
| Replay Trace | mirror replay | size | Replay path is wider. |
| Trace Hold | Pagecraft trace | duration | Mirror traces remain longer. |
| Record Window | mirror replay | duration | Captures a longer recent movement phrase. |
| Replay Cadence | mirror replay | cadence | Replays happen more often. |
| Echo Replay | dash segment | effect_count | Adds replay repeats for dash segments. |
| Offset Dancer | replay proc | proc_chance | Chance to create offset replay; cap 50%. |
| Trace Crossing | trace interaction | damage | Replays crossing traces hit harder. |

## 25. Wishwell Vortex

Status: Strong Candidate  
Role: Tug wells and global detonation  
Weapon type: Placed pull zone and charged detonation  
Base cadence band: Slow  
Catalyst tags: Wonder, Water  
Gameplay purpose: Groups enemies through active wells, then lets dash timing detonate the entire well network.  
Pagecraft verb: Places shimmering wishwells and faint wish rings.  
Dash payoff: Dashing through any faint wish ring detonates all active wells, scaling with enemies touched by all wells collectively.  
Range intent: Medium placement range; active well count and pull radius scale.

| Level | Fixed Milestone |
|---:|---|
| L1 | Places Wishwell Vortex zones that tug enemies inward and deal churn damage. |
| L5 | Wells track the total enemies touched across the whole active network; also grants one random upgrade card. |
| L10 | Capstone: detonating a large well network creates a page-shaking wishburst; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Churn Damage | active well | damage | Well churn hits harder. |
| Well Radius | active well | size | Pull zone grows. |
| Well Hold | active well | duration | Wells remain longer. |
| Well Reach | placement | range | Wells can place farther away. |
| Well Count | well network | active_cap | Allows more living wells. |
| Pull Force | active well | control_strength | Tug gets stronger. |
| Touch Scaling | network charge | damage | Collective-touch detonation scales harder. |
| Ring Detonation | dash payoff | damage | Dash-triggered detonation hits harder. |

## 26. Skykite Chorus

Status: Needs Review  
Role: Overhead kite-construct dives  
Weapon type: Construct dive and diagonal sweep  
Base cadence band: Slow  
Catalyst tags: Wonder, Thread  
Gameplay purpose: Adds readable overhead constructs that dive across the page in synchronized sweeps.  
Pagecraft verb: Leaves kite-tail streaks where dives pass.  
Dash payoff: Dashing tugs all active kites to dive along the dash direction.  
Range intent: Wide diagonal page coverage; kite count and dive width scale.

| Level | Fixed Milestone |
|---:|---|
| L1 | Summons skykites that circle briefly, then dive diagonally across the page. |
| L5 | Kites dive in synchronized crossing paths; also grants one random upgrade card. |
| L10 | Capstone: kites dive from several angles to cross a broad visible region; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Kite Dive | dive path | damage | Dive hits harder. |
| Tail Streak | Pagecraft tail | duration | Tail streaks remain longer. |
| Dive Width | dive path | size | Dive path widens. |
| Dive Reach | dive path | range | Dives travel farther. |
| Kite Count | chorus | effect_count | Adds kites. |
| Dive Cadence | chorus | cadence | Kites dive more often. |
| Wind Push | dive path | control_strength | Dive push gets stronger. |
| Dash Tug | dash payoff | damage | Dash-directed dive hits harder. |

## 27. Cloudcastle

Status: Strong Candidate  
Role: Drifting rain castle construct  
Weapon type: Big-object summon and area rain  
Base cadence band: Heavy Construct  
Catalyst tags: Bloom, Echo  
Gameplay purpose: Summons a readable drifting object that rains below it and can fire cannons through dash payoff.  
Pagecraft verb: Drops cloud-shadow rain patches beneath the castle.  
Dash payoff: Dashing gusts active Cloudcastles forward and makes cannons fire from all sides.  
Range intent: Medium drift around combat flow; rain footprint and cannon count scale.

| Level | Fixed Milestone |
|---:|---|
| L1 | Summons a Cloudcastle that drifts and rains damage beneath it. |
| L5 | Dash gust fires cannons from all sides of each active castle; also grants one random upgrade card. |
| L10 | Capstone: multiple Cloudcastles can drift together and rain on broad routes; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Castle Rain | rain patch | damage | Rain hits harder. |
| Rain Footprint | rain patch | size | Rain covers more space. |
| Castle Stay | Cloudcastle | duration | Castle remains longer. |
| Castle Drift | Cloudcastle | range | Castle can drift farther from origin. |
| Rain Cadence | rain patch | cadence | Rain acts more often. |
| Cannon Count | dash payoff | effect_count | Adds cannon shots. |
| Cannon Hit | dash payoff | damage | Cannon burst hits harder. |
| Active Castles | Cloudcastle | active_cap | Allows more living castles. |

## 28. Dream Gates

Status: Strong Candidate  
Role: Paired gate construct and teleport detonation  
Weapon type: Placed gates and connecting beam  
Base cadence band: Heavy Construct  
Catalyst tags: Dream, Thread  
Gameplay purpose: Places gates that damage locally, connect by beam, and create a dramatic dash-triggered enemy relocation burst.  
Pagecraft verb: Places dream door glyphs on the page.  
Dash payoff: Dashing through a gate teleports enemies touched by living gates to the oldest living gate, then all gates explode.  
Range intent: Medium placement range; gate count and beam length scale.

| Level | Fixed Milestone |
|---:|---|
| L1 | Places Dream Gates that damage nearby enemies and connect with a damaging beam. |
| L5 | Dashing through a gate teleports enemies touched by living gates to the oldest gate, then all gates explode; also grants one random upgrade card. |
| L10 | Capstone: Dream Gates can form a short-lived doorway network before detonation; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Gate Aura | gate aura | damage | Gate area damage scales. |
| Gate Radius | gate aura | size | Gate area grows. |
| Gate Hold | gate | duration | Gates remain longer. |
| Gate Reach | placement | range | Gates can place farther apart. |
| Gate Count | gate network | active_cap | Allows more living gates. |
| Beam Hit | gate beam | damage | Beam hits harder. |
| Beam Cadence | gate beam | cadence | Beam acts more often. |
| Gate Burst | dash payoff | damage | Teleport explosion hits harder. |

## 29. Bell Tower of Stars

Status: Needs Review  
Role: Big-object ringing tower  
Weapon type: Dropped tower and shockwave rings  
Base cadence band: Heavy Construct  
Catalyst tags: Echo, Moon  
Gameplay purpose: Summons a readable object that tolls expanding damage rings from its location.  
Pagecraft verb: Leaves bell-circle ripples around each tower.  
Dash payoff: Dashing through one tower tolls all living towers at once, creating overlapping rings.  
Range intent: Medium placement range; ring radius and tower count scale.

| Level | Fixed Milestone |
|---:|---|
| L1 | Drops a Bell Tower of Stars that tolls expanding rings before fading. |
| L5 | Multiple living towers can resonate with each other; also grants one random upgrade card. |
| L10 | Capstone: living towers can fill a broad region with overlapping tolls; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Toll Ring | tower ring | damage | Rings hit harder. |
| Ring Radius | tower ring | size | Rings grow. |
| Tower Stay | tower | duration | Towers remain longer. |
| Tower Reach | placement | range | Towers can drop farther away. |
| Toll Cadence | tower | cadence | Towers ring more often. |
| Ring Count | tower | effect_count | Adds rings per tower. |
| Tower Count | tower network | active_cap | Allows more living towers. |
| All-Tower Toll | dash payoff | damage | Dash-triggered toll hits harder. |

## 30. Starrail Express

Status: Needs Review  
Role: Big-object rail sweep  
Weapon type: Page-crossing express and fading rail  
Base cadence band: Heavy Construct  
Catalyst tags: Water, Firelight  
Gameplay purpose: Sends a clear page-crossing construct through one broad path.  
Pagecraft verb: Lays fading star rails along the express route.  
Dash payoff: Dashing across a fading rail detonates all fading rails immediately.  
Range intent: Long page-crossing range; rail width and train count scale.

| Level | Fixed Milestone |
|---:|---|
| L1 | Calls a Starrail Express across the visible page, damaging along a broad route. |
| L5 | Fading rails can be detonated by dash for burst damage; also grants one random upgrade card. |
| L10 | Capstone: Starrail Express can cross the page in two parallel routes; also grants one random upgrade card. |

| Upgrade | Scope | Stat | Notes |
|---|---|---|---|
| Express Hit | express route | damage | Train path hits harder. |
| Rail Width | express route | size | Rail route widens. |
| Rail Hold | Pagecraft rail | duration | Rails remain longer. |
| Route Reach | express route | range | Express travels farther. |
| Express Count | cast | effect_count | Adds parallel routes or side cars. |
| Rail Detonation | dash payoff | damage | Dash rail burst hits harder. |
| Detonation Width | dash payoff | size | Rail burst grows. |
| Grand Express | cast proc | proc_chance | Chance for larger express; cap 50%. |

## Removed Candidates Appendix

These concepts are removed from the active pool but retained for reference.

### Removed Candidate: Crown Compass

Reason: Cut from active pool during upgrade-model revision.

### Removed Candidate: Ribbon Whip

Reason: Cut from active pool during upgrade-model revision.

### Removed Candidate: Bannerlight Vanguard

Reason: Cut from active pool during upgrade-model revision.
