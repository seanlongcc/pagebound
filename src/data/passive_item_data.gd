class_name PassiveItemData
extends "res://src/data/pagebound_content_resource.gd"

## Catalyst tags that become evolution-enabling at level 5.
@export var catalyst_tags: Array[StringName] = []
## Simple runtime stat channel for the prototype passive.
@export var stat_id: StringName
## Level 1-5 stat values.
@export var level_values: Array[float] = []


func referenced_tag_ids() -> Array[StringName]:
	var referenced := super()
	referenced.append_array(catalyst_tags)
	return referenced


func has_valid_level_track() -> bool:
	if level_values.size() != 5:
		return false
	for value in level_values:
		if value < 0.0:
			return false
	return stat_id != &""
