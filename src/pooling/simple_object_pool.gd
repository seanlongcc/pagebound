class_name SimpleObjectPool
extends Node

var hard_cap := 128
var spawned_count := 0
var reused_count := 0
var dropped_count := 0

var _factory: Callable
var _root: Node
var _inactive: Array[Node] = []
var _active: Array[Node] = []


## Configures the pool factory, parent root, cap, and warm count.
func configure(factory: Callable, root: Node, new_hard_cap: int, initial_size: int) -> void:
	_factory = factory
	_root = root
	hard_cap = maxi(1, new_hard_cap)
	for index in initial_size:
		var instance := _create_instance()
		if instance != null:
			_deactivate_instance(instance)
			_inactive.append(instance)


## Requests one pooled instance or returns null when the hard cap is reached.
func request_instance() -> Node:
	var instance: Node = null
	if not _inactive.is_empty():
		instance = _inactive.pop_back()
		reused_count += 1
	elif _active.size() < hard_cap:
		instance = _create_instance()
	else:
		dropped_count += 1
		return null

	if instance != null:
		_active.append(instance)
		instance.visible = true
	return instance


## Returns one active instance to the inactive pool.
func return_instance(instance: Node) -> void:
	if instance == null:
		return
	_active.erase(instance)
	_deactivate_instance(instance)
	_inactive.append(instance)


## Returns active instance count.
func active_count() -> int:
	return _active.size()


## Returns inactive instance count.
func inactive_count() -> int:
	return _inactive.size()


func _create_instance() -> Node:
	if not _factory.is_valid() or _root == null:
		return null
	var instance = _factory.call() as Node
	if instance == null:
		return null
	_root.add_child(instance)
	spawned_count += 1
	return instance


func _deactivate_instance(instance: Node) -> void:
	instance.visible = false
	instance.set_process(false)
