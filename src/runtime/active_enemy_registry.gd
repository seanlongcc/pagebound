class_name ActiveEnemyRegistry
extends Node

var _active_enemies: Array[Node3D] = []
var _enemies_root: Node


## Configures optional root watching for enemies added outside RunDirector.
func configure(enemies_root: Node) -> void:
	if _enemies_root != null and _enemies_root.child_entered_tree.is_connected(_on_child_entered_tree):
		_enemies_root.child_entered_tree.disconnect(_on_child_entered_tree)
	_enemies_root = enemies_root
	if _enemies_root == null:
		return
	if not _enemies_root.child_entered_tree.is_connected(_on_child_entered_tree):
		_enemies_root.child_entered_tree.connect(_on_child_entered_tree)
	for child in _enemies_root.get_children():
		_try_register_enemy(child)


## Adds a visible living enemy to active queries.
func register_enemy(enemy: Node3D) -> void:
	if enemy == null:
		return
	_prune_invalid()
	if _active_enemies.has(enemy):
		return
	_active_enemies.append(enemy)
	var exit_callable := Callable(self, "_on_enemy_tree_exiting").bind(enemy)
	if not enemy.tree_exiting.is_connected(exit_callable):
		enemy.tree_exiting.connect(exit_callable)


## Removes an enemy from active queries.
func unregister_enemy(enemy: Node3D) -> void:
	if enemy == null:
		return
	_active_enemies.erase(enemy)


## Clears all tracked active enemies.
func clear() -> void:
	_active_enemies.clear()


## Returns active visible living enemy count.
func active_count() -> int:
	_prune_invalid()
	return _active_enemies.size()


## Returns a copy of active visible living enemies.
func active_enemies() -> Array[Node3D]:
	_prune_invalid()
	return _active_enemies.duplicate()


## Returns nearest active enemy inside range, using squared distance.
func nearest_enemy(origin: Vector3, max_range: float, exclude_enemy: Node3D = null) -> Node3D:
	_prune_invalid()
	var best_enemy: Node3D = null
	var best_distance_squared := maxf(0.0, max_range) * maxf(0.0, max_range)
	for enemy in _active_enemies:
		if enemy == exclude_enemy:
			continue
		var distance_squared := origin.distance_squared_to(enemy.global_position)
		if distance_squared <= best_distance_squared:
			best_enemy = enemy
			best_distance_squared = distance_squared
	return best_enemy


## Returns active enemies inside radius. max_count <= 0 means unlimited.
func enemies_in_radius(center: Vector3, radius: float, max_count: int = 0, exclude_enemy: Node3D = null) -> Array[Node3D]:
	_prune_invalid()
	var results: Array[Node3D] = []
	var radius_squared := maxf(0.0, radius) * maxf(0.0, radius)
	for enemy in _active_enemies:
		if enemy == exclude_enemy:
			continue
		if enemy.global_position.distance_squared_to(center) > radius_squared:
			continue
		results.append(enemy)
		if max_count > 0 and results.size() >= max_count:
			break
	return results


## Returns active enemies close to a segment. Used by Star Sticker ricochets.
func enemies_along_segment(start_position: Vector3, end_position: Vector3, hit_width_meters: float) -> Array[Node3D]:
	_prune_invalid()
	var results: Array[Node3D] = []
	var start_xz := Vector2(start_position.x, start_position.z)
	var end_xz := Vector2(end_position.x, end_position.z)
	var segment := end_xz - start_xz
	var length_squared := segment.length_squared()
	if length_squared <= 0.0001:
		return results
	var half_width := maxf(0.0, hit_width_meters * 0.5)
	var half_width_squared := half_width * half_width
	for enemy in _active_enemies:
		var point := Vector2(enemy.global_position.x, enemy.global_position.z)
		var projection := clampf((point - start_xz).dot(segment) / length_squared, 0.0, 1.0)
		var closest_point := start_xz + segment * projection
		if point.distance_squared_to(closest_point) <= half_width_squared:
			results.append(enemy)
	return results


func _on_enemy_tree_exiting(enemy: Node3D) -> void:
	unregister_enemy(enemy)


func _on_child_entered_tree(child: Node) -> void:
	_try_register_enemy(child)


func _try_register_enemy(child: Node) -> void:
	if child is Node3D:
		register_enemy(child as Node3D)


func _prune_invalid() -> void:
	for index in range(_active_enemies.size() - 1, -1, -1):
		var enemy := _active_enemies[index]
		if not _is_active_enemy(enemy):
			_active_enemies.remove_at(index)


func _is_active_enemy(enemy: Node3D) -> bool:
	if enemy == null or not is_instance_valid(enemy):
		return false
	if not enemy.is_inside_tree() or not enemy.visible:
		return false
	if enemy.has_method("debug_is_targetable"):
		return bool(enemy.call("debug_is_targetable"))
	var health := enemy.get_node_or_null("HealthComponent")
	return health != null and health.has_method("is_alive") and bool(health.call("is_alive"))
