extends SceneTree

const MAIN_SCENE := "res://Main.tscn"


func _initialize() -> void:
	var failures: Array[String] = []
	var root := _load_main(failures)
	if root == null:
		_finish(failures)
		return

	await process_frame
	await physics_frame
	var _runtime_start := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	if _runtime_start != null and _runtime_start.has_method("debug_start_run"):
		_runtime_start.debug_start_run()
	await process_frame
	await physics_frame

	var director := root.get_node_or_null("RunRoot/RunDirector")
	var hud := root.get_node_or_null("UI/HUD")

	_assert_true(director != null and director.has_method("debug_active_budget"), "director must expose active budget", failures)
	_assert_true(director != null and director.has_method("debug_spawn_interval_seconds"), "director must expose spawn interval", failures)
	_assert_true(director != null and director.has_method("debug_base_spawn_interval_seconds"), "director must expose base wave spawn interval", failures)
	_assert_true(director != null and director.has_method("debug_current_time_band_id"), "director must expose current time band", failures)
	_assert_true(director != null and director.has_method("debug_force_run_time"), "director must support simulated run time for smoke", failures)
	_assert_true(director != null and director.has_method("debug_spawned_count"), "director must expose spawned count", failures)
	_assert_true(director != null and director.has_method("debug_spawn_rate_per_second"), "director must expose pressure spawn rate", failures)
	_assert_true(director != null and director.has_method("debug_target_kills_per_second"), "director must expose target kill-rate curve", failures)
	_assert_true(director != null and director.has_method("debug_health_multiplier"), "director must expose enemy health multiplier", failures)

	if director == null:
		_finish_after_root(root, failures)
		return

	var opening_budget: int = director.debug_active_budget()
	var opening_interval := 0.0
	if director.has_method("debug_base_spawn_interval_seconds"):
		opening_interval = director.debug_base_spawn_interval_seconds()
	_assert_true(director.debug_safety_enemy_cap() == 350, "director max alive cap must match approved wave balance", failures)
	_assert_true(opening_budget == 8, "opening grace minimum alive must start at 8", failures)
	_assert_float_equal(opening_interval, 1.0, 0.01, "opening spawn interval must start at 1.00s", failures)
	if director.has_method("debug_spawn_rate_per_second"):
		_assert_float_equal(director.debug_spawn_rate_per_second(), 1.0, 0.01, "opening pressure spawn rate must start at 1 enemy/sec", failures)
	if director.has_method("debug_target_kills_per_second"):
		_assert_float_equal(director.debug_target_kills_per_second(), 1.0, 0.01, "opening kill-rate target must start at 1 kill/sec", failures)
	if director.has_method("debug_current_time_band_id"):
		_assert_true(director.debug_current_time_band_id() == &"opening", "director must start in opening time band", failures)

	if director.has_method("debug_force_run_time"):
		director.debug_force_run_time(15.0)
		await physics_frame
		_assert_true(director.debug_active_budget() >= 10 and director.debug_active_budget() <= 12, "0:15 opening grace minimum alive must remain about 11", failures)
		_assert_float_equal(director.debug_base_spawn_interval_seconds(), 1.0, 0.02, "0:15 spawn interval must stay readable", failures)

		director.debug_force_run_time(60.0)
		await physics_frame
		_assert_true(director.debug_active_budget() >= 25 and director.debug_active_budget() <= 26, "1:00 wave minimum alive must finish opening grace around 25", failures)

		director.debug_force_run_time(300.0)
		await physics_frame
		_assert_true(director.debug_active_budget() > opening_budget, "first pressure band must raise active budget", failures)
		_assert_true(director.debug_base_spawn_interval_seconds() < opening_interval, "first pressure band must lower spawn interval", failures)
		_assert_true(director.debug_active_budget() >= 46 and director.debug_active_budget() <= 48, "5:00 wave minimum alive must be about 47", failures)
		_assert_float_equal(director.debug_base_spawn_interval_seconds(), 0.94, 0.02, "5:00 spawn interval must follow smooth wave curve", failures)
		_assert_true(director.debug_current_time_band_id() == &"fast_wave", "5:00 must use fast_wave band", failures)

		var first_budget: int = director.debug_active_budget()
		var first_interval: float = director.debug_base_spawn_interval_seconds()
		director.debug_force_run_time(900.0)
		await physics_frame
		_assert_true(director.debug_active_budget() > first_budget, "second pressure band must raise active budget again", failures)
		_assert_true(director.debug_base_spawn_interval_seconds() < first_interval, "second pressure band must lower spawn interval again", failures)
		_assert_true(director.debug_active_budget() >= 172 and director.debug_active_budget() <= 174, "15:00 wave minimum alive must be about 173", failures)
		_assert_float_equal(director.debug_base_spawn_interval_seconds(), 0.60, 0.02, "15:00 spawn interval must follow smooth wave curve", failures)
		_assert_float_equal(director.debug_health_multiplier(), 1.0 + (7.0 * pow(0.5, 1.6)), 0.01, "15:00 enemy HP multiplier must follow eased 1x -> 8x curve", failures)
		_assert_true(director.debug_current_time_band_id() == &"tank_wave", "15:00 must use tank_wave band", failures)

		director.debug_force_run_time(1800.0)
		await physics_frame
		_assert_true(director.debug_active_budget() == 320, "30:00 wave minimum alive must hit 320", failures)
		_assert_float_equal(director.debug_base_spawn_interval_seconds(), 0.20, 0.01, "30:00 spawn interval must hit 0.20s", failures)
		if director.has_method("debug_target_kills_per_second"):
			_assert_float_equal(director.debug_target_kills_per_second(), 10.0, 0.01, "30:00 kill-rate target must hit 10 kills/sec", failures)
		_assert_float_equal(director.debug_health_multiplier(), 8.0, 0.01, "30:00 enemy HP multiplier must end at 8x", failures)
		_assert_true(director.debug_current_time_band_id() == &"elite_wave", "30:00 must use elite_wave band", failures)

	_assert_true(director.debug_all_active_enemies_within_bounds(), "time band pressure must keep active enemies inside finite page bounds", failures)
	var hud_text := _visible_text(hud)
	_assert_true(hud_text.contains("HP") and hud_text.contains("XP") and hud_text.contains("Level"), "HUD must expose player-facing counters", failures)
	_assert_true(not hud_text.contains("Budget") and not hud_text.contains("Spawned"), "HUD must not expose director debug counters", failures)

	_finish_after_root(root, failures)


func _finish_after_root(root: Node, failures: Array[String]) -> void:
	root.queue_free()
	await process_frame
	_finish(failures)


func _load_main(failures: Array[String]) -> Node:
	var packed_scene := load(MAIN_SCENE) as PackedScene
	_assert_true(packed_scene != null, "Main.tscn must load", failures)
	if packed_scene == null:
		return null
	var root := packed_scene.instantiate()
	get_root().add_child(root)
	return root


func _visible_text(node: Node) -> String:
	if node == null:
		return ""
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return ""
	var text := ""
	if node is Label and node.visible:
		text += (node as Label).text + "\n"
	if node is Button and node.visible:
		text += (node as Button).text + "\n"
	for child in node.get_children():
		text += _visible_text(child)
	return text


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _assert_float_equal(actual: float, expected: float, tolerance: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > tolerance:
		failures.append("%s (expected %.3f, got %.3f)" % [message, expected, actual])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("director time bands smoke check passed")
		quit(0)
		return

	push_error("director time bands smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
