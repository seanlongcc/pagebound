# ADR-0004: Runtime Events And Damage Model

## Status

Accepted for first playable.

## Context

Damage GDD requires all health changes to pass through one resolver. Runtime Event Bus GDD requires typed facts for damage, death, XP, and Pagecraft presentation listeners without weapon/enemy health hacks.

## Decision

Use a scene-owned `RuntimeEventBus` node created by `FirstPlayableRuntime`. Use `DamageModel` as an injected `RefCounted` service that resolves requests against `HealthComponent` nodes and emits damage/death facts. `HealthComponent` owns current/max health and guarantees one death fact per life.

## Consequences

- Weapons, enemies, and Pagecraft will call `DamageModel.apply_damage()` instead of mutating health.
- Damage numbers and XP rewards can subscribe to event facts later.
- Tests can instantiate bus, model, and health components without loading the main scene.
