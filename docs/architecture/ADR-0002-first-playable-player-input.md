# ADR-0002: First Playable Player Input

## Status

Accepted for first playable.

## Context

Input and player controller GDDs require runtime-created defaults, a typed input access layer, a `CharacterBody3D` player under `RunRoot/Actors/Players`, X/Z movement, and dash path events for Pagecraft. The existing shell forbids gameplay scripts on canonical shell nodes.

## Decision

Mount `FirstPlayableRuntime` as a child of `RunRoot`. It creates gameplay actors under shell-owned mount roots while leaving canonical shell nodes script-free. `InputActions` installs default keyboard/gamepad actions at boot. `PlayerController` owns planar movement, dash state, placeholder collision/mesh, and emits `dash_path_sampled`.

## Consequences

- Shell validation remains focused on topology.
- Movement and dash can be smoke-tested without editor input.
- Runtime can be split into scene files later without changing shell roots.
- Input defaults are currently installed at runtime rather than serialized into `project.godot`.
