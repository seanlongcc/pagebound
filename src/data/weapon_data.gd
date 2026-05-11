class_name WeaponData
extends "res://src/data/pagebound_content_resource.gd"

## Coarse weapon type ID consumed by weapon runtime behavior.
@export var weapon_type_id: StringName
## Runtime behavior lookup ID. Prototype uses a direct-hit behavior.
@export var attack_behavior_id: StringName
## Tags describing the weapon material identity.
@export var material_tags: Array[StringName] = []
## Catalyst tags that can later satisfy evolution checks.
@export var catalyst_tags: Array[StringName] = []
## Pagecraft material tag deposited by this weapon.
@export var pagecraft_material_tag: StringName
## Dash interaction behavior ID consumed by Pagecraft.
@export var dash_interaction_id: StringName
## Exactly 10 entries for MVP weapons.
@export var levels: Array[Resource] = []


## Returns every tag ID referenced by this weapon.
func referenced_tag_ids() -> Array[StringName]:
	var referenced := super()
	referenced.append_array(material_tags)
	referenced.append_array(catalyst_tags)
	if pagecraft_material_tag != &"":
		referenced.append(pagecraft_material_tag)
	return referenced


## Returns true when this weapon has exactly 10 valid level rows.
func has_valid_level_track() -> bool:
	if levels.size() != 10:
		return false
	for index in levels.size():
		var level_data = levels[index]
		if level_data == null or level_data.level != index + 1 or not level_data.has_valid_ranges():
			return false
	return true


## Returns the level data for a one-based weapon level.
func level_data_for(level: int) -> Resource:
	var clamped_level: int = clampi(level, 1, levels.size())
	return levels[clamped_level - 1]
