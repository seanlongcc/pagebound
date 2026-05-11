# ADR-0001: Resource Schema Foundation

## Status

Accepted for first playable.

## Context

Pagebound needs content data to be validated before runtime systems consume it. The Resource Data Schemas GDD requires stable lowercase snake_case IDs, shared tag vocabulary, exact weapon level counts, and headless smoke validation.

## Decision

Implement schema foundation as typed Godot `Resource` classes under `src/data/`, with a scene-independent `SchemaRegistry` and `SchemaValidationResult`. Runtime systems may receive validated `WeaponData` and `EnemyData` objects, but damage, weapon firing, enemy AI, and Pagecraft simulation remain outside the schema layer.

First playable uses `PrototypeContentFactory` to register primitive placeholder content in code. This keeps the loop bootable before full `.tres` content authoring lands.

## Consequences

- Schema smoke tests can run headlessly without loading the main scene.
- IDs and tag references have one validation path.
- Prototype data is replaceable with `.tres` loading later without changing consumers.
- Full MVP counts for 20 weapons, 20 passives, pets, chapters, and events remain future content work; the current foundation validates the minimal first-playable subset.
