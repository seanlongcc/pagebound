class_name EnemyPool
extends Node

var hard_cap := 350

var _root: Node
var _factory: Callable
var _instances: Array[Node] = []
var _inactive: Array[Node] = []
var _spawned_count := 0
var _reused_count := 0
var _returned_count := 0
var _dropped_count := 0


## Configures enemy instance storage and warms optional inactive entries.
func configure(root: Node, factory: Callable, new_hard_cap: int, initial_size: int = 0) -> void:
	_root = root
	_factory = factory
	hard_cap = maxi(1, new_hard_cap)
	for _index in initial_size:
		var instance := _create_instance()
		if instance != null:
			_deactivate_instance(instance)
			_inactive.append(instance)


## Requests one enemy instance, reusing inactive entries before creating new ones.
func request_instance() -> Node:
	_prune_invalid()
	var instance := _take_inactive()
	if instance != null:
		_reused_count += 1
	elif _instances.size() < hard_cap:
		instance = _create_instance()
	else:
		_dropped_count += 1
		return null

	if instance != null:
		_activate_instance(instance)
	return instance


## Returns one active enemy to inactive storage.
func return_instance(instance: Node) -> void:
	if instance == null or not is_instance_valid(instance):
		return
	if _inactive.has(instance):
		return
	_deactivate_instance(instance)
	_inactive.append(instance)
	_returned_count += 1


## Clears pool references after scene-owned children are removed.
func clear() -> void:
	_instances.clear()
	_inactive.clear()
	_spawned_count = 0
	_reused_count = 0
	_returned_count = 0
	_dropped_count = 0


func debug_active_count() -> int:
	_prune_invalid()
	return maxi(0, _instances.size() - _inactive.size())


func debug_inactive_count() -> int:
	_prune_invalid()
	return _inactive.size()


func debug_total_count() -> int:
	_prune_invalid()
	return _instances.size()


func owns_instance(instance: Node) -> bool:
	_prune_invalid()
	return instance != null and _instances.has(instance)


func debug_spawned_count() -> int:
	return _spawned_count


func debug_reused_count() -> int:
	return _reused_count


func debug_returned_count() -> int:
	return _returned_count


func debug_dropped_count() -> int:
	return _dropped_count


func _create_instance() -> Node:
	if _root == null or not _factory.is_valid():
		return null
	var instance = _factory.call() as Node
	if instance == null:
		return null
	_root.add_child(instance)
	_instances.append(instance)
	_spawned_count += 1
	return instance


func _take_inactive() -> Node:
	while not _inactive.is_empty():
		var instance := _inactive.pop_back() as Node
		if instance != null and is_instance_valid(instance):
			return instance
	return null


func _activate_instance(instance: Node) -> void:
	if instance.has_method("activate_from_pool"):
		instance.call("activate_from_pool")
	else:
		_set_visible(instance, true)
		instance.set_process(true)
		instance.set_physics_process(true)
	_enable_collision(instance, true)


func _deactivate_instance(instance: Node) -> void:
	if instance.has_method("reset_for_pool"):
		instance.call("reset_for_pool")
	else:
		_set_visible(instance, false)
		instance.set_process(false)
		instance.set_physics_process(false)
	_enable_collision(instance, false)


func _set_visible(instance: Node, visible: bool) -> void:
	if instance is Node3D:
		(instance as Node3D).visible = visible
	elif instance is CanvasItem:
		(instance as CanvasItem).visible = visible


func _enable_collision(instance: Node, enabled: bool) -> void:
	var collision := instance.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision != null:
		collision.disabled = not enabled


func _prune_invalid() -> void:
	for index in range(_instances.size() - 1, -1, -1):
		var instance := _instances[index]
		if instance == null or not is_instance_valid(instance):
			_instances.remove_at(index)
			_inactive.erase(instance)
	for index in range(_inactive.size() - 1, -1, -1):
		var instance := _inactive[index]
		if instance == null or not is_instance_valid(instance):
			_inactive.remove_at(index)
