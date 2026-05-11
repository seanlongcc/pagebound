# ADR-0007: Pagecraft MVP Hook

## Status

Accepted for first playable.

## Context

Pagecraft GDD requires weapons to leave visible marks and player dash paths to sample/activate marks without player or weapon scripts owning grid simulation.

## Decision

Add `PagecraftManager` under `RunRoot/Pagecraft`. `AutoWeaponManager` deposits primitive waxlight disc marks through the manager after successful hits. `PlayerController.dash_path_sampled` connects to `PagecraftManager.activate_path()`, which activates crossed marks by changing color and scale and emits Pagecraft event facts.

## Consequences

- Weapon and dash systems interact through Pagecraft API rather than direct visual mutation.
- First playable has visible Pagecraft cause/effect without full chunked grid storage yet.
- Chunked array simulation and material-specific damage remain future Pagecraft implementation work.
