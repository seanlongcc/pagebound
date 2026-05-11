# Resource Data Schemas

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Simple Controls, Deep Pagecraft

## Overview

`Resource Data Schemas` defines Pagebound's authorable content contracts for characters, weapons, passive items, pets, enemies, bosses, chapters, page events, upgrades, currencies, and audio metadata. It exists so gameplay systems consume consistent, validated data instead of hardcoded content rules. The system owns what fields content must provide, how IDs/tags/levels/rarities reference each other, and what validation failures block a build or smoke test. Players do not interact with schemas directly; they feel the result as readable upgrade drafts, reliable evolutions, coherent Pagecraft tags, consistent pet progression, and content that behaves the same way across runs.

## Player Fantasy

Players should never notice Resource Data Schemas as a system. They should feel its effect as trust: every draft card makes sense, every weapon level behaves as promised, every pet tier improves predictably, and every Pagecraft tag connects cleanly to the fantasy of redrawing the page. Good schemas make Pagebound feel generous and coherent because content can grow without becoming random, contradictory, or brittle.

## Detailed Design

### Core Rules

1. Resource Data Schemas define content shape, references, validation, and authoring rules only. They do not own runtime combat logic, draft weighting, enemy AI, save migration behavior, UI layout, or Pagecraft simulation.
2. Pagebound content data is authored as Godot `Resource` assets (`.tres`) for characters, weapons, passive items, pets, enemies, bosses, chapters, page events, upgrades, currencies, and audio metadata.
3. Every resource has a stable `id` string. IDs are lowercase snake_case and never reused for different content.
4. Display names, descriptions, icons, VFX references, SFX references, and localization keys are data references, not gameplay logic.
5. Cross-resource references use IDs, not scene paths or direct object references, unless the referenced object is an asset-only dependency such as an icon, audio clip, or scene prefab.
6. Tags are shared vocabulary. Weapon materials, evolution catalysts, Pagecraft materials, enemy traits, draft pools, pet traits, and chapter themes must reference approved tag IDs.
7. Weapons must define exactly 10 level entries. Level 1 is base behavior, level 5 is a major breakpoint, and level 10 is capstone/evolution eligibility.
8. Passive items must define exactly 5 level entries. Level 5 enables catalyst tags for evolution checks.
9. Pets must define exactly 5 tier entries and at least one attack behavior reference.
10. Characters must define starter weapon, dash profile reference, passive trait reference, preferred material tag, stat profile, unlock condition, and 10 mastery entries.
11. Chapters must define finite map metadata, visual identity references, boss/finale reference, chapter-specific Page Event pool, unique enemies, restoration track reference, and pet opportunity references.
12. Page Events must define timing eligibility, objective type, duration, success rewards, failure consequence, and reward pools.
13. Enemies and bosses must define stat profile references, movement/AI profile references, reward/drop profile references, and Pagecraft interaction tags. The schema records references; AI/combat systems own behavior.
14. Schema validation runs in editor/headless smoke paths and fails loudly on missing IDs, duplicate IDs, wrong level counts, unknown tags, missing required references, invalid ranges, or deprecated content used in active pools.
15. MVP schema completeness requires room for all 20 shared weapons and all 20 passive items, even if some assets are placeholder.
16. Runtime systems may cache validated resources into fast lookup maps, but authoring source remains the `.tres` resource set.
17. Deprecated resources remain loadable for saves and migration, but cannot appear in new run draft pools unless explicitly marked `allow_in_new_runs`.
18. No schema field may require a downstream system to exist for the shell to boot. Missing gameplay systems are allowed; invalid data shape is not.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `DraftContent` | Resource exists but has not passed validation. | `LocalValidationFailed`, `ValidatedContent` |
| `LocalValidationFailed` | Resource has schema errors. | `DraftContent` |
| `ValidatedContent` | Resource passes local field, type, and reference validation. | `RegisteredContent`, `DeprecatedContent` |
| `RegisteredContent` | Resource is part of active content registries and can appear in pools. | `RuntimeLoaded`, `DeprecatedContent` |
| `RuntimeLoaded` | Runtime systems have loaded validated content into lookup/cache structures. | `RegisteredContent`, `MigrationRequired` |
| `DeprecatedContent` | Resource remains available for old saves but is blocked from normal new-run pools. | `MigrationRequired`, `RegisteredContent` |
| `MigrationRequired` | Resource version or ID mapping requires save/profile migration. | `RegisteredContent`, `DeprecatedContent` |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Godot Project Shell | Upstream | Shell provides boot timing only. Schemas do not modify `Main.tscn` topology. |
| Damage and Status Model | Downstream | Consumes stat profiles, damage tags, status tags, resistance tags, and combat metadata. |
| Weapons and Auto-Attacks | Downstream | Consumes weapon IDs, 10 level entries, material tags, attack behavior references, Pagecraft mark references, dash interaction references, and evolution paths. |
| Passive Items and Drafts | Downstream | Consumes passive IDs, 5 level entries, catalyst tags, stat modifier references, and draft metadata. |
| XP, Leveling, and Upgrade Drafts | Downstream | Consumes draft pool tags, rarity/weight metadata, unlock gates, level caps, and 3-choice draft eligibility metadata. |
| Evolution System | Downstream | Consumes weapon evolution paths and item catalyst tags. It owns eligibility evaluation and draft presentation. |
| Pets and Companion Combat | Downstream | Consumes pet tier data, attack behavior references, unlock quest references, Treat costs, and Pagecraft interaction tags. |
| Enemies and AI Movement | Downstream | Consumes enemy stat profiles, movement profile references, enemy tags, reward/drop profiles, and chapter inclusion data. |
| Run Director and Finite Spawning | Downstream | Consumes chapter enemy pools, spawn budget metadata, boss timing references, and event schedule metadata. |
| Page Events and Objectives | Downstream | Consumes Page Event objective data, reward pools, failure consequence references, and chapter/event eligibility. |
| Save, Profile, and Migration | Downstream | Consumes stable IDs, resource versions, deprecated ID mappings, unlock IDs, and migration metadata. |
| In-Run HUD and Draft UI | Downstream | Consumes display names, short descriptions, icons, rarity display, level text, evolution preview metadata, and localization keys. |
| Audio and Music Layers | Downstream | Consumes audio metadata references only; audio systems own playback and mix behavior. |
| Asset Pipeline | Downstream/Supporting | Uses icon, VFX, SFX, and source asset references to validate imported assets and provenance. |
| Test Setup | Downstream | Loads registries, runs schema validation, and checks MVP content counts and cross-reference integrity. |

## Formulas

The `schema_validation_passed` formula is defined as:

`schema_validation_passed = failed_checks == 0 and required_checks > 0`

**Variables:**

| Variable | Symbol | Type | Range | Description |
|---|---|---|---|---|
| `failed_checks` | `F` | int | `0+` | Count of blocking schema validation failures. |
| `required_checks` | `R` | int | `1+` | Count of validation checks expected for loaded resources. |

**Output Range:** `true` or `false`.
**Example:** If 0 of 140 checks fail, `schema_validation_passed = true`.

The `content_set_readiness` formula is defined as:

`content_set_readiness = passed_required_content_counts / total_required_content_counts`

**Variables:**

| Variable | Symbol | Type | Range | Description |
|---|---|---|---|---|
| `passed_required_content_counts` | `P` | int | `0` to `total_required_content_counts` | Count of required content categories meeting minimum count. |
| `total_required_content_counts` | `T` | int | `1+` | Count of required content categories being measured. |

**Output Range:** `0.0` to `1.0`; MVP schema readiness requires `1.0`.
**Example:** If weapons, passives, and starter chapter data all meet required counts, `3 / 3 = 1.0`.

The `mvp_content_count_requirements` formula is defined as:

`mvp_content_count_requirements = weapon_count >= 20 and passive_item_count >= 20 and pet_count >= 5 and chapter_count >= 1`

**Variables:**

| Variable | Symbol | Type | Range | Description |
|---|---|---|---|---|
| `weapon_count` | `W` | int | `0+` | Number of active weapon resources. |
| `passive_item_count` | `I` | int | `0+` | Number of active passive item resources. |
| `pet_count` | `P` | int | `0+` | Number of active pet resources. |
| `chapter_count` | `C` | int | `0+` | Number of active chapter resources. |

**Output Range:** `true` or `false`.
**Example:** `20 weapons`, `20 passives`, `5 pets`, and `1 chapter` returns `true`.

The `resource_reference_integrity` formula is defined as:

`resource_reference_integrity = unresolved_reference_count == 0 and duplicate_id_count == 0 and unknown_tag_count == 0`

**Variables:**

| Variable | Symbol | Type | Range | Description |
|---|---|---|---|---|
| `unresolved_reference_count` | `U` | int | `0+` | Count of ID references pointing to missing resources. |
| `duplicate_id_count` | `D` | int | `0+` | Count of duplicate resource IDs within a registry. |
| `unknown_tag_count` | `T` | int | `0+` | Count of tag references not present in tag definitions. |

**Output Range:** `true` or `false`.
**Example:** If a weapon references missing tag `sun_magic`, `unknown_tag_count = 1`, so integrity fails.

Invalid states are blocking schema errors:

- `required_checks == 0`
- `total_required_content_counts == 0`
- Any resource ID is blank.
- Any active resource uses a deprecated resource ID without explicit migration metadata.
- Any weapon has not exactly 10 levels.
- Any passive item has not exactly 5 levels.
- Any pet has not exactly 5 tiers.
- Any character mastery track has not exactly 10 levels.
- Any draft card pool produces fewer than 3 valid choices before fallback rules.

## Edge Cases

- If two resources use the same `id` in the same registry, validation fails and no runtime registry is built for that content type.
- If a resource references an unknown ID, validation fails and reports the owner resource, field name, and missing ID.
- If a resource references an unknown tag, validation fails and reports the unknown tag plus the approved tag registry path.
- If active content references deprecated content, validation fails unless the reference is marked migration-only or the deprecated resource explicitly allows new runs.
- If a weapon has fewer or more than 10 levels, validation fails and the weapon cannot enter draft pools.
- If a passive item has fewer or more than 5 levels, validation fails and the item cannot enter draft pools or enable evolutions.
- If a pet has fewer or more than 5 tiers, validation fails and the pet cannot be unlocked, equipped, or upgraded.
- If a character references a missing starter weapon, validation fails and the character cannot appear in character select.
- If a chapter references fewer than 2 unique enemies, validation fails for MVP chapter content.
- If a Page Event reward pool is empty, validation fails unless the event is explicitly test-only.
- If a draft pool has fewer than 3 valid choices after normal eligibility checks, runtime draft systems must use approved fallback choices; schema validation warns if no fallback pool exists.
- If an icon, VFX, SFX, or scene path is missing, validation fails for active release content and warns for placeholder-tagged prototype content.
- If a resource ID changes after a save has referenced it, the old ID must remain as a deprecated alias or migration mapping.
- If a resource has valid shape but impossible tuning values, schema validation catches declared range violations; balance quality belongs to downstream tuning review.
- If downstream gameplay systems are absent, schema validation can still pass because it checks data contracts, not runtime behavior.

## Dependencies

- **Godot Project Shell**: Required. Provides project, folder, and smoke-test boot context.
- **Godot 4.6.2 Resource System**: Required. Authoring uses typed GDScript `Resource` subclasses and `.tres` assets.
- **Root GDD**: Required. Owns canonical counts, level structures, draft size, run timing, and content commitments.
- **Asset Provenance Rules**: Required before importing any non-placeholder asset reference into active content.
- **Runtime Event Bus**: Downstream. May report validation events later, but schemas must not require it to boot.
- **Save/Profile/Migration**: Downstream. Consumes stable IDs, versions, aliases, and deprecated mapping data.

## Tuning Knobs

Schema tuning is about data validation policy, not gameplay balance:

| Knob | Default | Range | Owner | Notes |
|---|---:|---:|---|---|
| `allow_placeholder_assets_in_dev` | `true` | bool | Tools/QA | Allows prototype resources to reference placeholder paths. |
| `fail_on_missing_active_assets` | `true` | bool | Tools/QA | Release builds fail when active asset refs are missing. |
| `minimum_mvp_weapons` | `20` | `20+` | Root GDD | Lower values are invalid for MVP readiness. |
| `minimum_mvp_passives` | `20` | `20+` | Root GDD | Lower values are invalid for MVP readiness. |
| `minimum_mvp_pets` | `5` | `5+` | Root GDD | Lower values are invalid for MVP readiness. |
| `minimum_mvp_chapters` | `1` | `1+` | Root GDD | First playable MVP needs one complete chapter. |
| `warn_on_unused_active_content` | `true` | bool | Tools/QA | Warns when active content is not reachable from any pool. |
| `registry_cache_enabled` | `true` | bool | Lead Programmer | Runtime may cache validated lookups after editor validation passes. |

## Visual/Audio Requirements

- Schema resources store references to icons, card art, VFX scenes, SFX events, music cues, and localization keys.
- Schema validation must not require final art for prototype resources marked placeholder.
- Imported assets must include provenance metadata before active content points at them: source URL, creator, license, cost, and allowed use.
- The schema layer must support top-down pixel/cute fantasy sprites presented as 3D cards or `Sprite3D` objects on a lit paper diorama.
- Audio references are metadata only. Mix priority, bus routing, ducking, and playback rules belong to `Audio and Music Layers`.
- Missing visual/audio references are blocking for active release content and warnings for placeholder-tagged prototype content.

## UI Requirements

- Schema validation output must be readable in editor/headless logs with resource path, resource ID, check ID, severity, and message.
- Draft UI consumers need display name, short description, icon reference, rarity, level text, category, and evolution preview metadata.
- Debug tools must be able to list active registries, deprecated resources, unresolved references, and MVP content-count readiness.
- Player-facing UI must never expose raw schema error text. Invalid content is a development/build failure, not a runtime player state.
- Localization keys must be present for active release resources; prototype content may use display strings until localization setup exists.

## Acceptance Criteria

- All required GDD sections are filled with no placeholder text.
- The document preserves root GDD commitments: Resources, stable IDs, exact level counts, 20 weapons, 20 passives, 5 pet tiers, 10 character mastery entries, 3-choice drafts, and tag-based evolutions.
- Every downstream MVP system has a clear data contract to consume.
- Schema validation has explicit blocking conditions for duplicate IDs, missing references, unknown tags, missing required counts, and invalid level/tier counts.
- Placeholder asset policy is explicit and does not permit untracked third-party asset imports.
- Implementation can proceed by creating typed Resource classes, registries, sample `.tres` content, and a headless schema smoke check.

## Open Questions

- Exact folder layout for content resources is implementation-owned, but recommended roots are `data/weapons/`, `data/passives/`, `data/pets/`, `data/enemies/`, `data/bosses/`, `data/chapters/`, `data/page_events/`, `data/tags/`, and `data/audio/`.
- Exact rarity names and numeric draft weights belong to `XP, Leveling, and Upgrade Drafts`.
- Exact icon atlas and final asset family remain open until the asset direction pass chooses a cohesive source set.
