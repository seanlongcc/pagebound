# ADR-0003: Gameplay Camera Follow

## Status

Accepted for first playable.

## Context

The camera GDD requires a `Camera3D` following the player on the X/Z page while preserving finite page readability and shell ownership. Shell validation forbids gameplay scripts on canonical camera nodes.

## Decision

Keep `RunRoot/CameraRig` and `Camera3D` as shell nodes. `FirstPlayableRuntime` creates a `GameplayCameraFollow` child under `CameraRig`; that service moves the rig toward the active player with smoothing, light lookahead, and simple finite page clamps.

## Consequences

- Canonical shell nodes remain free of gameplay scripts.
- Follow behavior can be tuned or replaced without editing shell validation.
- First playable keeps the primitive page, camera, and directional light readable under headless boot checks.
