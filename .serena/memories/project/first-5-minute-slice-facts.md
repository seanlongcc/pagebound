# First 5-Minute Slice Facts (2026-05-11)

- Branch `feat/mvp` now boots to a start menu; run timer, director, weapons, pickups, and player control stay idle until start/accept.
- Death and victory screens expose Retry and Main Menu; Retry resets HP, XP, level, enemies, pickups, marks, director time, upgrades, draft state, page event state, and counters.
- Opening pacing: only `inkling_chaser` before 60s; `paper_scrap_swarmer` joins after 60s. Opening chaser HP equals two starting Waxlight hits.
- Early health scaling uses readable director time-band multipliers: 1.0 opening, 1.15 at 60s, 1.3 at 120s, 1.5 at 240s.
- Spawn pressure is time-band driven by target budget, interval, and batch size. `safety_enemy_cap = 120` is only runaway protection, not gameplay pacing.
- Dash tune: speed 14.0, active 0.15s, recovery 0.14s, cooldown 0.9s, expected travel 2.1m. Dash still activates crossed Waxlight marks.
- HUD shows HP/max HP, level/XP, Waxlight damage/cooldown/duration/cap/inactive-active marks, director pressure/band/budget/spawned/active/safety, Page Event state, weapons, and passives.
- Draft UI is horizontal 3-card layout. Choices show title, current value, new value, and effect text. Eligibility includes owned weapon upgrades, new documented weapons, documented passives, stat upgrades, fallback choices, and prototype 5 weapon / 5 passive slot limits.
- `.tres` resources now exist for prototype Waxlight, Star Sticker Swarm, Inkling Chaser, Paper Scrap Swarmer, Candle Spark, and upgrade metadata/effects, with fallback factory data retained.
- Documented second weapon: `star_sticker_swarm`; chosen because the main GDD uses it as an early MVP pick and it gives distinct burst/multi-target primitive feedback. Damage routes through `DamageModel`.
- Documented first passive: `candle_spark`; chosen because the main GDD uses it as first passive and it cleanly modifies Waxlight/glow runtime damage.
- Documented first Page Event: `fill_color_well`; starts at 5:00, shows objective/progress on HUD, gains progress from kills/mark activation, applies light pressure while active, and appears before vertical-slice summary.
- 5:00 vertical-slice end stops gameplay and shows summary with time survived, level, XP collected, enemies defeated, weapons, and passives.
- Follow-up bead `pagebound-hup`: extract `src/runtime/first_playable_runtime.gd` below local 800-line guardrail; it is 925 lines after the slice hardening.
- Full `tests/smoke/*.gd` suite and headless boot passed after this work.