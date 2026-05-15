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
	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	if runtime != null and runtime.has_method("debug_start_run"):
		runtime.debug_start_run()
	await process_frame
	await physics_frame

	var player := root.get_node_or_null("RunRoot/Actors/Players/Player") as Node3D
	var dog := root.get_node_or_null("RunRoot/Actors/Pets/Dog") as Node3D
	_assert_true(player != null, "run must spawn player", failures)
	_assert_true(dog != null and dog.visible, "run must spawn visible Dog follower", failures)
	_assert_true(dog == null or dog.get_node_or_null("CollisionShape3D") == null, "Dog must not have collision", failures)
	_assert_true(dog == null or dog.get_node_or_null("DogAura") == null, "Dog must not render or own a pickup aura", failures)
	_assert_true(runtime != null and runtime.has_method("debug_dog_fetch_range"), "runtime must expose Dog fetch range", failures)
	_assert_true(runtime != null and runtime.has_method("debug_set_dog_tier"), "runtime must expose Dog tier debug setter", failures)
	_assert_true(runtime != null and runtime.has_method("debug_dog_accepts_pickup_type"), "runtime must expose Dog pickup type gate", failures)
	_assert_true(runtime != null and runtime.has_method("debug_dog_feedback_text"), "runtime must expose Dog feedback text", failures)
	_assert_true(runtime != null and runtime.has_method("debug_set_xp_range_circles_visible"), "runtime must expose XP range debug circle toggle", failures)
	_assert_true(runtime != null and runtime.has_method("debug_xp_range_circle_count"), "runtime must expose XP range debug circle count", failures)

	if runtime != null and runtime.has_method("debug_xp_range_circle_count") and runtime.has_method("debug_set_xp_range_circles_visible"):
		_assert_true(runtime.debug_xp_range_circle_count() == 0, "XP range debug circles must be hidden by default", failures)
		runtime.debug_set_xp_range_circles_visible(true)
		await process_frame
		_assert_true(runtime.debug_xp_range_circle_count() == 2, "XP debug toggle must show player pickup and Dog fetch range circles", failures)
		_assert_true(_visible_named_count(root, "PlayerXPRangeCircle") == 1, "debug toggle must show player XP pickup range circle", failures)
		_assert_true(_visible_named_count(root, "DogXPFetchRangeCircle") == 1, "debug toggle must show Dog fetch range circle", failures)
		runtime.debug_set_xp_range_circles_visible(false)
		await process_frame
		_assert_true(runtime.debug_xp_range_circle_count() == 0, "XP debug toggle must hide range circles again", failures)

	if runtime != null and runtime.has_method("debug_dog_fetch_range") and runtime.has_method("debug_spawn_xp_pickup") and player != null:
		var tier_one_range := float(runtime.debug_dog_fetch_range())
		_assert_true(is_equal_approx(tier_one_range, 6.0), "Dog T1 fetch range must be 100% larger than default XP magnetism", failures)
		runtime.debug_spawn_xp_pickup(player.global_position + Vector3(tier_one_range - 0.15, 0.0, 0.0), 5)
		await physics_frame
		await physics_frame
		_assert_true(runtime.debug_xp_total() == 0, "Dog must not instantly credit pickups at range", failures)
		for frame_index in 90:
			await physics_frame
		_assert_true(runtime.debug_xp_total() == 5, "Dog must path to and fetch Color Motes inside extended pickup range", failures)
		_assert_true(runtime.debug_dog_feedback_text().contains("Dog fetch +5 XP"), "Dog pickup assist must expose fetch feedback text", failures)
		_assert_true(_visible_text(root.get_node_or_null("UI/HUD")).contains("Dog"), "HUD must show Dog pet icon/label feedback", failures)
		runtime.debug_spawn_xp_pickup(player.global_position + Vector3.LEFT * (tier_one_range - 0.15), 5)
		await physics_frame
		await physics_frame
		player.global_position = Vector3.RIGHT * 20.0
		for frame_index in 150:
			await physics_frame
		_assert_true(runtime.debug_xp_total() == 10, "Dog must finish an already-started fetch after player leaves fetch range", failures)

	if runtime != null and runtime.has_method("debug_dog_accepts_pickup_type") and runtime.has_method("debug_set_dog_tier") and runtime.has_method("debug_dog_fetch_range"):
		_assert_true(runtime.debug_dog_accepts_pickup_type(&"color_mote"), "Dog T1 must collect Color Motes", failures)
		_assert_true(not runtime.debug_dog_accepts_pickup_type(&"health"), "Dog T1 must not collect health pickups", failures)
		var tier_one_range := float(runtime.debug_dog_fetch_range())
		runtime.debug_set_dog_tier(2)
		_assert_true(runtime.debug_dog_accepts_pickup_type(&"health"), "Dog T2 must collect health pickups", failures)
		runtime.debug_set_dog_tier(3)
		_assert_true(float(runtime.debug_dog_fetch_range()) > tier_one_range, "Dog T3 must increase fetch range", failures)

	root.queue_free()
	await process_frame
	_finish(failures)


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


func _visible_named_count(node: Node, name_prefix: String) -> int:
	if node == null:
		return 0
	var count := 0
	if String(node.name).begins_with(name_prefix) and _node_visible(node):
		count += 1
	for child in node.get_children():
		count += _visible_named_count(child, name_prefix)
	return count


func _node_visible(node: Node) -> bool:
	if node is Node3D:
		return (node as Node3D).visible
	if node is CanvasItem:
		return (node as CanvasItem).visible
	return true


func _load_main(failures: Array[String]) -> Node:
	var packed_scene := load(MAIN_SCENE) as PackedScene
	_assert_true(packed_scene != null, "Main.tscn must load", failures)
	if packed_scene == null:
		return null
	var root := packed_scene.instantiate()
	get_root().add_child(root)
	return root


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("dog support pet smoke check passed")
		quit(0)
		return

	push_error("dog support pet smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
