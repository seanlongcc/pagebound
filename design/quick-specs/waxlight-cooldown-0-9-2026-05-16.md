# Quick Design Spec: Waxlight Cooldown 0.9s

**Type**: Tuning
**System**: Weapons and Auto-Attacks
**GDD Reference**: `design/gdd/mvp-weapon-candidate-pool.md` — Waxlight Comet
**Date**: 2026-05-16

## Change

| Parameter | Old Value | New Value | Rationale |
|-----------|-----------|-----------|-----------|
| `waxlight_comet.base_cooldown_seconds` | `0.95s` | `0.9s` | Slightly increase Waxlight Comet cast cadence per user tuning direction. |

## Tuning Knob Mapping

Maps to Waxlight Comet base tuning. New value remains in the documented Fast cadence band.

## Acceptance Criteria

- [ ] `data/weapons/prototype_waxlight_comet.tres` uses `base_cooldown_seconds = 0.9`.
- [ ] `PrototypeContentFactory` fallback Waxlight data uses `0.9`.
- [ ] Weapon base stat smoke check expects Waxlight cooldown `0.9s`.
- [ ] Focused/root GDD and project memory reflect the new value.
