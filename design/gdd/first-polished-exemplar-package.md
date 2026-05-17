# First Polished Exemplar Package

> **Status**: Draft for implementation planning  
> **Author**: Sean + Codex  
> **Last Updated**: 2026-05-16
> **Implements Pillar**: The Page Is Alive, Power Fantasy First, Simple Controls  

## Purpose

This document locks the first polished exemplar package for the current prototype slice. It is the design source for the first cohesive gameplay package: one starter weapon, one passive item, one support pet, one Page Event, one enemy family, one mini-boss echo, and the HUD feedback needed to make them readable.

Design source consulted: `PAGEBOUND_CODEX_GDD_v1_5.md`; `design/gdd/mvp-weapon-candidate-pool.md`; `design/gdd/mvp-item-candidate-pool.md`; `design/gdd/xp-leveling-and-upgrade-drafts.md`; `design/gdd/page-events-and-objectives.md`; `design/gdd/enemies-and-ai-movement.md`; `design/gdd/boss-and-victory-flow.md`; `design/gdd/in-run-hud-and-draft-ui.md`; `design/gdd/pagecraft-materials-and-grid.md`; `design/gdd/passive-items-and-drafts.md`; `design/gdd/weapons-and-auto-attacks.md`; `design/gdd/damage-and-status-model.md`.

## Package Contents

| Domain | Exemplar Choice | Notes |
|---|---|---|
| Chapter feel | Waxlight Castle | Storybook page, Waxlight material identity. |
| Starter weapon | Star Sticker Swarm | Starter baseline weapon. Starts at level 1. Waxlight Comet remains an early AoE/Pagecraft weapon in the prototype pool. |
| Passive item | Candle Spark | First passive item. Global passive item, not weapon-specific. Current prototype pool also includes Cloud Seed, Dream Thread, Ribbon Spool, and Moon Button. |
| Pet | Dog | Support-only pickup fetch helper. No direct damage. Not a loadout slot. |
| Page Event | Color Well | Offscreen event, 60s timer, 15 kills inside circle. |
| Enemy family | Waxlight Imps | Wax Imp basic chaser + Flicker Imp fast low-HP chaser. |
| Mini-boss echo | Crownless Echo / Crownless Scribble | Killable mini-boss echo, not full final boss. |
| HUD direction | Refined C | Top-left kill counter, top-right exclusive event/boss banner, bottom XP, bottom-left level/pet badges, 5 weapons + 5 items. |

## First 5-Minute Target

The game does not hard stop at 5:00. Five minutes is the target evaluation window for whether the first package is readable.

| Time | Target Beat |
|---:|---|
| `0:00` | Run starts with Star Sticker Swarm level 1 and Dog active. No passive item by default. |
| `~0:30` | First normal level-up draft may appear, depending on XP tuning. |
| `1:00` | Color Well Page Event spawns outside current vision at a random valid reachable page location. Timer starts immediately. |
| `2:00` | Color Well succeeds or fails. Success opens a Page Event reward draft. Failure gives no event reward and run continues. |
| `3:30` | Crownless Echo appears if no Page Event is active. If an event is active, boss waits until it ends. |
| `5:00` | Evaluation point only. Run may continue and Crownless Echo may still be alive. |

Prototype map size must grow significantly beyond the current test slice so `Color Well` can spawn completely outside player vision with enough room for routing and combat.

## Draft Acquisition Canon

Normal level-up drafts and Page Event reward drafts show exactly 3 cards.

Normal draft card roll:

1. Roll category per card:
   - `70%` upgrade
   - `30%` new gear
2. If the card rolls new gear:
   - `50%` new weapon
   - `50%` new item
   - If the chosen gear type has no legal card but the other gear type does, redirect to the other gear type.
   - If no legal new gear exists, redirect to an upgrade.
3. If the card rolls upgrade:
   - `50%` weapon upgrade
   - `50%` item upgrade
   - If the chosen upgrade type has no legal card but the other upgrade type does, redirect to the other upgrade type.
4. Select uniformly among legal cards in the chosen category.
5. Reroll exact duplicate target+action cards within the same draft.

Legal normal cards:

- New weapon, if an unowned weapon exists and a weapon slot is open.
- New item, if an unowned item exists and an item slot is open.
- `+1` weapon level, if an owned weapon is below level 10.
- `+1` item level, if an owned item is below level 5.

Rules:

- New gear always enters at level 1.
- Upgrade cards always grant exactly `+1` level.
- There are no fixed weapon-only draft levels.
- There is no pity system.
- There are no elite/chest reward drafts in current scope.
- No Pagecraft modifiers, rare utility rewards, temporary super attacks, heals, magnets, event evolutions, or boss reward drafts are part of this package.

Page Event reward draft:

- Uses the same normal draft rules.
- Extra rule: if any legal unowned weapon or item exists and an appropriate slot is open, at least one card must be new gear.
- Forced event gear uses the same `50%` weapon / `50%` item subroll and redirect rules.
- If no legal unowned gear exists, the guarantee fails gracefully and the event reward is just a normal draft.

Overflow:

- Starts only when no normal legal cards exist: all weapon slots full, all item slots full, all owned weapons level 10, and all owned items level 5.
- Overflow cards are global `+5%` stat crumbs using existing broad stat channels.
- Overflow is not needed for the first 5-minute package but must not be confused with pity or fallback rewards.

## Current Prototype Pool Behavior

Historical first-package pool, now superseded by the current prototype pool:

- Weapon pool contained only Waxlight Comet.
- Item pool contained only Candle Spark.

Current prototype implementation note: the user-approved second content batch expands the pool with `Star Sticker Swarm`, `Cloud Seed`, `Dream Thread`, `Ribbon Spool`, and `Moon Button`. Runtime draft logic must use the authored content pool dynamically and must not assume Waxlight/Candle are the only legal gear.

Implications:

- The player starts with Star Sticker Swarm.
- Waxlight Comet is legal as an unowned new weapon while a weapon slot is open.
- Candle Spark, Cloud Seed, Dream Thread, Ribbon Spool, and Moon Button are legal as unowned passive items while passive slots are open.
- Page Event reward guarantees use the full current legal gear pool, not the historical Waxlight/Candle-only redirect.

## HUD Contract

HUD direction follows the approved `Refined C` prototype.

- Top-left shows the solo kill counter. Future party/multiplayer friend status must share or intentionally replace that space.
- Top-right is one exclusive banner slot. It shows Page Event state or boss state, never both.
- Event banner shows percentage as primary progress, with count/timer secondary.
- Boss banner shows HP percentage as primary progress, with boss name and health bar.
- Event circle shows ring/fill progress only. No center count text.
- Bottom edge is a full-width XP bar with XP percent text on the bar.
- Bottom-left shows current run level.
- Bottom-left also shows a small always-visible Dog pet icon that pulses/mirrors fetch feedback.
- Loadout displays all 10 slots from run start: 5 weapons and 5 items.
- Loadout does not label rows with text such as `Wpn` or `Item`; row meaning should be visually obvious from icons and content.
- Dog is not a loadout slot.
- HP bar must be larger than the current small prototype bar and easy to read while fighting.

## Dog Support Pet

Dog is a support-only pet in this package.

- Dog is a visible decorative follower.
- Dog has no collision, no combat AI, and no direct damage.
- Dog has no pickup aura.
- Developer-only XP range debug circles can show the player's 3.0m XP pickup range and Dog's fetch range when a debug toggle is enabled; these are not player-facing auras.
- Dog extends the player's effective pickup reach by watching pickups inside its fetch range.
- Pickups inside that range are not credited instantly; Dog moves to them and fetches them with its own simple pathing/follow AI.
- Once Dog starts moving toward a pickup, leaving Dog fetch range does not cancel that fetch; Dog finishes unless the pickup becomes invalid or is collected first.
- T1: Dog fetches Color Motes inside a 6.0m fetch range, 100% larger than default 3.0m XP magnetism.
- T2: Dog can also fetch health pickups.
- T3: Dog fetch range increases to 8.625m.
- When Dog fetches XP, credit is applied only when Dog reaches the pickup.
- Feedback is both world feedback (`Dog fetch +3 XP`) and pet icon pulse near the level badge.

## Color Well Page Event

Color Well is the first Page Event exemplar.

- Spawns at `1:00` in the first package target.
- Spawns outside current player/camera vision.
- Spawn location is random among valid reachable walkable page positions.
- Valid positions exclude blocked or unreachable locations, locked/future/boss-only areas, and locations where the event circle would clip off the usable page.
- Uses an edge arrow only while offscreen. No distance text, compass, or minimap is required for this package.
- Timer starts immediately when the event spawns, even if the player has not reached it.
- Event duration: 60 seconds.
- Objective: kill 15 enemies whose death position is inside the circle.
- Enemy spawns are not biased toward the circle. Player must lure enemies into it.
- Success opens the Page Event reward draft described above.
- Failure gives no event reward and run continues.
- Failed events do not immediately respawn or replace themselves. The next event waits for the next authored schedule slot.

## Waxlight Imps

First enemy family:

- Wax Imp: basic slow chaser, high readability, low complexity.
- Flicker Imp: faster low-HP chaser, creates movement pressure.

No ranged, tank, elite, or event-only enemy is required for the first package.

## Crownless Echo

Crownless Echo is a killable mini-boss echo, not the full final boss.

- Target spawn: `3:30`.
- Boss/event overlap is not allowed.
- Schedules should be authored to avoid overlap, and boss spawn should still wait if a Page Event is active.
- Uses the exclusive top-right boss banner.
- Killing Crownless Echo drops XP/Color Motes only.
- Crownless Echo does not open an in-run draft in the first package.
- The run does not hard stop at 5:00.

## Implementation Notes

- The prototype HUD reference lives at `prototypes/ui/pagebound-hud-live.html`.
- The prototype is not production code. Production HUD work should split behavior, data, and styling into focused Godot scenes/scripts/resources.
- The first implementation should not add hidden pity, static weapon levels, event-only reward pools, or draft categories not listed here.
