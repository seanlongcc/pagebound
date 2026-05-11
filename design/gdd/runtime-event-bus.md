# Runtime Event Bus

> **Status**: Approved
> **Author**: Sean + Codex
> **Last Updated**: 2026-05-11
> **Implements Pillar**: Power Fantasy First

## Overview

`Runtime Event Bus` defines Pagebound's typed runtime signal hub for gameplay events that multiple systems need to observe: damage, pickups, XP, level-ups, drafts, evolutions, Page Events, boss state, player state, pet attacks, and debug metrics. It owns event contracts and dispatch order policy. It does not own gameplay decisions, validation, save persistence, UI layout, or audio playback.

## Player Fantasy

Players do not see the bus. They feel it when every hit produces numbers, sounds, XP, quest progress, and UI feedback without systems missing each other or duplicating logic.

## Detailed Design

### Core Rules

1. Event bus uses typed GDScript signals where practical.
2. Events describe facts that happened, not commands asking another system to decide.
3. High-volume events must be small payloads and avoid per-frame allocation spikes.
4. Event subscribers may update presentation, stats, quests, debug overlays, and audio, but must not mutate the original event payload.
5. Core runtime can boot without every listener present.
6. Damage resolution publishes damage facts after calculations, not before.
7. UI/audio/debug listeners must tolerate missed optional events during tests.
8. Event names are snake_case past tense, matching technical preferences.
9. The bus should be easy to disable or replace for deterministic tests.
10. The bus does not replace direct references for tight ownership within one system.

### States and Transitions

| State | Description | Valid Transitions |
|---|---|---|
| `Uninitialized` | Bus node/service not ready. | `RuntimeReady` |
| `RuntimeReady` | Signals can be emitted and subscribers can connect. | `RunActive`, `Shutdown` |
| `RunActive` | Events from active run are flowing. | `PausedDispatch`, `Shutdown` |
| `PausedDispatch` | UI pause may suppress gameplay producers, but UI/system events can still flow. | `RunActive`, `Shutdown` |
| `Shutdown` | Bus disconnects transient subscribers and clears run-scoped counters. | `RuntimeReady` |

### Interactions with Other Systems

| System | Direction | Contract |
|---|---|---|
| Godot Project Shell | Upstream | Bus may initialize after shell ready but shell does not require it. |
| Damage and Status Model | Producer | Emits damage, status, death, and healing facts. |
| XP, Leveling, and Upgrade Drafts | Producer/consumer | Emits XP collected, level gained, draft opened, draft selected. |
| Page Events and Objectives | Producer | Emits event spawned, event succeeded, event failed, reward draft opened. |
| Boss and Victory Flow | Producer | Emits boss spawned, phase changed, boss defeated, victory started. |
| Damage Numbers and Combat Feedback | Consumer | Consumes damage/status facts. |
| Audio and Music Layers | Consumer | Consumes gameplay state facts. |
| Object Pooling and Performance Debug | Consumer/producer | Emits pool warnings and consumes high-volume counters. |

## Formulas

`event_allowed = bus_state in [RuntimeReady, RunActive, PausedDispatch]`

`high_volume_event_budget_ok = emitted_events_this_frame <= event_budget_per_frame`

`listener_safe = listener_exists == false or listener_accepts_payload_version == true`

Invalid states:

- Event emitted before bus ready without explicit local fallback.
- Event payload contains direct mutable ownership of another system's internal state.
- High-volume presentation event allocates large dictionaries per hit.
- Listener assumes it is the only subscriber or mutates shared event data.

## Edge Cases

- If no listener is connected, event emit succeeds silently.
- If listener errors, debug logs identify listener and signal; producer should not crash in release unless the event is required.
- If event rate is too high, producers aggregate or consumers pool; the bus does not drop critical damage facts by default.
- If scene reload happens, transient listeners disconnect during shutdown.
- If tests run one system alone, bus can be stubbed with a local test bus.

## Dependencies

- **Godot Project Shell**: Optional boot/handoff context.
- **Resource Data Schemas**: Event payloads can reference stable content IDs.
- **Object Pooling and Performance Debug**: Needed before high-volume events are scaled.
- **Save/Profile/Migration**: Later consumer for durable unlock/meta events.

## Tuning Knobs

| Knob | Default | Range | Notes |
|---|---:|---:|---|
| `event_budget_per_frame` | `2000` | `500-10000` | Debug warning threshold, not hard cap. |
| `log_unhandled_required_events` | `true` | bool | Warn when required milestone events have no listener. |
| `aggregate_damage_ticks` | `true` | bool | Allows consumers to aggregate visual tick feedback. |
| `strict_payload_versioning` | `false` | bool | Enable for migration-sensitive builds later. |

## Visual/Audio Requirements

- No direct visuals/audio.
- Event names and payload IDs must support downstream VFX/SFX routing.
- Debug overlay may display event rates and top producers.

## UI Requirements

- UI systems subscribe to high-level events, not low-level combat internals.
- Draft, boss, Page Event, and victory UI must receive stable event IDs and content IDs.
- Debug overlay can inspect event count per frame and recent critical events.

## Acceptance Criteria

- A typed event bus exists or is specified for implementation with clear signals.
- Damage, XP, draft, Page Event, boss, victory, and player lifecycle events have ownership.
- Systems can run without optional listeners.
- High-volume event policy supports pooling/aggregation.
- Event payloads reference stable IDs from schemas where content identity matters.

## Open Questions

- Exact bus placement as autoload or scene-owned service is implementation-owned; MVP may use scene-owned first and promote later if needed.

