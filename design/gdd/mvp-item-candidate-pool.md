# MVP Item Candidate Pool and Meta Stat Progression

> Status: Draft review document  
> Owner: Design  
> Source beads: pagebound-nge, pagebound-xhi
> Last updated: 2026-05-13

## Purpose

This document captures the active MVP item/stat model based on the latest item, draft, and endless-mode decisions. It answers current design questions, defines the 23-entry passive item pool, defines 5-tier long-term meta progression tracks, and adds rules to reduce "missed required item" frustration.

This is the active MVP passive-item and Wonder Box stat-track source for exact roster rows, L1-L5 values, capstone bonuses, catalyst tags, and long-term meta rank values. The root GDD and focused system docs should reference this sheet instead of duplicating those tables.

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
- Treat normal item stat bonuses as global player-owned stat bonuses; catalyst tags drive evolutions and draft synergy, not stat scope.
- Keep the broadest raw-count stats - `effect_count`, `active_cap`, and `dash_count` - limited to authored eligible channels.
- Keep `base_stat_boost` Legendary-only and out of Wonder Box meta progression.
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
| Around 10:00-12:00 | Focused builds can reasonably reach a first level 5 passive item; casual or unfocused runs may reach this closer to 15:00. |
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

### Stat and Terminology Rules

- Normal passive item stat bonuses apply globally to player-owned sources unless a stat explicitly says otherwise.
- Catalyst tags are evolution and draft-synergy tags. They do not limit normal item stat bonuses.
- Level 5 normally reaches +50% or an equivalent fifth-step value plus a modest capstone. `Foundational Keepsake` is the exception because it affects multiple core stats and carries all catalyst tags.
- `cadence` means attack/cast rate, not cooldown reduction.
- Chance bonuses use player-facing `+X% chance` wording. They add directly to the base chance and still respect each effect's cap.
- `proc_chance` means trigger chance for authored optional effects such as spark release, node spawn, pollen chance, fork chance, chain eruption, absorb chance, ignite chance, giant cast, or dash loop effects.
- `effect_count` only affects authored eligible count channels such as extra projectiles, pulses, echoes, links, sparks, or repeated effects.
- `active_cap` only affects authored eligible active-object channels such as living pools, beacons, sentries, wells, gates, towers, zones, constructs, or summons.
- `dash_count` adds dash charges. Dash recharge time refills spent charges; if a charge is available, the player can dash without waiting for recharge.
- Base dash recharge time is 2.0s per charge. Baseline dash invulnerability is 0.15s.
- Base player max HP is 1000 for the MVP balance scale.
- Crit chance is global, additive, and capped at 75%.
- Base crit multiplier is 2.0x. Crit damage adds to that multiplier; for example, +50% crit damage changes 2.0x to 2.5x. Final crit multiplier is capped at 4.0x.
- Luck uses raffle math: Common/basic weights stay unchanged, Uncommon-and-higher draft rarity weights multiply by `1 + luck`, then the table is normalized.

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
| 1 | Candle Spark | Common | damage | Firelight, Light | +10% | +20% | +30% | +40% | +50%; first player-owned hit per enemy deals +10% damage |
| 2 | Cloud Seed | Common | size | Bloom, Wonder | +10% | +20% | +30% | +40% | +50%; every 5th eligible cast gets extra +50% size |
| 3 | Dream Thread | Common | duration | Dream, Thread | +10% | +20% | +30% | +40% | +50%; every 5th eligible timed effect gets extra +50% duration |
| 4 | Ribbon Spool | Common | range | Thread, Star | +10% | +20% | +30% | +40% | +50%; outer 25% range hits/effects are 10% stronger |
| 5 | Moon Button | Common | cadence | Moon, Echo | +10% | +20% | +30% | +40% | +50%; +10% cadence while HP is at or below 50% |
| 6 | Firefly Charm | Uncommon | proc_chance | Light, Wonder | +10% chance | +20% chance | +30% chance | +40% chance | +50% chance; first failed eligible trigger retries after cooldown |
| 7 | Seashell Lullaby | Uncommon | control_strength | Water, Echo | +10% | +20% | +30% | +40% | +50%; eligible control touch applies +10% damage taken for 1s |
| 8 | Acorn Charm | Epic | effect_count | Bloom, Star | +1 | +2 | +3 | +4 | +5; eligible casts have 20% chance for one extra effect |
| 9 | Pocket Locket | Epic | active_cap | Dream, Wonder | +2 | +4 | +6 | +8 | +10; cap-replaced objects persist as faded echoes for 2s |
| 10 | Lucky Pebble | Rare | luck | Star, Wonder | +20% Luck | +40% Luck | +60% Luck | +80% Luck | +100% Luck; promote one weapon-upgrade draft card to Epic once per run |
| 11 | Blanket Pin | Common | armor | Thread, Light | 10% mitigation | 20% mitigation | 30% mitigation | 40% mitigation | 50% mitigation; post-hit 1s invulnerability, 60s cooldown |
| 12 | Paper Heart | Common | max_health | Bloom, Light | +100 HP | +200 HP | +300 HP | +400 HP | +500 HP; later run level-ups heal 100 HP |
| 13 | Dewdrop Thimble | Uncommon | health_regen | Water, Bloom | +5 HP/s | +10 HP/s | +15 HP/s | +20 HP/s | +25 HP/s; drops 100 HP dewdrop every 60s, max 3 active |
| 14 | Firefly Jar | Uncommon | xp_magnet_range | Light, Wonder | +10% | +20% | +30% | +40% | +50%; pulls Color Motes from Page Event area after event |
| 15 | Storybook Key | Uncommon | xp_gain_rate | Dream, Star | +10% | +20% | +30% | +40% | +50%; Page Event success tags current enemies for 30s, tagged kills drop double XP |
| 16 | Wooden Star | Rare | crit_chance | Star, Light | +10% chance | +20% chance | +30% chance | +40% chance | +50% chance; crits have 1% execute chance on normal non-elite, non-boss enemies |
| 17 | Tiny Crown | Rare | crit_damage | Light, Wonder | +10% | +20% | +30% | +40% | +50%; crit kills splash 50% overkill damage in a small area |
| 18 | Feather Cape | Uncommon | dash_range | Thread, Moon | +10% | +20% | +30% | +40% | +50%; dash leaves a 2s slow trail |
| 19 | Button Boots | Rare | dash_count | Wonder, Thread | +1 charge | +1 charge | +2 charges | +2 charges | +3 charges; dashing through player Pagecraft refunds 1 charge, 10s cooldown |
| 20 | Moonlace Stopwatch | Rare | dash_recharge | Moon, Echo | -10% | -20% | -30% | -40% | -50%; next player-owned hit after dash deals +50% damage |
| 21 | Paper Pinwheel | Common | movement_speed | Water, Bloom | +10% | +20% | +30% | +40% | +50%; after dash ends, +25% movement speed for 1s |
| 22 | Foundational Keepsake | Legendary | base_stat_boost | Firelight, Moon, Star, Dream, Thread, Bloom, Water, Light, Echo, Wonder | +2% | +4% | +6% | +8% | +10%; all catalyst tags active and opens one Legendary weapon-upgrade draft |
| 23 | Second Bookmark | Epic | low_health_ward | Dream, Light | 20% HP trigger, 100 HP/s for 2s, 60s cooldown, 0.5s invuln | 30% trigger, 3s regen, 55s cooldown, 0.6s invuln | 40% trigger, 4s regen, 50s cooldown, 0.7s invuln | 50% trigger, 5s regen, 45s cooldown, 0.8s invuln | 60% trigger, 6s regen, 40s cooldown, 1s invuln; one full-HP revive, cleanse, 2s invuln |

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

- `effect_count` uses direct `+1/+2/+3/+4/+5`, but only on authored eligible count channels.
- `active_cap` uses direct `+2/+4/+6/+8/+10`, but only on authored eligible active-object channels.
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
- Wonder Box does not include `base_stat_boost`, `revive`, `effect_count`, `active_cap`, or `dash_count` stat tracks.
- Wonder Box Luck uses the same raffle math as Lucky Pebble, at half item strength.
- The Wonder Box should not replace in-run build decisions. It should make weak starts less punishing and unlock more build consistency over time.

| Stat Track | Tier 1 | Tier 2 | Tier 3 | Tier 4 | Tier 5 | Notes |
|---|---:|---:|---:|---:|---:|---|
| damage | +5% | +10% | +15% | +20% | +25% | Applies to player-owned damage. |
| size | +5% | +10% | +15% | +20% | +25% | Area, width, footprint. |
| duration | +5% | +10% | +15% | +20% | +25% | Includes lifetime. |
| range | +5% | +10% | +15% | +20% | +25% | Target, placement, travel, link, seek reach. |
| cadence | +5% | +10% | +15% | +20% | +25% | Faster weapon attack/cast rate. |
| proc_chance | +5% chance | +10% chance | +15% chance | +20% chance | +25% chance | Additive trigger chance; per-effect caps still apply. |
| control_strength | +5% | +10% | +15% | +20% | +25% | Slow, pull, push, snare, knockback. |
| luck | +10% Luck | +20% Luck | +30% Luck | +40% Luck | +50% Luck | Draft rarity raffle modifier only. |
| armor | 5% mitigation | 10% mitigation | 15% mitigation | 20% mitigation | 25% mitigation | Incoming damage mitigation. |
| max_health | +50 HP | +100 HP | +150 HP | +200 HP | +250 HP | Starting max health. |
| health_regen | +2 HP/s | +4 HP/s | +6 HP/s | +8 HP/s | +10 HP/s | Passive health recovery. |
| xp_magnet_range | +5% | +10% | +15% | +20% | +25% | Pickup radius for XP motes. |
| xp_gain_rate | +5% | +10% | +15% | +20% | +25% | Multiplies XP gained. |
| crit_chance | +5% chance | +10% chance | +15% chance | +20% chance | +25% chance | Global crit chance, cap 75%. |
| crit_damage | +5% | +10% | +15% | +20% | +25% | Adds to crit multiplier bonus, final cap 4x. |
| dash_range | +5% | +10% | +15% | +20% | +25% | Dash distance. |
| dash_recharge | -5% | -10% | -15% | -20% | -25% | Dash charge recharge time only. Does not affect weapon cadence. |
| movement_speed | +5% | +10% | +15% | +20% | +25% | Player movement speed. |

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
