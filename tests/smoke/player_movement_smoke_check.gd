extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const REQUIRED_ACTIONS := [
	"move_left",
	"move_right",
	"move_up",
	"move_down",
	"dash",
	"interact",
	"pause",
	"ui_accept",
	"ui_cancel",
]


func _initialize() -> void:
	var failures: Array[String] = []
	var root := _load_main(failures)
	if root == null:
		_finish(failures)
		return

	await process_frame
	await physics_frame

	for action in REQUIRED_ACTIONS:
		_assert_true(InputMap.has_action(action), "missing input action: %s" % action, failures)

	var player := root.get_node_or_null("RunRoot/Actors/Players/Player")
	_assert_true(player is CharacterBody3D, "player must spawn under Players root as CharacterBody3D", failures)
	if player != null:
		_assert_true(player.has_signal("dash_path_sampled"), "player must expose dash_path_sampled signal", failures)
		_assert_true(player.has_method("debug_integrate"), "player must expose debug_integrate for smoke tests", failures)
		_assert_player_moves_and_dashes(player, failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _load_main(failures: Array[String]) -> Node:
	var packed_scene := load(MAIN_SCENE) as PackedScene
	_assert_true(packed_scene != null, "Main.tscn must load", failures)
	if packed_scene == null:
		return null

	var root := packed_scene.instantiate()
	_assert_true(root is Node3D, "Main.tscn root must be Node3D", failures)
	if root == null:
		return null

	get_root().add_child(root)
	return root


func _assert_player_moves_and_dashes(player: Node, failures: Array[String]) -> void:
	var start_position: Vector3 = player.global_position
	player.debug_integrate(Vector2.RIGHT, false, 0.25)
	_assert_true(player.global_position.x > start_position.x + 0.1, "player must move on X/Z plane from input", failures)
	_assert_equal(roundf(player.global_position.y), roundf(start_position.y), "player movement must keep Y height stable", failures)

	player.global_position = Vector3.ZERO
	player.debug_integrate(Vector2.UP, false, 0.25)
	_assert_true(player.global_position.z < -0.1, "move_up/W must move toward page top, not down", failures)

	player.global_position = Vector3.ZERO
	player.debug_integrate(Vector2.RIGHT, false, 3.0)
	_assert_true(player.global_position.x <= 7.8, "player must be clamped inside finite page width", failures)

	player.global_position = Vector3.ZERO
	var dash_events: Array[Dictionary] = []
	player.dash_path_sampled.connect(func(start: Vector3, end: Vector3) -> void:
		dash_events.append({"start": start, "end": end})
	)
	player.debug_integrate(Vector2.RIGHT, true, 0.01)
	player.debug_integrate(Vector2.ZERO, false, 0.25)
	_assert_equal(dash_events.size(), 1, "dash must emit one dash path sample", failures)
	if not dash_events.is_empty():
		var dash_start: Vector3 = dash_events[0]["start"]
		var dash_end: Vector3 = dash_events[0]["end"]
		_assert_true(dash_end.distance_to(dash_start) > 1.0, "dash path must show travel distance", failures)


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _assert_equal(actual, expected, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s (expected: %s, actual: %s)" % [message, str(expected), str(actual)])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("player movement smoke check passed")
		quit(0)
		return

	push_error("player movement smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
