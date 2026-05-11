class_name WeaponLevelData
extends Resource

## One-based weapon level. MVP weapons have exactly 10 entries.
@export_range(1, 10, 1) var level := 1
## Resolved as base damage before runtime multipliers.
@export_range(0.0, 10000.0, 0.1) var base_damage := 1.0
## Auto-fire interval before attack-speed modifiers.
@export_range(0.05, 60.0, 0.01) var cooldown_seconds := 1.0
## Radius used by first playable mark/impact behavior.
@export_range(0.0, 20.0, 0.1) var mark_radius_meters := 1.0
## Maximum targeting range for this weapon level.
@export_range(0.1, 40.0, 0.1) var range_meters := 8.0


## Returns true when level tuning values are in valid authoring ranges.
func has_valid_ranges() -> bool:
	return level >= 1 and level <= 10 and base_damage >= 0.0 and cooldown_seconds > 0.0 and mark_radius_meters >= 0.0 and range_meters > 0.0
