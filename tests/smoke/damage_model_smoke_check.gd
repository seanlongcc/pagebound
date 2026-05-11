extends SceneTree

const DamageModelScript := preload("res://src/combat/damage_model.gd")
const HealthComponentScript := preload("res://src/combat/health_component.gd")
const RuntimeEventBusScript := preload("res://src/events/runtime_event_bus.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var bus = RuntimeEventBusScript.new()
	get_root().add_child(bus)

	var health = HealthComponentScript.new()
	health.configure(&"target_dummy", 10.0, &"enemy")
	get_root().add_child(health)

	var damage_model = DamageModelScript.new()
	damage_model.configure(bus)

	var damage_events: Array[Dictionary] = []
	var death_events: Array[Dictionary] = []
	bus.damage_resolved.connect(func(event: Dictionary) -> void:
		damage_events.append(event)
	)
	bus.entity_died.connect(func(event: Dictionary) -> void:
		death_events.append(event)
	)

	damage_model.apply_damage(health, &"smoke_weapon", 4.0, [&"waxlight"])
	_assert_equal(health.current_health, 6.0, "damage must reduce health through one model path", failures)
	_assert_equal(damage_events.size(), 1, "damage model must emit resolved damage event", failures)

	damage_model.apply_damage(health, &"smoke_weapon", 12.0, [&"waxlight"])
	_assert_true(not health.is_alive(), "lethal damage must kill target", failures)
	_assert_equal(death_events.size(), 1, "death event must emit exactly once", failures)

	damage_model.apply_damage(health, &"smoke_weapon", 12.0, [&"waxlight"])
	_assert_equal(death_events.size(), 1, "dead target must not emit duplicate death", failures)

	bus.queue_free()
	health.queue_free()
	await process_frame
	_finish(failures)


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _assert_equal(actual, expected, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s (expected: %s, actual: %s)" % [message, str(expected), str(actual)])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("damage model smoke check passed")
		quit(0)
		return

	push_error("damage model smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
