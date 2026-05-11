class_name DamageNumberManager
extends Node

const DamageNumberVisualScript := preload("res://src/feedback/damage_number_visual.gd")
const SimpleObjectPoolScript := preload("res://src/pooling/simple_object_pool.gd")

@export_range(1, 1500, 1) var damage_number_hard_cap := 500
@export_range(0, 256, 1) var initial_pool_size := 16
@export_range(0.1, 3.0, 0.05) var number_lifetime_seconds := 0.75

var _pool
var _event_bus: Node
var _numbers_root: Node
var _presented_count := 0


## Connects the manager to the runtime event bus and pool root.
func configure(event_bus: Node, numbers_root: Node) -> void:
	_event_bus = event_bus
	_numbers_root = numbers_root
	_ensure_pool()
	if _event_bus != null and _event_bus.has_signal("damage_resolved"):
		if not _event_bus.damage_resolved.is_connected(_on_damage_resolved):
			_event_bus.damage_resolved.connect(_on_damage_resolved)


## Returns active damage number count for smoke/debug checks.
func debug_active_count() -> int:
	if _pool == null:
		return 0
	return _pool.active_count()


## Returns spawned pooled object count for smoke/debug checks.
func debug_spawned_count() -> int:
	if _pool == null:
		return 0
	return _pool.spawned_count


## Returns total damage numbers presented since manager configuration.
func debug_presented_count() -> int:
	return _presented_count


## Returns dropped presentation count for smoke/debug checks.
func debug_dropped_count() -> int:
	if _pool == null:
		return 0
	return _pool.dropped_count


func _ensure_pool() -> void:
	if _pool != null:
		return
	_pool = SimpleObjectPoolScript.new()
	_pool.name = "DamageNumberPool"
	add_child(_pool)
	_pool.configure(Callable(self, "_create_visual"), _numbers_root, damage_number_hard_cap, initial_pool_size)


func _create_visual() -> Node:
	var visual = DamageNumberVisualScript.new()
	visual.name = "DamageNumberVisual"
	visual.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	visual.no_depth_test = true
	visual.font_size = 48
	visual.pixel_size = 0.012
	if not visual.expired.is_connected(_on_visual_expired):
		visual.expired.connect(_on_visual_expired)
	return visual


func _on_damage_resolved(event: Dictionary) -> void:
	var amount := float(event.get("amount", 0.0))
	if amount <= 0.0:
		return
	var visual = _pool.request_instance()
	if visual == null or not visual.has_method("activate"):
		return
	visual.activate(event.get("world_position", Vector3.ZERO), amount, _color_for_event(event), number_lifetime_seconds)
	_presented_count += 1


func _on_visual_expired(visual: Node) -> void:
	if visual != null and visual.has_method("reset_for_pool"):
		visual.reset_for_pool()
	if _pool != null:
		_pool.return_instance(visual)


func _color_for_event(event: Dictionary) -> Color:
	if event.get("killed", false):
		return Color(1.0, 0.32, 0.22, 1.0)
	return Color(1.0, 0.88, 0.24, 1.0)
