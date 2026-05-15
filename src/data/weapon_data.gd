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
## Authored starting hit/area damage before upgrade and passive modifiers.
@export_range(0.0, 10000.0, 0.1) var base_damage := 1.0
## Authored starting auto-fire interval before cadence modifiers.
@export_range(0.05, 60.0, 0.01) var base_cooldown_seconds := 1.0
## Authored starting mark, splash, or footprint radius before size modifiers.
@export_range(0.0, 20.0, 0.1) var base_mark_radius_meters := 1.0
## Authored starting targeting or placement range before range modifiers.
@export_range(0.1, 40.0, 0.1) var base_range_meters := 8.0


## Returns every tag ID referenced by this weapon.
func referenced_tag_ids() -> Array[StringName]:
	var referenced := super()
	referenced.append_array(material_tags)
	referenced.append_array(catalyst_tags)
	if pagecraft_material_tag != &"":
		referenced.append(pagecraft_material_tag)
	return referenced


## Returns true when this weapon has valid editable base tuning.
func has_valid_base_stats() -> bool:
	return base_damage >= 0.0 and base_cooldown_seconds > 0.0 and base_mark_radius_meters >= 0.0 and base_range_meters > 0.0


## Compatibility shim for older debug callers. Weapon level no longer changes base stats.
func level_data_for(_level: int) -> Resource:
	return self
