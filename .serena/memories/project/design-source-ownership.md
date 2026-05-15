# Design Source Ownership

Updated 2026-05-13.

- Root GDD `PAGEBOUND_CODEX_GDD_v1_5.md` keeps stable design principles, invariants, and cross-system rules.
- Exact MVP weapon candidate rows, L1/L5/L10 milestones, upgrade pools, catalyst assignments, and base numeric weapon tuning live in `design/gdd/mvp-weapon-candidate-pool.md`; root section 11 references that focused sheet instead of duplicating weapon tables. Weapon level is upgrade-count progress only; base stats do not auto-scale by level.
- Exact MVP passive item rows, L1-L5 values, capstones, catalyst tags, stat-channel definitions, and Wonder Box stat-track rank values live in `design/gdd/mvp-item-candidate-pool.md`; root sections 12 and 20 reference that focused sheet instead of duplicating item/Wonder Box tables.
- When changing weapon/item/Wonder Box exact values, update the focused MVP sheet first, then update root GDD only if a stable rule or invariant changes.
