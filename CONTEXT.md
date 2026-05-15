# Pagebound Combat Balance Context

This context defines shared combat-balance language for Pagebound's first playable weapon, enemy, dash payoff, and evolution tuning.

## Language

**Starter baseline weapon**:
The first-run weapon used as the opening kill-rate and enemy HP tuning reference.
_Avoid_: anchor weapon, starter Waxlight, baseline anchor

**Star Sticker Swarm**:
The starter baseline weapon for current tuning, built around reliable early hits that later grow into a sticker network.
_Avoid_: anchor, rare side weapon

**Waxlight Comet**:
An early AoE/Pagecraft lane weapon, not the current starter baseline weapon.
_Avoid_: starter baseline, single-target anchor

**Star node**:
A placed Star Sticker object on the page or enemy that can support sticker pop, ricochet, dash payoff, or constellation behavior.
_Avoid_: anchor

**Dash payoff**:
A weapon-specific reward triggered by dashing through or near that weapon's Pagecraft objects.
_Avoid_: dash bonus, dash proc

**Pagecraft visibility unlock**:
The weapon level where weapon-created Pagecraft objects first become visible and interactable on the page.
_Avoid_: show pagecraft

**Attack visual**:
A short-lived visual effect that communicates a weapon hit or projectile, without creating a persistent Pagecraft object.
_Avoid_: Pagecraft mark when the effect cannot be dashed through or reused

**Target range**:
How far a weapon can acquire a target from the player. This does not mean AoE radius, mark radius, dash activation padding, or Star node ricochet range.
_Avoid_: range when talking about mark size or node reach

Current first-playable defaults:
- **Star Sticker Swarm target range**: `8.0m`
- **Waxlight Comet target range**: `6.5m`

**Range upgrade scope**:
A weapon `range` upgrade applies to every range-bearing part of that weapon currently unlocked. `size` upgrades still own AoE radius and mark radius.
_Avoid_: separate hidden range upgrades for each sub-mechanic

Current first-playable rules:
- **Star Sticker Swarm range** scales target range, and at L5+ also scales Star node ricochet range.
- **Waxlight Comet range** scales target range, and at L10+ also scales connected-mark activation reach.
- **Waxlight Comet mark radius** is scaled by `size`, not `range`.

**Star ricochet model**:
The L5+ Star Sticker follow-up where the newly placed or selected Star node fires at one nearby enemy.
_Avoid_: multi-hop enemy-to-node-to-enemy chain

Current first-playable rules:
- **L1-L4**: Star hits one enemy and creates no node.
- **L5+**: Star hit creates a node at the hit position, then that node fires one ricochet at a nearby enemy for `50%` damage.
- **L10+**: when a node fires a ricochet, that same node fires one extra non-node star at another nearby enemy for `50%` damage.
- **Dash volleys** can use existing nodes for ricochet, but do not create nodes.

**Opening attack pacing**:
The level-1 cooldown baseline used before spawn pressure is retuned upward.
_Avoid_: raising spawn pressure before current weapon mechanics are playtested

Current first-playable defaults:
- **Star Sticker Swarm cooldown**: `0.9s`
- **Waxlight Comet cooldown**: `0.95s`
- **Enemy spawn curve**: unchanged until playtest proves weapon slowdown is insufficient.

**Waxlight AoE damage**:
Waxlight Comet's impact AoE damage applies at full current weapon damage to every enemy inside the AoE, including secondary targets.
_Avoid_: reduced secondary splash damage

**XP range debug circles**:
Developer-only toggle visuals showing pickup collection/fetch reach, not player-facing HUD.
_Avoid_: always-on XP range UI

Current first-playable debug ranges:
- **Player XP pickup radius**: `3.0m`
- **Dog T1 fetch radius**: `6.0m` (100% larger than player XP pickup radius)

**Dog committed fetch**:
Once Dog starts moving toward an eligible pickup, player movement out of fetch range does not cancel that action.
_Avoid_: re-checking player-to-pickup range during active Dog fetch

## Relationships

- **Star Sticker Swarm** is the current **starter baseline weapon**.
- **Waxlight Comet** is balanced against the **starter baseline weapon**, not used as the baseline itself.
- A **Dash payoff** depends on weapon-created Pagecraft objects such as **Star nodes**.
- **Star nodes** and **Waxlight marks** use an L5 **Pagecraft visibility unlock** in the current design.
- **Waxlight Comet** still has an **Attack visual** before L5; it just does not leave persistent Waxlight marks until L5.
- **Waxlight Comet** should not have a longer **target range** than **Star Sticker Swarm**.
- **Range upgrade scope** follows currently unlocked mechanics, so later Pagecraft systems can inherit the same weapon range upgrade without adding a new upgrade type.
- **Star ricochet model** uses a node as the follow-up origin, not a multi-hop bounce chain.
- **Opening attack pacing** slows level-1 weapon cadence before raising enemy spawn pressure.
- **Waxlight AoE damage** is full damage for every target in the impact AoE; secondary splash does not have a damage penalty.
- **XP range debug circles** are shown only when a debug toggle is enabled.
- **Dog committed fetch** only ends early if the pickup is no longer collectible.

## Example Dialogue

> **Dev:** "Should opening Wax Imp HP be based on Waxlight Comet damage?"
> **Domain expert:** "No. Opening HP should be based on **Star Sticker Swarm** because it is the **starter baseline weapon**."

## Flagged Ambiguities

- "anchor" was used for both a weapon role and placed map objects; resolved: use **starter baseline weapon** for the role and **Star node** for placed Star Sticker objects.
- "starter Waxlight" conflicted with current intent; resolved: **Waxlight Comet** is an AoE/Pagecraft lane weapon, while **Star Sticker Swarm** is the **starter baseline weapon**.
