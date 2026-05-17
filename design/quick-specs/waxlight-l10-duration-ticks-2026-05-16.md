# Quick Design Spec: Waxlight L5/L10 Duration Ticks

**Type**: Tweak
**System**: Weapons and Pagecraft
**GDD Reference**: `design/gdd/mvp-weapon-candidate-pool.md` — Waxlight Comet
**Date**: 2026-05-16

## Change Summary

Waxlight L5 dash activation keeps an active damage window. Duration upgrades scale that L5 window, and Waxlight L10 derives its connected active window from the scaled L5 duration.

## Design Delta

Current stale implementation/doc text treated L5 as one immediate burst and made duration L10-only. This spec changes that to:

- L5 dash activation: `1.0s` base active window.
- L5 ticks: immediately and every `0.33s` while the active window lasts.
- L5 tick damage: `35%` activation damage.
- Waxlight duration upgrades scale the L5 active window.
- L10 connected activation: touching/overlapping unactivated Waxlight marks activate together and create a ticking active window.
- L10 active window formula: scaled L5 active duration `* 2`; base L10 window is therefore `2.0s`.
- L10 tick interval and damage use the same `0.33s` / `35%` formula as L5.
- Waxlight duration upgrades are normal Waxlight pool options, not L10-only.

## Acceptance Criteria

- [ ] L5 dash activation ticks immediately and every `0.33s` while active for `35%` activation damage.
- [ ] L5 active marks remain catchable for the base `1.0s` damage window plus brief visual grace.
- [ ] Waxlight `duration` is eligible before L10 and extends the L5 active window.
- [ ] L10 connected activation uses the same `0.33s` / `35%` tick formula as L5.
- [ ] Default L10 active window ends after about `2.0s` plus brief visual grace.
- [ ] Epic `duration` scales the L5 window from `1.0s` to at least `1.5s`; L10 uses that scaled value `* 2`, reaching at least `3.0s`.
