# ADR-0005: Pooled Damage Feedback

## Status

Accepted for first playable.

## Context

Damage Numbers and Object Pooling GDDs require resolved damage facts to create pooled visuals rather than gameplay systems instantiating presentation directly.

## Decision

Add a generic `SimpleObjectPool` and a `DamageNumberManager` under `RunRoot/DamageNumbers`. The manager subscribes to `RuntimeEventBus.damage_resolved`, requests pooled `DamageNumberVisual` `Label3D` instances, and exposes debug counters for active, spawned, and dropped visuals.

## Consequences

- Damage feedback is event-driven and does not recompute damage.
- Pool cap behavior can degrade presentation without changing combat.
- First playable uses primitive text-only `Label3D` visuals; final font/art remains future UI work.
