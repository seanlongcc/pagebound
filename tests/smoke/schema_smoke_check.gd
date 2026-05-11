extends SceneTree

const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const SchemaRegistryScript := preload("res://src/data/schema_registry.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var registry = SchemaRegistryScript.new()
	var content_factory = PrototypeContentFactoryScript.new()

	content_factory.register_minimal_first_playable_content(registry)
	var result = registry.validate()

	_assert_equal(result.error_count, 0, "schema validation must have no errors", failures)
	_assert_true(result.has_check_id("resource_ids_valid"), "schema check must validate resource IDs", failures)
	_assert_true(result.has_check_id("tag_references_valid"), "schema check must validate tag references", failures)
	_assert_true(result.has_check_id("weapon_level_counts_valid"), "schema check must validate weapon level counts", failures)
	_assert_true(registry.has_weapon(&"waxlight_comet"), "prototype weapon must be registered", failures)
	_assert_true(registry.has_enemy(&"inkling_chaser"), "prototype enemy must be registered", failures)
	_assert_true(registry.has_tag(&"waxlight"), "prototype material tag must be registered", failures)

	_finish(failures)


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _assert_equal(actual, expected, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s (expected: %s, actual: %s)" % [message, str(expected), str(actual)])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("schema smoke check passed")
		quit(0)
		return

	push_error("schema smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
