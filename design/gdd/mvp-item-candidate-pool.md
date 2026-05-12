# MVP Item Candidate Pool and Meta Stat Progression

> Status: Draft review document  
> Owner: Design  
> Source bead: pagebound-nge  
> Last updated: 2026-05-12

## Purpose

This document captures the active MVP item/stat model based on the latest item, draft, and endless-mode decisions. It answers current design questions, defines the 23-entry passive item pool, defines 5-tier long-term meta progression tracks, and adds rules to reduce "missed required item" frustration.

This is the active MVP passive-item roster draft. The root GDD and focused system docs should reference 23 passive items after the matching documentation update.

Design source consulted: `PAGEBOUND_CODEX_GDD_v1_5.md` sections 12, 20, and 37; `design/gdd/passive-items-and-drafts.md`; `design/gdd/xp-leveling-and-upgrade-drafts.md`; `design/gdd/evolution-system.md`; `design/gdd/damage-and-status-model.md`; `design/gdd/mvp-weapon-candidate-pool.md`.

## Working Answers

| Question | Working Answer | Recommendation |
|---|---|---|
| When do players get items? | Items appear in the same 3-choice reward drafts as weapons: run level-ups, Page Event rewards, elite story chests, boss/finale rewards, and rare treasure pickups. A new item enters at level 1. An owned item upgrade card adds exactly +1 item level, up to level 5. | Allow item cards from the first draft, but weight early drafts toward weapons until the player has 2-3 weapons. Guarantee at least one new item offer by run level 4 or the first Page Event reward, whichever happens first. |
| Do items level by collecting multiples? | Not by physical duplicate pickups by default. The player levels items by selecting item upgrade cards from drafts. | Keep this consistent with weapon leveling: one selected card equals one level. Rare chest/event rewards may grant "+1 to an owned item" but should still be presented as a draft reward. |
| Is there a max unique item cap during a run? | Yes. MVP should keep 5 unique passive item slots and item level cap 5. | Keep 5 slots for readability and HUD clarity. Consider a later Wonder Box unlock for a starter item option before adding a 6th passive slot. |
| How do catalysts relate to items? | Items carry catalyst tags from level 1, but only level 5 items expose full catalyst value for weapon evolution eligibility. Items are not consumed by evolutions. | Keep catalysts broad and tag-based. Do not use strict 1:1 weapon-item recipes. |
| How does item rarity work? | Each item has an initial find rarity. That rarity affects how often the item appears as a new-item card only. Once owned, its +1 level upgrade cards use normal upgrade-card weights and still grant exactly one item level. | Use the 60/25/9/5/1 rarity weights for initial item finds. Do not make Legendary items miserable to level after they are found. |
| How do we avoid "I needed one item and never got it"? | Build reliability comes from broad catalyst families, multiple compatible items, synergy-weighted drafts, pity rules, rerolls/banishes, and useful item effects even when no evolution happens. | Treat every item as a real build piece first and an evolution catalyst second. Add compatibility previews and draft pity before adding more raw item slots. |

## Recommendation

Use this structure for MVP review:

- Keep 5 unique passive item slots.
- Keep 5 item levels.
- Keep 10 catalyst families from the weapon candidate document: `Firelight`, `Moon`, `Star`, `Dream`, `Thread`, `Bloom`, `Water`, `Light`, `Echo`, `Wonder`.
- Use 23 active passive items.
- Use initial find rarity split: 8 Common, 6 Uncommon, 5 Rare, 3 Epic, 1 Legendary.
- Use initial find weights: Common 60, Uncommon 25, Rare 9, Epic 5, Legendary 1.
- Give normal passives 2 catalyst tags.
- Give Legendary `Foundational Keepsake` all 10 catalyst tags at level 5.
- Keep the broadest three stats - `effect_count`, `active_cap`, and `base_stat_boost` - bounded through chance, overflow, and capstone limits instead of raw global count multiplication.
- Normal strong-run target by the 30:00 boss: 5 weapons owned, 2 level 10 weapons, 4 level 5 items, and 1-2 evolutions.

## In-Run Item Rules

### Acquisition

Passive item cards can appear from:

- normal run level-up drafts,
- Page Event reward drafts,
- elite story chests,
- boss/finale reward drafts,
- rare treasure pickups.

Draft defaults:

- Normal drafts still show exactly 3 choices.
- Weapon-only drafts occur at run levels 5, 10, 20, and 35. When legal, those drafts show only new-weapon cards.
- Non-weapon-only normal drafts try to show 1 weapon-side card, 1 item-side card, and 1 flex card.
- A new passive item can appear if the player owns fewer than 5 passive items.
- A +1 item level card can appear if the player owns that item below level 5.
- Initial item find rarity affects new-item cards only.
- Owned item upgrade cards grant fixed +1 item level.
- A level 5 item unlocks its full catalyst value.
- A level 5 item is never consumed by evolution.
- If every item slot is full, new item cards stop appearing unless a later reward explicitly offers replacement.

### Timing Targets

| Run Timing | Item Target |
|---|---|
| First 2-3 normal drafts | Weapon-only level drafts handle weapon count; normal drafts should already include item-side choices. |
| By run level 4 or first Page Event | If the player has no passive item, force at least one legal new item offer. |
| Around 5:00 | Expected build has 2-3 weapons and 1-2 items. |
| Around 10:00 | Expected build has the 3-weapon core and is filling item slots. |
| Around 20:00 | Expected build has 4 weapons and several owned items approaching level 5. |
| Around 30:00 | Normal strong build has 5 weapons owned, 2 level 10 weapons, 4 level 5 items, and 1-2 evolutions. |
| Endless | Normal upgrades continue after level 50 while available; overflow drafts start only after no normal weapon/item/evolution upgrades remain. |

### Item Levels

All passive items use 5 levels.

| Level | Rule |
|---:|---|
| 1 | Base item effect starts immediately. Catalyst tags are visible, but not evolution-enabling. |
| 2 | Improves the item effect. |
| 3 | Improves the item effect or adds a small secondary behavior. |
| 4 | Improves the item effect. |
| 5 | Capstone effect and full evolution catalyst value. |

## Build Reliability Rules

These rules directly address the Vampire Survivors problem where the player needs a specific passive, misses it, and loses the intended build.

### Broad Catalyst Matching

Each weapon has two catalyst families. Each item has two catalyst families. Evolutions require a matching catalyst family, not a specific item ID.

Example:

```text
Level 10 Waxlight Comet
+ any level 5 item with Firelight or Light
= compatible evolution options can appear
```

### Draft Synergy Weighting

Draft generator should raise the weight of:

- items whose catalyst tags match owned weapons,
- item upgrades that would bring a compatible item closer to level 5,
- new items that cover catalyst families the current build is missing,
- evolution cards once requirements are met.

### Pity Rules

Use pity rules so build construction does not collapse from bad card luck:

- If the player owns 0 items by run level 4, the next normal draft must include one legal new item.
- If the player owns a level 7+ weapon and no owned item can support either catalyst family, the next three item-eligible drafts heavily weight compatible new items.
- If the player owns a level 8+ weapon and a compatible item at level 3 or 4, item upgrade cards for that item gain strong weight.
- If a level 10 weapon and level 5 compatible item exist, evolution cards gain late-run priority.
- If all normal choices would be dead or irrelevant, fallback choices can include heal, pickup magnet, currency, temporary Page Takeover attack, or Pagecraft modifier.

### No Key-Only Items

Every item must be useful at level 1 without a matching weapon. Catalyst value is a bonus, not the item's whole identity.

Bad pattern:

```text
Item does almost nothing unless paired with one exact weapon.
```

Good pattern:

```text
Item gives useful stats now, shows catalyst tags, and can support multiple weapons later.
```

### Compatibility Preview

Draft cards should show:

- item stat effect,
- item level,
- catalyst tags,
- owned weapons that could use those catalyst tags later,
- whether this card moves any owned weapon closer to evolution eligibility.

## Candidate Item Stat Pool

This table uses 23 active passive items because the requested stat list has 23 roles.

| # | Working Item Name | Find Rarity | Stat Role | Catalyst Tags | L1 | L2 | L3 | L4 | L5 |
|---:|---|---|---|---|---:|---:|---:|---:|---:|
| 1 | Candle Spark | Common | damage | Firelight, Light | +5% | +10% | +15% | +20% | +25% and capstone spark |
| 2 | Cloud Seed | Common | size | Bloom, Wonder | +5% | +10% | +15% | +20% | +25% and larger expiration pop |
| 3 | Dream Thread | Common | duration | Dream, Thread | +5% | +10% | +15% | +20% | +25% and first timed mark echoes |
| 4 | Ribbon Spool | Common | range | Thread, Star | +5% | +10% | +15% | +20% | +25% and longer link reach |
| 5 | Moon Button | Common | cadence | Moon, Echo | +5% | +10% | +15% | +20% | +25% and every 10th cast echoes at partial power |
| 6 | Firefly Charm | Uncommon | proc_chance | Light, Wonder | +5 pp | +10 pp | +15 pp | +20 pp | +25 pp and first failed proc after a delay is retried |
| 7 | Seashell Lullaby | Uncommon | control_strength | Water, Echo | +5% | +10% | +15% | +20% | +25% and control effects leave a tiny resonance pulse |
| 8 | Acorn Charm | Epic | effect_count | Bloom, Star | +10% bonus effect chance | +15% | +20% | +25% | +30% and first bonus each Page Event is guaranteed |
| 9 | Pocket Locket | Epic | active_cap | Dream, Wonder | +10% cap overflow grace | +15% | +20% | +25% | +30% and one eligible construct can exceed cap by 1 |
| 10 | Lucky Pebble | Rare | luck | Star, Wonder | +5% | +10% | +15% | +20% | +25% and better rare-card weighting |
| 11 | Blanket Pin | Common | armor | Thread, Light | +1 | +2 | +3 | +4 | +5 and shield pulse on heavy hit |
| 12 | Paper Heart | Common | max_health | Bloom, Light | +10 | +20 | +30 | +40 | +50 and overheal shield |
| 13 | Dewdrop Thimble | Uncommon | health_regen | Water, Bloom | +0.2/s | +0.4/s | +0.6/s | +0.8/s | +1.0/s and first heal after Page Event doubles |
| 14 | Firefly Jar | Uncommon | xp_magnet_range | Light, Wonder | +10% | +20% | +30% | +40% | +50% and periodic mote pull |
| 15 | Storybook Key | Uncommon | xp_gain_rate | Dream, Star | +5% | +10% | +15% | +20% | +25% and Page Event rewards add bonus XP motes |
| 16 | Wooden Star | Rare | crit_chance | Star, Light | +3 pp | +6 pp | +9 pp | +12 pp | +15 pp and crit sparks |
| 17 | Tiny Crown | Rare | crit_damage | Light, Wonder | +10% | +20% | +30% | +40% | +50% and large crits make brighter popups |
| 18 | Feather Cape | Uncommon | dash_range | Thread, Moon | +5% | +10% | +15% | +20% | +25% and dash trail hitbox grows |
| 19 | Button Boots | Rare | dash_count | Wonder, Thread | +1 charge | +1 charge, faster refill after Page Event | +2 charges | +2 charges, first empty dash refunds once | +3 charges |
| 20 | Moonlace Stopwatch | Rare | dash_cooldown | Moon, Echo | -5% | -10% | -15% | -20% | -25% and first dash after draft has no cooldown |
| 21 | Paper Pinwheel | Common | movement_speed | Water, Bloom | +3% | +6% | +9% | +12% | +15% and brief speed burst after pickup streak |
| 22 | Foundational Keepsake | Legendary | base_stat_boost | Firelight, Moon, Star, Dream, Thread, Bloom, Water, Light, Echo, Wonder | +2% | +4% | +6% | +8% | +10%, all catalyst tags active, and improves lowest core stat again |
| 23 | Second Bookmark | Epic | revive | Dream, Light | 1 revive at 20% health | 30% | 40% | 50% | 60% and short invulnerability |

### Find Rarity Rules

| Find Rarity | Item Count | Initial Find Weight |
|---|---:|---:|
| Common | 8 | 60 |
| Uncommon | 6 | 25 |
| Rare | 5 | 9 |
| Epic | 3 | 5 |
| Legendary | 1 | 1 |

- Find rarity applies only when a new item is being offered.
- Once an item is owned, its upgrade cards grant fixed +1 item level.
- Upgrade-card rarity and luck may affect how often an owned item upgrade appears, but never changes the amount of item levels gained.
- `Foundational Keepsake` is the only Legendary passive and its all-catalyst value is evolution-enabling only at level 5.

### Flat-Count Item Guardrail

`effect_count`, `active_cap`, and `dash_count` are flat-count stats. They should not scale like percentage stats because each extra projectile, construct, dash, echo, link, or summon can multiply the whole build.

Recommended handling:

- `effect_count` item uses bonus-effect chance, not unconditional global +5 effects.
- `active_cap` item uses overflow grace and a small capstone cap increase, not unconditional global +5 active objects.
- `base_stat_boost` item affects only damage, size, duration, range, cadence, and control_strength; it does not affect crit, XP, dash count, revive, effect_count, or active_cap.
- `dash_count` can grant extra dash charges, but should be balanced around player safety and dash payoff damage.

## Endless Overflow Drafts

Normal upgrades continue after level 50 while they remain available. Endless should not raise the weapon or item level caps.

Rules:

- Weapons remain capped at level 10.
- Items remain capped at level 5.
- A base weapon can still evolve once per run.
- New weapon and new item cards stop when their slots are full.
- Weapon and item upgrade cards stop when all owned entries are capped.
- Overflow drafts begin only after no normal weapon, item, or evolution upgrades remain.

Overflow drafts can offer:

- small repeatable stat boosts,
- temporary Page Takeover attacks,
- heals or shields,
- Pigment, Treats, or Sticker rewards,
- endless risk/reward modifiers.

## Long-Term Meta Progression

Permanent progression lives in the Wonder Box. Each node has 5 tiers. These bonuses are profile-wide and should be smaller than in-run item bonuses so drafts still matter.

### Meta Progression Rules

- Meta bonuses apply at run start.
- Meta bonuses stack additively with item bonuses unless a stat says otherwise.
- Crit chance respects the 75% global cap.
- Crit multiplier respects the 4x final multiplier cap.
- Flat-count meta tracks use controlled breakpoints or chance-based relief, not raw +1 every tier.
- The Wonder Box should not replace in-run build decisions. It should make weak starts less punishing and unlock more build consistency over time.

| Stat Track | Tier 1 | Tier 2 | Tier 3 | Tier 4 | Tier 5 | Notes |
|---|---:|---:|---:|---:|---:|---|
| damage | +2% | +4% | +6% | +8% | +10% | Applies to player-owned damage. |
| size | +2% | +4% | +6% | +8% | +10% | Area, width, footprint. |
| duration | +2% | +4% | +6% | +8% | +10% | Includes lifetime. |
| range | +2% | +4% | +6% | +8% | +10% | Target, placement, travel, link, seek reach. |
| cadence | +2% | +4% | +6% | +8% | +10% | Faster weapon cadence. |
| proc_chance | +1 pp | +2 pp | +3 pp | +4 pp | +5 pp | Per-effect caps still apply. |
| control_strength | +2% | +4% | +6% | +8% | +10% | Slow, pull, push, snare, knockback. |
| effect_count | +5% bonus effect chance | +10% | +15% | +20% | +25% | Controlled substitute for global flat count. |
| active_cap | +5% overflow grace | +10% | +15% | +20% | +25% | Chance to avoid immediate replacement when at cap. |
| luck | +2% | +4% | +6% | +8% | +10% | Affects rarity/draft odds, not guaranteed outcomes. |
| armor | +1 | +2 | +3 | +4 | +5 | Flat damage mitigation or armor formula input. |
| max_health | +5 | +10 | +15 | +20 | +25 | Starting max health. |
| health_regen | +0.1/s | +0.2/s | +0.3/s | +0.4/s | +0.5/s | Passive health recovery. |
| xp_magnet_range | +5% | +10% | +15% | +20% | +25% | Pickup radius for XP motes. |
| xp_gain_rate | +3% | +6% | +9% | +12% | +15% | Multiplies XP gained. |
| crit_chance | +1 pp | +2 pp | +3 pp | +4 pp | +5 pp | Global crit chance, cap 75%. |
| crit_damage | +5% | +10% | +15% | +20% | +25% | Adds to crit multiplier bonus, final cap 4x. |
| dash_range | +3% | +6% | +9% | +12% | +15% | Dash distance. |
| dash_count | emergency charge after Page Event | +1 emergency charge per 10:00 | +1 max dash charge | emergency charge after boss warning | +1 max dash charge | Breakpoint track, not linear +1 each tier. |
| dash_cooldown | -3% | -6% | -9% | -12% | -15% | Dash cooldown only. Does not affect weapon cadence. |
| movement_speed | +2% | +4% | +6% | +8% | +10% | Player movement speed. |
| base_stat_boost | +1% | +2% | +3% | +4% | +5% | Applies only to damage, size, duration, range, cadence, and control_strength. |
| revive | unlock 1 revive at 20% health | revive at 30% | revive at 40% | revive at 50% | revive at 60% and cleanse | One revive per run unless a separate source grants more. |

## Anti-Frustration Design Around Required Items

### Problem

Strict build recipes can fail because:

- the player never sees the exact required item,
- the required item is weak outside the recipe,
- the player locks item slots before realizing what the build needs,
- late-game drafts offer dead cards instead of build completion.

### Design Solution

Use tag-based build completion instead of item-ID recipes.

| Friction | Solution |
|---|---|
| Need one exact item | Any level 5 item with a compatible catalyst family can support the weapon. |
| Needed item feels bad | Every item has a useful level 1 stat effect and level 5 capstone. |
| Bad draft luck | Add first-item guarantee, catalyst pity, and upgrade weighting for near-complete items. |
| Player cannot read build path | Draft cards show compatible owned weapons and evolution hints. |
| Item slots fill too early | Let Page Event rewards weight compatible item upgrades and avoid offering irrelevant new items. |
| Wanted build still misses | Add reroll/banish sources through Luck and Wonder Box progression. |

### Optional Future Safety Valve

If build frustration remains after draft weighting, add one rare Page Event reward:

**Catalyst Attunement**

- Appears only from Page Events or treasure rewards, not normal level-ups.
- Lets the player choose one owned level 5 item.
- Adds one temporary catalyst family for the current run from a short list of families compatible with owned level 8+ weapons.
- Does not change the item's normal identity or permanent unlocks.

This should be a fallback safety valve, not the main build path.

## Locked Review Decisions

- MVP uses 23 active passive items.
- MVP keeps 5 passive item slots.
- MVP starts runs with 0 passive items.
- Normal passives have 2 catalyst tags.
- `Foundational Keepsake` has all 10 catalyst tags at level 5.
- Item find rarity only controls initial find rate.
- Owned item upgrade cards grant fixed +1 item level.
