# End-Game Performance Pooling (2026-05-17)

Implemented beads `pagebound-5se`, `pagebound-b5g`, `pagebound-7b0`, and `pagebound-ntp` without commits.

Design sources consulted: `PAGEBOUND_CODEX_GDD_v1_5.md` sections 37 and 49; `design/gdd/object-pooling-and-performance-debug.md`; `design/gdd/xp-leveling-and-upgrade-drafts.md`.

New harness: `tests/performance/end_game_profile_check.gd` runs under Godot 4.6.2 console and prints `PROFILE_SUMMARY` plus `PROFILE_JSON`. It supports scenarios `baseline`, `no_pickups`, `no_damage_numbers`, `no_shadows`, `no_vfx_pagecraft`, `low_enemy_cap`, and `minimal_presentation`; tunables include `--run-time`, `--warmup-frames`, `--death-cycles`, `--kills-per-cycle`, `--sample-frames`, and optional `--output`. Snapshot helper is `src/runtime/performance_profile_snapshot.gd`.

Enemy performance: added `src/runtime/active_enemy_registry.gd` and `src/enemies/enemy_pool.gd`. `RunDirector` now uses hard-capped pooled `ChaserEnemy` instances and active registry queries. Runtime enemy death returns director-owned enemies to pool before reward XP spawn. Weapons/Pagecraft/contact damage use registry-backed active/range/segment queries with fallback for unregistered test-spawned enemies.

XP performance: added `src/pickups/xp_pickup_pool.gd`; `XpPickup` now supports merge/reset/reuse lifecycle. Runtime routes Color Mote spawns through `XpPickupPool`, which has hard cap `350`, merge radius `1.0`, return-on-collect, and debug stats via `debug_xp_pickup_pool_stats()`.

Profiler baseline evidence after changes: `end_game_profile_check.gd` baseline with 320 kills reported `enemies_total=331`, `enemies_hidden=0`, `pickups_total=142`, `xp_pickups.merged=178`, `physics_p95_ms≈17.317`, `process_p95_ms≈8.070`. Earlier harness baseline before pooling showed `enemies_total=653`, `enemies_hidden=320`, `pickups_total=320`.

Large-file note: `src/runtime/first_playable_runtime.gd` grew only for wiring/debug delegation to focused helpers; core pooling/query behavior lives in new helper modules.