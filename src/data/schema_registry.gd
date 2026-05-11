class_name SchemaRegistry
extends RefCounted

const SchemaValidationResultScript := preload("res://src/data/schema_validation_result.gd")

var _tags: Array[Resource] = []
var _weapons: Array[Resource] = []
var _enemies: Array[Resource] = []
var _tag_lookup: Dictionary = {}
var _weapon_lookup: Dictionary = {}
var _enemy_lookup: Dictionary = {}


## Registers a tag resource for validation and runtime lookup.
func register_tag(tag: Resource) -> void:
	_tags.append(tag)
	if tag != null and tag.id != &"":
		_tag_lookup[tag.id] = tag


## Registers a weapon resource for validation and runtime lookup.
func register_weapon(weapon: Resource) -> void:
	_weapons.append(weapon)
	if weapon != null and weapon.id != &"":
		_weapon_lookup[weapon.id] = weapon


## Registers an enemy resource for validation and runtime lookup.
func register_enemy(enemy: Resource) -> void:
	_enemies.append(enemy)
	if enemy != null and enemy.id != &"":
		_enemy_lookup[enemy.id] = enemy


## Returns true when a tag ID is registered.
func has_tag(id: StringName) -> bool:
	return _tag_lookup.has(id)


## Returns true when a weapon ID is registered.
func has_weapon(id: StringName) -> bool:
	return _weapon_lookup.has(id)


## Returns true when an enemy ID is registered.
func has_enemy(id: StringName) -> bool:
	return _enemy_lookup.has(id)


## Returns a registered weapon or null.
func weapon(id: StringName) -> Resource:
	return _weapon_lookup.get(id, null) as Resource


## Returns a registered enemy or null.
func enemy(id: StringName) -> Resource:
	return _enemy_lookup.get(id, null) as Resource


## Validates IDs, duplicate IDs, tag refs, and prototype runtime ranges.
func validate():
	var result = SchemaValidationResultScript.new()
	_add_resource_id_check(result)
	_add_duplicate_id_check(result, "duplicate_tag_ids_valid", _tags)
	_add_duplicate_id_check(result, "duplicate_weapon_ids_valid", _weapons)
	_add_duplicate_id_check(result, "duplicate_enemy_ids_valid", _enemies)
	_add_tag_reference_check(result)
	_add_weapon_level_count_check(result)
	_add_enemy_range_check(result)
	result.finalize()
	return result


func _add_resource_id_check(result) -> void:
	var invalid_labels: Array[String] = []
	for tag in _tags:
		if tag == null or not _is_valid_id(tag.id):
			invalid_labels.append(_tag_label(tag))
	for resource in _all_content_resources():
		if resource == null or not _is_valid_id(resource.id):
			invalid_labels.append(_resource_label(resource))

	result.add_check(
		"resource_ids_valid",
		invalid_labels.is_empty(),
		"Resource and tag IDs must be non-empty lowercase snake_case.",
		{"invalid_resources": invalid_labels}
	)


func _add_duplicate_id_check(result, check_id: String, resources: Array) -> void:
	var seen := {}
	var duplicates: Array[String] = []
	for resource in resources:
		if resource == null:
			continue
		if seen.has(resource.id):
			duplicates.append(String(resource.id))
		seen[resource.id] = true

	result.add_check(
		check_id,
		duplicates.is_empty(),
		"Duplicate IDs are not allowed inside a registry.",
		{"duplicate_ids": duplicates}
	)


func _add_tag_reference_check(result) -> void:
	var missing: Array[String] = []
	for resource in _all_content_resources():
		if resource == null:
			continue
		for tag_id in resource.referenced_tag_ids():
			if tag_id != &"" and not has_tag(tag_id):
				missing.append("%s -> %s" % [_resource_label(resource), String(tag_id)])

	result.add_check(
		"tag_references_valid",
		missing.is_empty(),
		"Every content tag reference must point at a registered tag.",
		{"missing_tag_references": missing}
	)


func _add_weapon_level_count_check(result) -> void:
	var invalid_weapons: Array[String] = []
	for weapon_resource in _weapons:
		if weapon_resource == null or not weapon_resource.has_valid_level_track():
			invalid_weapons.append(_resource_label(weapon_resource))

	result.add_check(
		"weapon_level_counts_valid",
		invalid_weapons.is_empty(),
		"Weapons must define exactly 10 valid level entries.",
		{"invalid_weapons": invalid_weapons}
	)


func _add_enemy_range_check(result) -> void:
	var invalid_enemies: Array[String] = []
	for enemy_resource in _enemies:
		if enemy_resource == null or not enemy_resource.has_valid_ranges():
			invalid_enemies.append(_resource_label(enemy_resource))

	result.add_check(
		"enemy_ranges_valid",
		invalid_enemies.is_empty(),
		"Enemies must define positive health and non-negative runtime ranges.",
		{"invalid_enemies": invalid_enemies}
	)


func _all_content_resources() -> Array[Resource]:
	var resources: Array[Resource] = []
	resources.append_array(_weapons)
	resources.append_array(_enemies)
	return resources


func _is_valid_id(id: StringName) -> bool:
	var text := String(id)
	if text.is_empty():
		return false
	if text[0].is_valid_int():
		return false
	for index in text.length():
		var code := text.unicode_at(index)
		var is_lower := code >= 97 and code <= 122
		var is_digit := code >= 48 and code <= 57
		var is_underscore := code == 95
		if not (is_lower or is_digit or is_underscore):
			return false
	return not text.begins_with("_") and not text.ends_with("_") and not text.contains("__")


func _resource_label(resource: Resource) -> String:
	if resource == null:
		return "<null content resource>"
	return resource.schema_label()


func _tag_label(tag: Resource) -> String:
	if tag == null:
		return "<null tag resource>"
	return tag.schema_label()
