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

	var director := root.get_node_or_null("RunRoot/RunDirector")
	var hud := root.get_node_or_null("UI/HUD")

	_assert_true(director != null and director.has_method("debug_active_budget"), "director must expose active budget", failures)
	_assert_true(director != null and director.has_method("debug_spawn_interval_seconds"), "director must expose spawn interval", failures)
	_assert_true(director != null and director.has_method("debug_current_time_band_id"), "director must expose current time band", failures)
	_assert_true(director != null and director.has_method("debug_force_run_time"), "director must support simulated run time for smoke", failures)
	_assert_true(director != null and director.has_method("debug_spawned_count"), "director must expose spawned count", failures)

	if director == null:
		_finish_after_root(root, failures)
		return

	var opening_budget: int = director.debug_active_budget()
	var opening_interval := 0.0
	if director.has_method("debug_spawn_interval_seconds"):
		opening_interval = director.debug_spawn_interval_seconds()
	if director.has_method("debug_current_time_band_id"):
		_assert_true(director.debug_current_time_band_id() == &"opening", "director must start in opening time band", failures)

	if director.has_method("debug_force_run_time"):
		director.debug_force_run_time(75.0)
		await physics_frame
		_assert_true(director.debug_active_budget() > opening_budget, "first pressure band must raise active budget", failures)
		_assert_true(director.debug_spawn_interval_seconds() < opening_interval, "first pressure band must lower spawn interval", failures)
		_assert_true(director.debug_current_time_band_id() == &"first_pressure", "75s must use first_pressure band", failures)

		var first_budget: int = director.debug_active_budget()
		var first_interval: float = director.debug_spawn_interval_seconds()
		director.debug_force_run_time(150.0)
		await physics_frame
		_assert_true(director.debug_active_budget() > first_budget, "second pressure band must raise active budget again", failures)
		_assert_true(director.debug_spawn_interval_seconds() < first_interval, "second pressure band must lower spawn interval again", failures)
		_assert_true(director.debug_current_time_band_id() == &"ink_surge", "150s must use ink_surge band", failures)

	_assert_true(director.debug_all_active_enemies_within_bounds(), "time band pressure must keep active enemies inside finite page bounds", failures)
	_assert_true(_hud_has_text(hud, "Budget") and _hud_has_text(hud, "Spawned"), "HUD must expose active budget and spawned count", failures)

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


func _hud_has_text(hud: Node, text_fragment: String) -> bool:
	if hud == null:
		return false
	for child in hud.get_children():
		if child is Label and child.text.contains(text_fragment):
			return true
	return false


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("director time bands smoke check passed")
		quit(0)
		return

	push_error("director time bands smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
