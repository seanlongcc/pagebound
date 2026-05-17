class_name XpPickupPool
extends Node

signal collected(pickup: Node, amount: int)

const XpPickupScript := preload("res://src/pickups/xp_pickup.gd")

@export_range(1, 2000, 1) var pickup_hard_cap := 350
@export_range(0.0, 8.0, 0.05) var merge_radius := 1.0

var _root: Node
var _collector: Node3D
var _instances: Array[Node] = []
var _inactive: Array[Node] = []
var _active: Array[Node] = []
var _spawned_count := 0
var _reused_count := 0
var _returned_count := 0
var _merged_count := 0
var _dropped_count := 0


## Configures pickup storage root and collection target.
func configure(root: Node, collector: Node3D) -> void:
	_root = root
	_collector = collector


## Spawns, reuses, or merges one Color Mote pickup while preserving XP value.
func spawn_pickup(world_position: Vector3, amount: int) -> Node:
	var resolved_amount := maxi(1, amount)
	var merge_target := _nearest_active_pickup(world_position, merge_radius)
	if merge_target != null:
		_merge_pickup(merge_target, resolved_amount)
		return merge_target

	var pickup := _request_instance()
	if pickup == null:
		merge_target = _nearest_active_pickup(world_position, INF)
		if merge_target != null:
			_merge_pickup(merge_target, resolved_amount)
			return merge_target
		_dropped_count += 1
		return null

	pickup.name = "ColorMote_%d" % resolved_amount
	if pickup is Node3D:
		(pickup as Node3D).position = Vector3(world_position.x, 0.28, world_position.z)
	if pickup.has_method("configure"):
		pickup.configure(resolved_amount, _collector)
	if pickup.has_signal("collected") and not pickup.collected.is_connected(_on_pickup_collected):
		pickup.collected.connect(_on_pickup_collected)
	_active.append(pickup)
	return pickup


## Clears references after scene-owned pickup children are removed.
func clear() -> void:
	_instances.clear()
	_inactive.clear()
	_active.clear()
	_spawned_count = 0
	_reused_count = 0
	_returned_count = 0
	_merged_count = 0
	_dropped_count = 0


func debug_active_count() -> int:
	_prune_invalid()
	return _active.size()


func debug_inactive_count() -> int:
	_prune_invalid()
	return _inactive.size()


func debug_total_count() -> int:
	_prune_invalid()
	return _instances.size()


func debug_hard_cap() -> int:
	return pickup_hard_cap


func debug_spawned_count() -> int:
	return _spawned_count


func debug_reused_count() -> int:
	return _reused_count


func debug_returned_count() -> int:
	return _returned_count


func debug_merged_count() -> int:
	return _merged_count


func debug_dropped_count() -> int:
	return _dropped_count


func _request_instance() -> Node:
	_prune_invalid()
	var pickup := _take_inactive()
	if pickup != null:
		_reused_count += 1
	elif _instances.size() < pickup_hard_cap:
		pickup = _create_pickup()
	else:
		return null
	_activate_instance(pickup)
	return pickup


func _create_pickup() -> Node:
	if _root == null:
		return null
	var pickup = XpPickupScript.new()
	_root.add_child(pickup)
	_instances.append(pickup)
	_spawned_count += 1
	return pickup


func _take_inactive() -> Node:
	while not _inactive.is_empty():
		var pickup := _inactive.pop_back() as Node
		if pickup != null and is_instance_valid(pickup):
			return pickup
	return null


func _activate_instance(pickup: Node) -> void:
	if pickup.has_method("activate_from_pool"):
		pickup.activate_from_pool()
	else:
		_set_visible(pickup, true)
		pickup.set_physics_process(true)


func _return_instance(pickup: Node) -> void:
	if pickup == null or not is_instance_valid(pickup):
		return
	_active.erase(pickup)
	if not _inactive.has(pickup):
		if pickup.has_method("reset_for_pool"):
			pickup.reset_for_pool()
		else:
			_set_visible(pickup, false)
			pickup.set_physics_process(false)
		_inactive.append(pickup)
		_returned_count += 1


func _merge_pickup(pickup: Node, amount: int) -> void:
	if pickup.has_method("merge_amount"):
		pickup.merge_amount(amount)
	elif "amount" in pickup:
		pickup.amount += amount
	_merged_count += 1


func _nearest_active_pickup(world_position: Vector3, radius: float) -> Node:
	_prune_invalid()
	var nearest: Node = null
	var nearest_distance_squared := radius * radius
	for pickup in _active:
		if not pickup is Node3D:
			continue
		if not pickup.has_method("is_collectible") or not pickup.is_collectible():
			continue
		var distance_squared := _pickup_position(pickup as Node3D).distance_squared_to(world_position)
		if distance_squared <= nearest_distance_squared:
			nearest = pickup
			nearest_distance_squared = distance_squared
	return nearest


func _pickup_position(pickup: Node3D) -> Vector3:
	if pickup.is_inside_tree():
		return pickup.global_position
	return pickup.position


func _on_pickup_collected(pickup: Node, amount: int) -> void:
	collected.emit(pickup, amount)
	_return_instance(pickup)


func _set_visible(pickup: Node, visible: bool) -> void:
	if pickup is Node3D:
		(pickup as Node3D).visible = visible
	elif pickup is CanvasItem:
		(pickup as CanvasItem).visible = visible


func _prune_invalid() -> void:
	for index in range(_instances.size() - 1, -1, -1):
		var pickup := _instances[index]
		if pickup == null or not is_instance_valid(pickup):
			_instances.remove_at(index)
			_inactive.erase(pickup)
			_active.erase(pickup)
	for index in range(_inactive.size() - 1, -1, -1):
		var pickup := _inactive[index]
		if pickup == null or not is_instance_valid(pickup):
			_inactive.remove_at(index)
	for index in range(_active.size() - 1, -1, -1):
		var pickup := _active[index]
		if pickup == null or not is_instance_valid(pickup):
			_active.remove_at(index)
