extends SceneTree

const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")

const ALLOWED_FIRST_PLAYABLE_WEAPONS := {
	&"waxlight_comet": true,
}


func _initialize() -> void:
	var failures: Array[String] = []
	var factory = PrototypeContentFactoryScript.new()
	var weapon_ids: Array[StringName] = []
	var weapon_names: Array[String] = []
	for weapon in factory.weapon_pool():
		if weapon == null:
			failures.append("weapon pool must not contain null resources")
			continue
		weapon_ids.append(weapon.id)
		weapon_names.append(weapon.display_name)
		_assert_true(ALLOWED_FIRST_PLAYABLE_WEAPONS.has(weapon.id), "prototype weapon pool must only contain current GDD-backed first-playable weapon IDs, got %s" % weapon.id, failures)

	_assert_true(weapon_ids == [&"waxlight_comet"], "first polished weapon pool must contain only Waxlight Comet", failures)
	_assert_true(not weapon_ids.has(&"star_sticker_swarm"), "first polished weapon pool must not include old broad Star Sticker weapon", failures)
	_assert_true(not weapon_ids.has(&"dreamsap_glob"), "first polished weapon pool must not include old broad Dreamsap weapon", failures)
	_assert_true(not weapon_ids.has(&"color_bloom"), "first polished weapon pool must not include old broad Color Bloom weapon", failures)
	_assert_true(not weapon_ids.has(&"paper_plane_dart"), "weapon pool must not include non-GDD Paper Plane Dart", failures)
	_assert_true(not weapon_ids.has(&"margin_spark_ring"), "weapon pool must not include non-GDD Margin Spark Ring", failures)
	_assert_true(not "Paper Plane Dart" in weapon_names, "weapon names must not include Paper Plane Dart", failures)
	_assert_true(not "Margin Spark Ring" in weapon_names, "weapon names must not include Margin Spark Ring", failures)

	_finish(failures)


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("prototype weapon pool GDD guard smoke check passed")
		quit(0)
		return

	push_error("prototype weapon pool GDD guard smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
