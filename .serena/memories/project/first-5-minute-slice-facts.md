# First 5-Minute Slice Facts (2026-05-11)

- Branch `feat/mvp` now boots to a start menu; run timer, director, weapons, pickups, and player control stay idle until start/accept.
- Death and victory screens expose Retry and Main Menu; Retry resets HP, XP, level, enemies, pickups, marks, director time, upgrades, draft state, page event state, counters, and snaps/rebinds camera follow to the new player at spawn.
- Opening pacing: only `inkling_chaser` before 60s; `paper_scrap_swarmer` joins after 60s. Opening chaser HP equals two starting Waxlight hits.
- Early health scaling uses readable director time-band multipliers: 1.0 opening, 1.15 at 60s, 1.3 at 120s, 1.5 at 240s.
- Spawn pressure is time-band driven by target budget, interval, and batch size. `safety_enemy_cap = 120` is only runaway protection, not gameplay pacing.
- Dash tune: speed 14.0, active 0.15s, recovery 0.14s, cooldown 0.9s, expected travel 2.1m. Dash still activates crossed Waxlight marks.
- HUD shows HP/max HP, level/XP, Waxlight damage/cooldown/duration/cap/inactive-active marks, director pressure/band/budget/spawned/active/safety, Page Event state, weapons, and passives.
- Draft UI is centered horizontal 3-card layout with equal card sizes and viewport-safe scaling across tested 16:9 sizes: 960x540, 1152x648, 1280x720, 1600x900, and 1920x1080. Choices show title, current value, new value, and effect text. Eligibility includes owned weapon upgrades, new documented weapons, documented passives, stat upgrades, fallback choices, and prototype 5 weapon / 5 passive slot limits.
- `.tres` resources now exist for prototype Waxlight, Star Sticker Swarm, Inkling Chaser, Paper Scrap Swarmer, Candle Spark, and upgrade metadata/effects, with fallback factory data retained.
- Documented second weapon: `star_sticker_swarm`; chosen because the main GDD uses it as an early MVP pick. Prototype behavior now reads as orbit -> fire -> page-stick -> pop -> reform; immediate hit and pop damage route through `DamageModel`, create damage numbers, and all sticker/travel/pop artifacts have finite cleanup.
- Documented first passive: `candle_spark`; chosen because the main GDD uses it as first passive and it cleanly modifies Waxlight/glow runtime damage. Prototype starts at chunky +15% glow damage and advances in 15% steps.
- Documented first Page Event: `fill_color_well`; prototype/test tuning starts it at 60s for fast validation while full-run GDD timing remains 5:00. It shows objective/progress on HUD, gains progress from kills/mark activation, applies light pressure while active, and appears before vertical-slice summary.
- 5:00 vertical-slice end stops gameplay and shows summary with time survived, level, XP collected, enemies defeated, weapons, and passives.
- Prototype upgrades now use chunky values: Waxlight damage +2, Waxlight cooldown -0.25s, Waxlight duration +1s, Waxlight cap +3, player max HP +20, Star Sticker damage/count level-up 4 -> 6 and 1 -> 2, and Candle Spark +15% per level.
- No current attack artifact is indefinite: active Waxlight marks decay, inactive Waxlight marks expire plus cap enforcement, Waxlight dash pulses clean up, and Star Sticker page stickers pop/clean up.
- Finite page/map is larger: playable half-extents 11.0 x 7.0, visible mesh 22 x 14, director/player/camera use larger bounds, and Color Mote magnet radius is 8m for larger-page readability.
- Follow-up bead `pagebound-hup`: extract `src/runtime/first_playable_runtime.gd` below local 800-line guardrail; it is 942 lines after the readability/scaling pass.
- Full `tests/smoke/*.gd` suite and headless boot passed after this work.
