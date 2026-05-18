# Spawn / Overflow / Waxlight Performance (2026-05-17)

Bead: `pagebound-0tg`.

Design sources consulted: `PAGEBOUND_CODEX_GDD_v1_5.md`; `design/gdd/xp-leveling-and-upgrade-drafts.md`; `design/gdd/run-director-and-finite-spawning.md`; `design/gdd/mvp-weapon-candidate-pool.md` Waxlight Comet; `design/gdd/pagecraft-materials-and-grid.md`; `design/gdd/object-pooling-and-performance-debug.md`.

XP pacing decision: keep XP thresholds and enemy Color Mote value unchanged (`5 XP`). First tuning lever was refill behavior: after the first 60s opening grace, `min_alive` catch-up refill now consumes the same target spawn credit as pressure spawns, so forcing mid/late run time cannot fill the whole active budget in one tick. After play feel was too slow, RunDirector target kill-rate curve was tuned to `2/s -> 15/s` while keeping the refill throttle.

Overflow implementation: normal weapon/item choices must be exhausted before overflow can apply. Overflow crumbs are repeatable additive global `+5%` bonuses for `damage`, `range`, `size`, `cadence`, and `duration`. They do not raise weapon/item caps or add `effect_count`/`active_cap`.

Waxlight L10 performance: `PagecraftManager` keeps Waxlight behavior values unchanged (`1.0s` L5 window, L10 window = scaled L5 * 2, `0.33s` ticks, `35%` tick damage). Large connected L10 activation damage pulses queue and drain via `activation_damage_jobs_per_frame = 4`, preventing large connected Waxlight groups from resolving all radius damage inside the dash call. Follow-up bug `pagebound-btq` restored L5/small Waxlight ticks to synchronous resolution so the documented immediate dash tick works again, and queued L10 jobs now snapshot target enemies at queue time so movement before the drain frame does not shift the tick. Existing Waxlight dash/duration smokes passed after this change.

Star L10 performance: follow-up bug `pagebound-92m` kept Star Sticker Swarm rules unchanged while moving L10 constellation segment work into queued jobs drained at `star_ricochet_segment_jobs_per_frame = 4`; direct Star hit remains immediate and L5 ricochet remains synchronous.

Pool hygiene: `EnemyPool._prune_invalid()` now removes invalid refs by index instead of erasing a freed object from a typed array, avoiding Godot invalid-object errors during verification.

Verification evidence in session: `run_director_smoke_check`, `director_time_bands_smoke_check`, `enemy_pool_smoke_check`, `overflow_crumb_smoke_check`, `draft_rarity_weights_smoke_check`, `upgrade_effects_smoke_check`, `waxlight_dash_damage_smoke_check`, `waxlight_l10_duration_smoke_check`, `pagecraft_smoke_check`, `waxlight_l10_activation_budget_check`, and compact `end_game_profile_check` runs passed. After the `2/s -> 15/s` tune, compact profile at 27:00 showed spawn rate about `14.65/s` and killed 19 enemies; use longer warmup or a dedicated stress setup for high-enemy profile comparisons.
