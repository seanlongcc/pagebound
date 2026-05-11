# ADR-0006: First Combat Prototype

## Status

Accepted for first playable.

## Context

Weapons, Enemies, Damage, XP, and Feedback GDDs require a minimal loop where an enemy spawns, chases the player, an auto weapon hits through the damage model, damage numbers appear, and death creates an XP reward stub.

## Decision

Use `FirstPlayableRuntime` to instantiate one `ChaserEnemy` under `RunRoot/Actors/Enemies` and one `AutoWeaponManager` under `RunRoot/Projectiles`. The weapon consumes `WeaponData`, finds the nearest living enemy, and calls `DamageModel.apply_damage()`. The enemy owns movement only; health/death remains in `HealthComponent` and `DamageModel`. XP is tracked as a runtime stub from `RuntimeEventBus.entity_died`.

## Consequences

- Combat is playable without final spawner/director systems.
- Weapon/enemy scripts do not mutate health directly.
- XP reward plumbing exists without draft UI or full progression yet.
