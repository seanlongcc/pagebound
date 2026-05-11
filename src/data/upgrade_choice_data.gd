class_name UpgradeChoiceData
extends "res://src/data/pagebound_content_resource.gd"

## Runtime choice category: weapon, weapon_upgrade, passive, passive_upgrade, stat, fallback.
@export var choice_type: StringName
## ID consumed by the runtime upgrade applier.
@export var effect_id: StringName
## Optional weapon affected or granted by this choice.
@export var weapon_id: StringName
## Optional passive affected or granted by this choice.
@export var passive_id: StringName
## Stat channel changed by this choice.
@export var stat_id: StringName
## Numeric amount used by simple prototype effects.
@export var value := 0.0
## Display text for the player-facing effect line.
@export var effect_text := ""
## Base draft weight used by the prototype eligible pool.
@export_range(0.0, 1000.0, 0.1) var draft_weight := 1.0


func referenced_tag_ids() -> Array[StringName]:
	return super()


func has_valid_ranges() -> bool:
	return choice_type != &"" and effect_id != &"" and draft_weight >= 0.0
