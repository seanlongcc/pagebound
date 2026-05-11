class_name EnemyData
extends "res://src/data/pagebound_content_resource.gd"

## AI behavior lookup ID. Prototype uses chaser.
@export var behavior_id: StringName
## Maximum health before runtime modifiers.
@export_range(1.0, 100000.0, 0.1) var max_health := 12.0
## X/Z movement speed in meters per second.
@export_range(0.0, 100.0, 0.1) var move_speed := 3.5
## Contact damage value routed through DamageModel.
@export_range(0.0, 10000.0, 0.1) var contact_damage := 3.0
## First playable XP reward stub.
@export_range(0, 100000, 1) var reward_xp := 1
## Pagecraft tags this enemy can read or interact with.
@export var pagecraft_interaction_tags: Array[StringName] = []


## Returns every tag ID referenced by this enemy.
func referenced_tag_ids() -> Array[StringName]:
	var referenced := super()
	referenced.append_array(pagecraft_interaction_tags)
	return referenced


## Returns true when numeric runtime values are valid.
func has_valid_ranges() -> bool:
	return max_health > 0.0 and move_speed >= 0.0 and contact_damage >= 0.0 and reward_xp >= 0
