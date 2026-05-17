class_name PagecraftManager
extends Node

const ACTIVATION_BASE_WINDOW_SECONDS := 1.0
const ACTIVATION_DAMAGE_PULSE_SCALE := 0.35
const CONNECTED_ACTIVATION_WINDOW_MULTIPLIER := 2.0
const CONNECTED_ACTIVATION_DAMAGE_PULSE_SCALE := 0.35

@export_range(0.05, 2.0, 0.05) var dash_activation_padding := 0.675
@export_range(0.05, 5.0, 0.01) var activation_damage_tick_seconds := 0.33
@export_range(0.05, 5.0, 0.01) var connected_activation_damage_tick_seconds := 0.33
@export_range(0.0, 0.5, 0.01) var activation_visual_grace_seconds := 0.05
@export_range(0.5, 30.0, 0.5) var inactive_mark_lifetime_seconds := 12.0
@export_range(0.1, 3.0, 0.05) var pulse_lifetime_seconds := 1.125
@export_range(1, 64, 1) var base_unactivated_mark_cap := 6

var _event_bus: Node
var _pagecraft_root: Node3D
var _damage_model
var _enemies_root: Node
var _enemy_registry: Node
var _upgrade_state
var _marks: Array[Dictionary] = []
var _activation_count := 0
var _activation_damage_count := 0
var _last_activation_damage := 0.0
var _last_mark_position := Vector3.ZERO
var _pulse_count := 0
var _pulse_visuals: Array[Dictionary] = []


func _physics_process(delta: float) -> void:
	_tick_marks(delta)
	_tick_pulse_visuals(delta)


## Configures the Pagecraft manager root and event output.
func configure(event_bus: Node, pagecraft_root: Node3D, damage_model = null, enemies_root: Node = null, upgrade_state = null) -> void:
	_event_bus = event_bus
	_pagecraft_root = pagecraft_root
	_damage_model = damage_model
	_enemies_root = enemies_root
	_enemy_registry = _active_enemy_registry_from_root(enemies_root)
	_upgrade_state = upgrade_state


## Deposits a visible primitive mark on the page.
func deposit_mark(
	world_position: Vector3,
	material_tag: StringName,
	radius: float,
	source_id: StringName,
	activation_damage: float = 0.0,
	damage_tags: Array = []
) -> void:
	_enforce_unactivated_mark_cap(material_tag)
	var resolved_radius := _mark_radius(source_id, radius)
	var mark_visual := _create_mark_visual(world_position, resolved_radius, false)
	var mark := {
		"position": Vector3(world_position.x, 0.04, world_position.z),
		"radius": resolved_radius,
		"material_tag": material_tag,
		"source_id": source_id,
		"activation_damage": activation_damage,
		"damage_tags": _activation_damage_tags(damage_tags),
		"inactive_remaining_duration": inactive_mark_lifetime_seconds,
		"remaining_duration": 0.0,
		"damage_tick_remaining": 0.0,
		"activation_damage_tick_seconds": activation_damage_tick_seconds,
		"activation_duration_seconds": 0.0,
		"activation_damage_pulses_remaining": 0,
		"activation_damage_pulse_count": 0,
		"visual": mark_visual,
		"activated": false,
	}
	_marks.append(mark)
	_last_mark_position = mark["position"]
	_emit_deposited(mark)


## Activates marks crossed by a dash path.
func activate_path(start_position: Vector3, end_position: Vector3) -> void:
	var activated_indices := {}
	for index in _marks.size():
		var mark := _marks[index]
		if mark.get("activated", false):
			continue
		if not _can_activate_mark(mark):
			continue
		if _distance_to_segment(mark["position"], start_position, end_position) <= float(mark["radius"]) + dash_activation_padding:
			var indices := _activation_indices_for(index)
			for activation_index in indices:
				if activated_indices.has(activation_index):
					continue
				_activate_mark(activation_index, start_position, end_position, activated_indices.is_empty())
				activated_indices[activation_index] = true


## Returns active mark count for smoke/debug checks.
func debug_mark_count() -> int:
	return _marks.size()


## Returns unactivated mark count for smoke/debug checks.
func debug_unactivated_mark_count() -> int:
	var count := 0
	for mark in _marks:
		if not mark.get("activated", false):
			count += 1
	return count


## Returns active mark count for smoke/debug checks.
func debug_active_mark_count() -> int:
	var count := 0
	for mark in _marks:
		if mark.get("activated", false):
			count += 1
	return count


## Returns activation count for smoke/debug checks.
func debug_activation_count() -> int:
	return _activation_count


## Returns the number of enemies damaged by dash-activated marks.
func debug_activation_damage_count() -> int:
	return _activation_damage_count


## Returns the last dash activation damage amount for smoke/debug checks.
func debug_last_activation_damage() -> float:
	return _last_activation_damage


## Returns the most recently deposited mark position for smoke/debug checks.
func debug_last_mark_position() -> Vector3:
	return _last_mark_position


## Returns primitive pulse visual count for smoke/debug checks.
func debug_pulse_count() -> int:
	return _pulse_count


## Returns current visible pulse visual count for smoke/debug checks.
func debug_active_pulse_visual_count() -> int:
	return _pulse_visuals.size()


## Returns current unactivated Waxlight mark cap for smoke/debug checks.
func debug_unactivated_mark_cap() -> int:
	return _unactivated_mark_cap()


## Returns current activated Waxlight duration for smoke/debug checks.
func debug_activation_duration_seconds() -> float:
	return _activation_duration_seconds()


## Deposits a test Waxlight mark for smoke checks.
func debug_deposit_test_mark(world_position: Vector3) -> void:
	deposit_mark(world_position, &"waxlight", 0.5, &"waxlight_comet", 5.0, [&"waxlight"])


## Clears transient Pagecraft marks for smoke checks.
func debug_clear_marks() -> void:
	for mark in _marks:
		var visual = mark.get("visual", null)
		if visual is Node:
			(visual as Node).queue_free()
	_marks.clear()
	for pulse in _pulse_visuals:
		var visual = pulse.get("visual", null)
		if visual is Node:
			(visual as Node).queue_free()
	_pulse_visuals.clear()
	_last_mark_position = Vector3.ZERO


## Returns the first mark position for smoke/debug checks.
func debug_first_mark_position() -> Vector3:
	if _marks.is_empty():
		return Vector3.ZERO
	return _marks[0]["position"]


func _activate_mark(index: int, start_position: Vector3, end_position: Vector3, create_pulse: bool = true) -> void:
	if index < 0 or index >= _marks.size():
		return
	var mark := _marks[index]
	if mark.get("activated", false):
		return
	mark["activated"] = true
	mark["activation_damage_pulse_count"] = _activation_damage_pulse_count(mark)
	mark["activation_damage_scale"] = _activation_damage_scale(mark)
	mark["activation_damage_tick_seconds"] = _activation_damage_tick_seconds(mark)
	mark["activation_duration_seconds"] = _activation_duration_seconds(mark)
	mark["remaining_duration"] = mark["activation_duration_seconds"]
	mark["activation_damage_pulses_remaining"] = int(mark["activation_damage_pulse_count"])
	mark = _apply_activation_damage_pulse(mark)
	_marks[index] = mark
	_activation_count += 1
	var visual = mark.get("visual", null)
	if visual is MeshInstance3D:
		(visual as MeshInstance3D).material_override = _mark_material(true)
		(visual as MeshInstance3D).scale *= 1.35
	if create_pulse:
		_create_dash_pulse(start_position, end_position)
	_emit_activated(mark)


func _tick_marks(delta: float) -> void:
	for index in range(_marks.size() - 1, -1, -1):
		var mark := _marks[index]
		if not mark.get("activated", false):
			mark["inactive_remaining_duration"] = float(mark.get("inactive_remaining_duration", inactive_mark_lifetime_seconds)) - delta
			if float(mark["inactive_remaining_duration"]) <= 0.0:
				_remove_mark_at(index)
				continue
			_marks[index] = mark
			continue
		mark["remaining_duration"] = float(mark.get("remaining_duration", 0.0)) - delta
		if float(mark["remaining_duration"]) <= 0.0:
			_remove_mark_at(index)
			continue
		mark = _tick_activation_damage_pulses(mark, delta)
		_update_active_visual(mark)
		_marks[index] = mark


func _create_mark_visual(world_position: Vector3, radius: float, activated: bool) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	visual.name = "PagecraftMark"
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.035
	mesh.radial_segments = 32
	visual.mesh = mesh
	visual.position = Vector3(world_position.x, 0.03, world_position.z)
	visual.material_override = _mark_material(activated)
	_pagecraft_root.add_child(visual)
	return visual


func _mark_material(activated: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.45, 0.12, 0.9) if activated else Color(1.0, 0.82, 0.18, 0.72)
	material.roughness = 0.7
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _update_active_visual(mark: Dictionary) -> void:
	var visual = mark.get("visual", null)
	if not visual is MeshInstance3D:
		return
	var duration := maxf(0.01, float(mark.get("activation_duration_seconds", _activation_duration_seconds(mark))))
	var remaining_ratio := clampf(float(mark.get("remaining_duration", 0.0)) / duration, 0.0, 1.0)
	(visual as MeshInstance3D).scale.y = maxf(0.35, remaining_ratio)


func _create_dash_pulse(start_position: Vector3, end_position: Vector3) -> void:
	if _pagecraft_root == null:
		return
	var start_flat := Vector3(start_position.x, 0.09, start_position.z)
	var end_flat := Vector3(end_position.x, 0.09, end_position.z)
	var direction := end_flat - start_flat
	var length := direction.length()
	if length <= 0.01:
		return
	var midpoint := start_flat + direction * 0.5
	var normalized_direction := direction.normalized()
	var side := Vector3(-normalized_direction.z, 0.0, normalized_direction.x)
	var pulse_colors := [
		Color(1.0, 0.18, 0.32, 0.92),
		Color(1.0, 0.86, 0.16, 0.92),
		Color(0.2, 0.82, 1.0, 0.92),
	]
	for lane in pulse_colors.size():
		var visual := MeshInstance3D.new()
		visual.name = "WaxlightDashPulse_%d" % _pulse_count
		var mesh := BoxMesh.new()
		mesh.size = Vector3(length, 0.035, 0.055)
		visual.mesh = mesh
		visual.position = midpoint + side * (float(lane) - 1.0) * 0.11
		visual.rotation.y = atan2(-normalized_direction.z, normalized_direction.x)
		visual.material_override = _pulse_material(pulse_colors[lane])
		_pagecraft_root.add_child(visual)
		_pulse_visuals.append({"visual": visual, "remaining": pulse_lifetime_seconds})
		_pulse_count += 1


func _tick_pulse_visuals(delta: float) -> void:
	for index in range(_pulse_visuals.size() - 1, -1, -1):
		var pulse := _pulse_visuals[index]
		pulse["remaining"] = float(pulse.get("remaining", 0.0)) - delta
		if float(pulse["remaining"]) <= 0.0:
			var visual = pulse.get("visual", null)
			if visual is Node:
				(visual as Node).queue_free()
			_pulse_visuals.remove_at(index)
			continue
		_pulse_visuals[index] = pulse


func _pulse_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = 0.65
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _tick_activation_damage_pulses(mark: Dictionary, delta: float) -> Dictionary:
	var pulses_remaining := int(mark.get("activation_damage_pulses_remaining", 0))
	if pulses_remaining <= 0:
		return mark
	var interval := float(mark.get("activation_damage_tick_seconds", activation_damage_tick_seconds))
	var tick_remaining := float(mark.get("damage_tick_remaining", interval)) - delta
	while pulses_remaining > 0 and tick_remaining <= 0.0:
		_apply_activation_damage(mark, float(mark.get("activation_damage_scale", ACTIVATION_DAMAGE_PULSE_SCALE)))
		pulses_remaining -= 1
		if pulses_remaining <= 0:
			tick_remaining = 0.0
			break
		tick_remaining += interval
	mark["activation_damage_pulses_remaining"] = pulses_remaining
	mark["damage_tick_remaining"] = tick_remaining
	return mark


func _apply_activation_damage_pulse(mark: Dictionary) -> Dictionary:
	var pulses_remaining := int(mark.get("activation_damage_pulses_remaining", 0))
	if pulses_remaining <= 0:
		return mark
	_apply_activation_damage(mark, float(mark.get("activation_damage_scale", ACTIVATION_DAMAGE_PULSE_SCALE)))
	pulses_remaining -= 1
	mark["activation_damage_pulses_remaining"] = pulses_remaining
	var interval := float(mark.get("activation_damage_tick_seconds", activation_damage_tick_seconds))
	mark["damage_tick_remaining"] = interval if pulses_remaining > 0 else 0.0
	return mark


func _apply_activation_damage(mark: Dictionary, damage_scale: float = 1.0) -> void:
	if _damage_model == null or _enemies_root == null:
		return
	var activation_damage := float(mark.get("activation_damage", 0.0)) * damage_scale
	if activation_damage <= 0.0:
		return
	var radius := float(mark.get("radius", 0.0))
	for enemy in _enemies_in_radius(mark["position"], radius):
		var health := enemy.get_node_or_null("HealthComponent")
		if health == null:
			continue
		var result: Dictionary = _damage_model.apply_damage(
			health,
			_activation_source_id(mark),
			activation_damage,
			mark.get("damage_tags", [])
		)
		if result.is_empty():
			continue
		_activation_damage_count += 1
		_last_activation_damage = float(result.get("amount", activation_damage))


func _enemies_in_radius(center: Vector3, radius: float) -> Array[Node3D]:
	var enemies: Array[Node3D] = []
	if _enemy_registry != null and _enemy_registry.has_method("active_count") and int(_enemy_registry.active_count()) > 0 and _enemy_registry.has_method("enemies_in_radius"):
		for enemy in _enemy_registry.enemies_in_radius(center, radius):
			if enemy is Node3D:
				enemies.append(enemy)
		return enemies
	if _enemies_root == null:
		return enemies
	for enemy in _enemies_root.get_children():
		if not enemy is Node3D or not (enemy as Node3D).visible:
			continue
		var enemy_node := enemy as Node3D
		if enemy_node.global_position.distance_squared_to(center) <= radius * radius:
			enemies.append(enemy_node)
	return enemies


func _active_enemy_registry_from_root(enemies_root: Node) -> Node:
	if enemies_root == null:
		return null
	var current := enemies_root
	while current != null and current.name != "RunRoot":
		current = current.get_parent()
	if current == null:
		return null
	return current.get_node_or_null("ActiveEnemyRegistry")


func _activation_indices_for(origin_index: int) -> Array[int]:
	if origin_index < 0 or origin_index >= _marks.size():
		return []
	var origin := _marks[origin_index]
	if not _connected_activation_enabled(origin):
		return [origin_index]
	var result: Array[int] = []
	var queue: Array[int] = [origin_index]
	var visited := {}
	while not queue.is_empty():
		var current_index: int = queue.pop_front()
		if visited.has(current_index):
			continue
		visited[current_index] = true
		var current := _marks[current_index]
		if current.get("activated", false) or not _same_activation_group(origin, current):
			continue
		result.append(current_index)
		for candidate_index in _marks.size():
			if visited.has(candidate_index):
				continue
			var candidate := _marks[candidate_index]
			if candidate.get("activated", false) or not _same_activation_group(origin, candidate):
				continue
			if _marks_touch(current, candidate):
				queue.append(candidate_index)
	return result


func _can_activate_mark(mark: Dictionary) -> bool:
	var source_id: StringName = mark.get("source_id", &"")
	if source_id != &"waxlight_comet":
		return true
	if _upgrade_state != null and _upgrade_state.has_method("waxlight_dash_unlocked"):
		return _upgrade_state.waxlight_dash_unlocked()
	return false


func _connected_activation_enabled(mark: Dictionary) -> bool:
	if mark.get("source_id", &"") != &"waxlight_comet":
		return false
	if _upgrade_state != null and _upgrade_state.has_method("waxlight_connected_activation_unlocked"):
		return _upgrade_state.waxlight_connected_activation_unlocked()
	return false


func _same_activation_group(a: Dictionary, b: Dictionary) -> bool:
	return a.get("source_id", &"") == b.get("source_id", &"") and a.get("material_tag", &"") == b.get("material_tag", &"")


func _marks_touch(a: Dictionary, b: Dictionary) -> bool:
	var a_position: Vector3 = a.get("position", Vector3.ZERO)
	var b_position: Vector3 = b.get("position", Vector3.ZERO)
	var reach := _connected_mark_reach(a, b)
	return a_position.distance_to(b_position) <= reach


func _connected_mark_reach(a: Dictionary, b: Dictionary) -> float:
	var base_reach := float(a.get("radius", 0.0)) + float(b.get("radius", 0.0))
	if a.get("source_id", &"") != &"waxlight_comet" or b.get("source_id", &"") != &"waxlight_comet":
		return base_reach
	if _upgrade_state != null and _upgrade_state.has_method("waxlight_connected_reach_meters"):
		return _upgrade_state.waxlight_connected_reach_meters(base_reach)
	return base_reach


func _enforce_unactivated_mark_cap(material_tag: StringName) -> void:
	var cap := _unactivated_mark_cap()
	while _unactivated_mark_count_for(material_tag) >= cap:
		var oldest_index := _oldest_unactivated_mark_index(material_tag)
		if oldest_index < 0:
			return
		_remove_mark_at(oldest_index)


func _unactivated_mark_count_for(material_tag: StringName) -> int:
	var count := 0
	for mark in _marks:
		if mark.get("material_tag", &"") == material_tag and not mark.get("activated", false):
			count += 1
	return count


func _oldest_unactivated_mark_index(material_tag: StringName) -> int:
	for index in _marks.size():
		var mark := _marks[index]
		if mark.get("material_tag", &"") == material_tag and not mark.get("activated", false):
			return index
	return -1


func _remove_mark_at(index: int) -> void:
	if index < 0 or index >= _marks.size():
		return
	var mark := _marks[index]
	var visual = mark.get("visual", null)
	if visual is Node:
		(visual as Node).queue_free()
	_marks.remove_at(index)


func _activation_duration_seconds(mark: Dictionary = {}) -> float:
	return _activation_damage_window_seconds(mark) + activation_visual_grace_seconds


func _activation_damage_window_seconds(mark: Dictionary = {}) -> float:
	if not _uses_waxlight_activation_window(mark):
		return 0.0
	var base_window := ACTIVATION_BASE_WINDOW_SECONDS
	if _upgrade_state != null and _upgrade_state.has_method("waxlight_active_duration_seconds"):
		base_window = _upgrade_state.waxlight_active_duration_seconds(ACTIVATION_BASE_WINDOW_SECONDS)
	if _connected_activation_enabled(mark):
		return base_window * CONNECTED_ACTIVATION_WINDOW_MULTIPLIER
	return base_window


func _activation_damage_tick_seconds(mark: Dictionary = {}) -> float:
	if _connected_activation_enabled(mark):
		return connected_activation_damage_tick_seconds
	return activation_damage_tick_seconds


func _activation_damage_pulse_count(mark: Dictionary = {}) -> int:
	if mark.has("activation_damage_pulse_count") and int(mark["activation_damage_pulse_count"]) > 0:
		return int(mark["activation_damage_pulse_count"])
	if not _uses_waxlight_activation_window(mark):
		return 1
	return _tick_count_for_window(_activation_damage_window_seconds(mark), _activation_damage_tick_seconds(mark))


func _activation_damage_scale(mark: Dictionary = {}) -> float:
	if _connected_activation_enabled(mark):
		return CONNECTED_ACTIVATION_DAMAGE_PULSE_SCALE
	if not _uses_waxlight_activation_window(mark):
		return 1.0
	return ACTIVATION_DAMAGE_PULSE_SCALE


func _tick_count_for_window(window_seconds: float, tick_seconds: float) -> int:
	if window_seconds <= 0.0 or tick_seconds <= 0.0:
		return 1
	return int(floor(window_seconds / tick_seconds)) + 1


func _uses_waxlight_activation_window(mark: Dictionary = {}) -> bool:
	return mark.is_empty() or mark.get("source_id", &"") == &"waxlight_comet"


func _unactivated_mark_cap() -> int:
	if _upgrade_state != null and _upgrade_state.has_method("waxlight_unactivated_mark_cap"):
		return _upgrade_state.waxlight_unactivated_mark_cap(base_unactivated_mark_cap)
	return base_unactivated_mark_cap


func _mark_radius(source_id: StringName, base_radius: float) -> float:
	if _upgrade_state != null and _upgrade_state.has_method("weapon_mark_radius_meters"):
		return _upgrade_state.weapon_mark_radius_meters(source_id, base_radius)
	return base_radius


func _activation_source_id(mark: Dictionary) -> StringName:
	return StringName("%s_dash_activation" % String(mark.get("source_id", &"pagecraft")))


func _activation_damage_tags(base_tags: Array) -> Array[StringName]:
	var tags: Array[StringName] = []
	for tag in base_tags:
		tags.append(tag)
	if not tags.has(&"pagecraft"):
		tags.append(&"pagecraft")
	if not tags.has(&"dash_activation"):
		tags.append(&"dash_activation")
	return tags


func _distance_to_segment(point: Vector3, start_position: Vector3, end_position: Vector3) -> float:
	var start_flat := Vector3(start_position.x, point.y, start_position.z)
	var end_flat := Vector3(end_position.x, point.y, end_position.z)
	var segment := end_flat - start_flat
	var segment_length_squared := segment.length_squared()
	if segment_length_squared == 0.0:
		return point.distance_to(start_flat)
	var t := clampf((point - start_flat).dot(segment) / segment_length_squared, 0.0, 1.0)
	var closest := start_flat + segment * t
	return point.distance_to(closest)


func _emit_deposited(mark: Dictionary) -> void:
	if _event_bus != null and _event_bus.has_method("emit_pagecraft_mark_deposited"):
		_event_bus.emit_pagecraft_mark_deposited({
			"material_tag": mark["material_tag"],
			"source_id": mark["source_id"],
			"world_position": mark["position"],
			"radius": mark["radius"],
		})


func _emit_activated(mark: Dictionary) -> void:
	if _event_bus != null and _event_bus.has_method("emit_pagecraft_mark_activated"):
		_event_bus.emit_pagecraft_mark_activated({
			"material_tag": mark["material_tag"],
			"source_id": mark["source_id"],
			"world_position": mark["position"],
			"radius": mark["radius"],
		})
