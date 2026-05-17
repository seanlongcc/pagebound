class_name PerformanceProfileSnapshot
extends RefCounted

const HOT_ROOT_PATHS := {
	"enemies": "Actors/Enemies",
	"pickups": "Pickups",
	"damage_numbers": "DamageNumbers",
	"vfx": "VFX",
	"pagecraft": "Pagecraft",
	"projectiles": "Projectiles",
}


## Captures one low-allocation performance snapshot for headless profiling.
func capture(run_root: Node, label: String = "") -> Dictionary:
	return {
		"label": label,
		"timings": _timing_monitors(),
		"node_count": maxi(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)), _recursive_node_count(run_root)),
		"object_count": int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		"resource_count": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),
		"orphan_node_count": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),
		"draw_calls": int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		"roots": _hot_root_counts(run_root),
		"director": _director_metrics(run_root),
		"pools": _pool_metrics(run_root),
	}


func _timing_monitors() -> Dictionary:
	return {
		"fps": float(Performance.get_monitor(Performance.TIME_FPS)),
		"process_time_ms": float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0,
		"physics_time_ms": float(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)) * 1000.0,
	}


func _hot_root_counts(run_root: Node) -> Dictionary:
	var counts := {}
	if run_root == null:
		return counts
	for key in HOT_ROOT_PATHS.keys():
		var hot_root := run_root.get_node_or_null(HOT_ROOT_PATHS[key])
		counts[key] = _root_counts(hot_root)
	return counts


func _root_counts(root: Node) -> Dictionary:
	var total_children := 0
	var visible_children := 0
	var hidden_children := 0
	var process_children := 0
	var physics_process_children := 0
	var active_children := 0
	if root == null:
		return {
			"total_children": 0,
			"visible_children": 0,
			"hidden_children": 0,
			"process_children": 0,
			"physics_process_children": 0,
			"active_children": 0,
		}

	for child in root.get_children():
		total_children += 1
		var is_visible := _is_visible_node(child)
		if is_visible:
			visible_children += 1
		else:
			hidden_children += 1
		if child.is_processing():
			process_children += 1
		if child.is_physics_processing():
			physics_process_children += 1
		if _is_active_child(child, is_visible):
			active_children += 1

	return {
		"total_children": total_children,
		"visible_children": visible_children,
		"hidden_children": hidden_children,
		"process_children": process_children,
		"physics_process_children": physics_process_children,
		"active_children": active_children,
	}


func _director_metrics(run_root: Node) -> Dictionary:
	var director := _child_or_null(run_root, "RunDirector")
	if director == null:
		return {}
	return {
		"run_time_seconds": _call_float(director, "debug_run_time"),
		"spawned_count": _call_int(director, "debug_spawned_count"),
		"active_enemy_count": _call_int(director, "debug_active_enemy_count"),
		"active_budget": _call_int(director, "debug_active_budget"),
		"safety_enemy_cap": _call_int(director, "debug_safety_enemy_cap"),
		"spawn_interval_seconds": _call_float(director, "debug_spawn_interval_seconds"),
		"spawn_rate_per_second": _call_float(director, "debug_spawn_rate_per_second"),
	}


func _pool_metrics(run_root: Node) -> Dictionary:
	var pools := {}
	var damage_manager := _node_or_null(run_root, "DamageNumbers/DamageNumberManager")
	if damage_manager != null:
		pools["damage_numbers"] = {
			"active": _call_int(damage_manager, "debug_active_count"),
			"spawned": _call_int(damage_manager, "debug_spawned_count"),
			"presented": _call_int(damage_manager, "debug_presented_count"),
			"dropped": _call_int(damage_manager, "debug_dropped_count"),
		}
	var xp_pool := _child_or_null(run_root, "XpPickupPool")
	if xp_pool != null:
		pools["xp_pickups"] = {
			"active": _call_int(xp_pool, "debug_active_count"),
			"inactive": _call_int(xp_pool, "debug_inactive_count"),
			"total": _call_int(xp_pool, "debug_total_count"),
			"hard_cap": _call_int(xp_pool, "debug_hard_cap"),
			"spawned": _call_int(xp_pool, "debug_spawned_count"),
			"reused": _call_int(xp_pool, "debug_reused_count"),
			"returned": _call_int(xp_pool, "debug_returned_count"),
			"merged": _call_int(xp_pool, "debug_merged_count"),
			"dropped": _call_int(xp_pool, "debug_dropped_count"),
		}
	return pools


func _is_visible_node(node: Node) -> bool:
	if node is Node3D:
		return (node as Node3D).visible
	if node is CanvasItem:
		return (node as CanvasItem).visible
	return false


func _is_active_child(node: Node, is_visible: bool) -> bool:
	if not is_visible:
		return false
	if node.has_method("debug_is_targetable"):
		return bool(node.call("debug_is_targetable"))
	if node.has_method("is_collectible"):
		return bool(node.call("is_collectible"))
	var health := node.get_node_or_null("HealthComponent")
	if health != null and health.has_method("is_alive"):
		return bool(health.call("is_alive"))
	return true


func _node_or_null(root: Node, path: String) -> Node:
	if root == null:
		return null
	return root.get_node_or_null(path)


func _child_or_null(root: Node, child_name: String) -> Node:
	if root == null:
		return null
	return root.get_node_or_null(child_name)


func _call_int(target: Node, method_name: String) -> int:
	if target == null or not target.has_method(method_name):
		return 0
	return int(target.call(method_name))


func _call_float(target: Node, method_name: String) -> float:
	if target == null or not target.has_method(method_name):
		return 0.0
	return float(target.call(method_name))


func _recursive_node_count(root: Node) -> int:
	if root == null:
		return 0
	var count := 1
	for child in root.get_children():
		count += _recursive_node_count(child)
	return count
