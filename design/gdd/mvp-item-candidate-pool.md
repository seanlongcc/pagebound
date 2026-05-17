# MVP Item Candidate Pool and Meta Stat Progression

> Status: Draft review document  
> Owner: Design  
> Source beads: pagebound-nge, pagebound-xhi
> Last updated: 2026-05-14

## Purpose

This document captures the active MVP item/stat model based on the latest item and draft decisions. It answers current design questions, defines the 23-entry passive item pool, defines 5-tier long-term meta progression tracks, and keeps items useful without relying on a pity system.

This is the active MVP passive-item and Wonder Box stat-track source for exact roster rows, L1-L5 values, capstone bonuses, catalyst tags, and long-term meta rank values. The root GDD and focused system docs should reference this sheet instead of duplicating those tables.

Design source consulted: `PAGEBOUND_CODEX_GDD_v1_5.md` sections 12, 20, and 37; `design/gdd/passive-items-and-drafts.md`; `design/gdd/xp-leveling-and-upgrade-drafts.md`; `design/gdd/evolution-system.md`; `design/gdd/damage-and-status-model.md`; `design/gdd/mvp-weapon-candidate-pool.md`; first polished exemplar grilling session, 2026-05-14.

## Working Answers

| Question | Working Answer | Recommendation |
|---|---|---|
| When do players get items? | Items appear in 3-choice run level-up drafts and successful Page Event reward drafts. Normal cards roll `50%` upgrade / `50%` new gear; gear splits `50%` new weapon / `50%` new item before legality redirects. Page Event rewards include at least one new gear card if legal unowned gear exists and a slot is open. | Keep the normal draft simple. No fixed item levels and no pity. |
| Do items level by collecting multiples? | Not by physical duplicate pickups by default. The player levels items by selecting item upgrade cards from drafts. | Keep this consistent with weapon leveling: one selected card equals one level. |
| Is there a max unique item cap during a run? | Yes. MVP should keep 5 unique passive item slots and item level cap 5. | Keep 5 slots for readability and HUD clarity. Consider a later Wonder Box unlock for a starter item option before adding a 6th passive slot. |
| How do catalysts relate to items? | Items carry catalyst tags from level 1, but only level 5 items expose full catalyst value for weapon evolution eligibility. Items are not consumed by evolutions. | Keep catalysts broad and tag-based. Do not use strict 1:1 weapon-item recipes. |
| How does item rarity work? | Each item has an initial find rarity for content identity and future tuning. Current approved draft canon does not use rarity to change the `50/50` upgrade/new gear split or the `50/50` weapon/item split. | Keep rarity metadata, but do not add rarity weighting until a separate draft-weighting pass approves it. |
| How do we avoid "I needed one item and never got it"? | Current answer is broad item usefulness plus Page Event new-gear guarantee, not pity. Players can take or skip normal gear offers like a normal draft. | Treat every item as a real build piece first and an evolution catalyst second. |

## Recommendation

Use this structure for MVP review:

- Keep 5 unique passive item slots.
- Keep 5 item levels.
- Keep 10 catalyst families from the weapon candidate document: `Firelight`, `Moon`, `Star`, `Dream`, `Thread`, `Bloom`, `Water`, `Light`, `Echo`, `Wonder`.
- Use 23 active passive items.
- Use initial find rarity split: 8 Common, 6 Uncommon, 5 Rare, 3 Epic, 1 Legendary.
- Keep initial find weights as inactive future tuning metadata: Common 60, Uncommon 25, Rare 9, Epic 5, Legendary 1.
- Give normal passives 2 catalyst tags.
- Give Legendary `Foundational Keepsake` all 10 catalyst tags at level 5.
- Treat normal item stat bonuses as global player-owned stat bonuses; catalyst tags drive evolutions and future compatibility hints, not stat scope.
- Keep the broadest raw-count stats - `effect_count`, `active_cap`, and `dash_count` - limited to authored eligible channels.
- Keep `base_stat_boost` Legendary-only and out of Wonder Box meta progression.
- Full-run build targets remain tuning-owned after the `50/50` draft model is implemented.

## In-Run Item Rules

### Acquisition

Passive item cards can appear from:

- normal run level-up drafts,
- Page Event reward drafts.

Draft defaults:

- Normal drafts still show exactly 3 choices.
- Normal draft cards roll `50%` upgrade and `50%` new gear before legality redirects.
- New gear rolls split `50%` new weapon and `50%` new passive item before legality redirects.
- Upgrade rolls split `50%` owned weapon upgrade and `50%` owned item upgrade before legality redirects.
- Successful Page Event reward drafts include at least one new gear card if legal unowned gear exists and a slot is open.
- A new passive item can appear if the player owns fewer than 5 passive items.
- A +1 item level card can appear if the player owns that item below level 5.
- Initial item find rarity is display/future tuning metadata in the current approved draft canon.
- Owned item upgrade cards grant fixed +1 item level.
- A level 5 item unlocks its full catalyst value.
- A level 5 item is never consumed by evolution.
- If every item slot is full, new item cards stop appearing unless a later reward explicitly offers replacement.

### Timing Targets

| Run Timing | Item Target |
|---|---|
| First normal drafts | Items may appear through the normal `50%` new gear lane if legal. |
| First successful Page Event | Guarantees at least one new gear card if legal unowned gear exists and a slot is open. In the first polished exemplar, this points to `Candle Spark` if still unowned. |
| Full-run tuning | Exact item count by 5/10/20/30 minutes must be remeasured after the `50/50` model is implemented. |
| Endless | Normal upgrades continue while available; overflow drafts start only after no normal weapon/item choices remain. |

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
- Catalyst tags are evolution and future compatibility-hint tags. They do not limit normal item stat bonuses.
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
- Luck does not change the current `50/50` upgrade/gear split or the `50/50` weapon/item split.

## Build Reliability Rules

These rules address missed-item frustration without adding pity.

### Broad Catalyst Matching

Each weapon has two catalyst families. Each item has two catalyst families. Evolutions require a matching catalyst family, not a specific item ID.

Example:

```text
Level 10 Waxlight Comet
+ any level 5 item with Firelight or Light
= compatible evolution options can appear
```

### Draft Reliability

Current draft reliability comes from:

- normal level-up drafts always allowing legal new gear through the `50%` lane,
- Page Event rewards guaranteeing at least one new gear card when legal,
- broad catalyst families,
- useful item effects even when no evolution happens.

There is no pity system in the current approved model.

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

- Find rarity is inactive future tuning metadata in the current approved draft canon.
- Once an item is owned, its upgrade cards grant fixed +1 item level.
- Upgrade-card rarity and luck do not change the current `50/50` category split or the amount of item levels gained.
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
- Overflow drafts begin only after no normal weapon or item choices remain.

Overflow drafts can offer:

- small repeatable `+5%` global stat crumbs in the current approved draft canon.

## Long-Term Meta Progression

Permanent progression lives in the Wonder Box. Each node has 5 tiers. These bonuses are profile-wide and should be smaller than in-run item bonuses so drafts still matter.

### Meta Progression Rules

- Meta bonuses apply at run start.
- Meta bonuses stack additively with item bonuses unless a stat says otherwise.
- Crit chance respects the 75% global cap.
- Crit multiplier respects the 4x final multiplier cap.
- Wonder Box does not include `base_stat_boost`, `revive`, `effect_count`, `active_cap`, or `dash_count` stat tracks.
- Wonder Box Luck affects future rarity tuning only until a separate draft-weighting pass approves raffle math.
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
| Bad draft luck | Let normal drafts stay random; use Page Event new-gear guarantee when legal. |
| Player cannot read build path | Draft cards show compatible owned weapons and evolution hints. |
| Item slots fill too early | Player chooses whether to take new gear or upgrades from drafts. |
| Wanted build still misses | Accept this as normal draft variance unless future testing proves it breaks fun. |

## Locked Review Decisions

- MVP uses 23 active passive items.
- MVP keeps 5 passive item slots.
- MVP starts runs with 0 passive items.
- Normal passives have 2 catalyst tags.
- `Foundational Keepsake` has all 10 catalyst tags at level 5.
- Item find rarity is inactive future tuning metadata under the current approved draft canon.
- Owned item upgrade cards grant fixed +1 item level.
