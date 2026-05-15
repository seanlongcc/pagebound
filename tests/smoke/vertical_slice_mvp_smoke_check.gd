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
	var hud := root.get_node_or_null("UI/HUD") as Control
	var modal_layer := root.get_node_or_null("UI/ModalLayer") as Control

	_assert_true(runtime != null and runtime.has_method("debug_run_started"), "runtime must expose run-start state", failures)
	_assert_true(runtime != null and runtime.has_method("debug_start_run"), "runtime must expose start-run helper", failures)
	_assert_true(_screen_visible(root, "StartScreen"), "boot must show start menu", failures)
	_assert_true(_visible_text(modal_layer).contains("Start Run"), "start menu must show Start Run action", failures)
	if runtime != null and runtime.has_method("debug_run_started"):
		_assert_true(not runtime.debug_run_started(), "run systems must be idle before start", failures)
	_assert_equal(_active_enemy_count(root), 0, "no enemies may spawn before start", failures)

	if runtime != null and runtime.has_method("debug_start_run"):
		runtime.debug_start_run()
	await process_frame
	await physics_frame

	var player := root.get_node_or_null("RunRoot/Actors/Players/Player")
	var director := root.get_node_or_null("RunRoot/RunDirector")
	var weapon_manager := root.get_node_or_null("RunRoot/Projectiles/WeaponManager")
	var pagecraft := root.get_node_or_null("RunRoot/Pagecraft/PagecraftManager")

	_assert_true(player is CharacterBody3D, "start must spawn player", failures)
	_assert_true(director != null, "start must create director", failures)
	_assert_true(weapon_manager != null, "start must create weapon manager", failures)
	_assert_true(not _screen_visible(root, "StartScreen"), "start must hide start menu", failures)
	if runtime != null and runtime.has_method("debug_run_started"):
		_assert_true(runtime.debug_run_started(), "runtime must report active run after start", failures)

	await _wait_physics_frames(20)

	if director != null and director.has_method("debug_spawned_enemy_ids"):
		var opening_ids: Array = director.debug_spawned_enemy_ids()
		_assert_true(opening_ids.has(&"wax_imp"), "opening must spawn Wax Imp family", failures)
		_assert_true(not opening_ids.has(&"flicker_imp"), "opening must not spawn Flicker Imp family", failures)
	if director != null and director.has_method("debug_safety_enemy_cap"):
		_assert_true(director.debug_safety_enemy_cap() >= 80, "safety cap must be high and not early pacing budget", failures)

	var opening_enemy := _first_enemy(root, &"wax_imp")
	var opening_health := _health(opening_enemy)
	if weapon_manager != null and weapon_manager.has_method("debug_weapon_damage") and opening_health != null:
		var star_damage := float(weapon_manager.debug_weapon_damage(&"star_sticker_swarm"))
		_assert_float_equal(opening_health.max_health, 70.0, 0.01, "opening Wax Imp HP must use tuned 70 HP baseline", failures)
		_assert_true(opening_health.max_health < star_damage, "opening Wax Imp must be one-shot by base Star Sticker Swarm", failures)
		if weapon_manager.has_method("debug_fire_weapon_at"):
			weapon_manager.debug_fire_weapon_at(&"star_sticker_swarm", opening_enemy)
			await physics_frame
			_assert_true(not opening_health.is_alive(), "opening normal enemy must die in one Star Sticker hit", failures)

	if director != null and director.has_method("debug_force_run_time"):
		director.debug_force_run_time(75.0)
	await _wait_physics_frames(90)
	if director != null and director.has_method("debug_spawned_enemy_ids"):
		_assert_true(director.debug_spawned_enemy_ids().has(&"flicker_imp"), "75s pressure band must allow Flicker Imp family", failures)
	if director != null and director.has_method("debug_force_run_time"):
		director.debug_force_run_time(180.0)
	await _wait_physics_frames(12)
	var later_enemy := _last_enemy(root)
	if later_enemy != null and later_enemy != opening_enemy:
		var later_health := _health(later_enemy)
		if later_health != null and opening_health != null:
			var later_base_health := 70.0
			if later_enemy.has_method("debug_enemy_id") and later_enemy.debug_enemy_id() == &"flicker_imp":
				later_base_health = 45.0
			_assert_true(later_health.max_health > later_base_health, "later enemies must scale above their authored base HP", failures)

	if player != null and player.has_method("debug_dash_distance"):
		_assert_float_equal(float(player.debug_dash_distance()), 2.1, 0.01, "default dash distance must be 2.1 meters", failures)
	if pagecraft != null and pagecraft.has_method("debug_deposit_test_mark") and player != null and player.has_method("debug_integrate") and runtime != null and runtime.has_method("debug_apply_upgrade_choice"):
		pagecraft.debug_clear_marks()
		player.global_position = Vector3.ZERO
		if player.has_method("debug_force_dash_ready"):
			player.debug_force_dash_ready()
		var activation_before: int = pagecraft.debug_activation_count()
		pagecraft.debug_deposit_test_mark(player.global_position + Vector3.RIGHT * 1.0)
		player.debug_integrate(Vector2.RIGHT, true, 0.01)
		player.debug_integrate(Vector2.ZERO, false, 0.4)
		_assert_true(pagecraft.debug_activation_count() == activation_before, "L1 Waxlight mark must not dash-activate before L5 payoff", failures)
		runtime.debug_apply_upgrade_choice(&"new_weapon_waxlight_comet")
		for _upgrade in 4:
			runtime.debug_apply_upgrade_choice(&"weapon_upgrade_waxlight_comet")
		pagecraft.debug_clear_marks()
		pagecraft.debug_deposit_test_mark(player.global_position + Vector3.RIGHT * 1.0)
		if player.has_method("debug_force_dash_ready"):
			player.debug_force_dash_ready()
		player.debug_integrate(Vector2.RIGHT, true, 0.01)
		player.debug_integrate(Vector2.ZERO, false, 0.4)
		_assert_true(pagecraft.debug_activation_count() > activation_before, "L5 Waxlight dash payoff must activate nearby marks", failures)

	var hud_text := _visible_text(hud)
	_assert_true(hud_text.contains("HP") and hud_text.contains("1000") and hud_text.contains("XP") and hud_text.contains("Level") and hud_text.contains("Dog"), "HUD must show player-facing HP, XP, Level, and Dog surfaces", failures)
	_assert_true(hud_text.contains("Star Sticker Swarm") and hud_text.contains("Lv1") and hud_text.contains("Empty"), "HUD must show loadout slots and starter Star level", failures)
	_assert_true(_find_named(root, "PartyReserve") == null or not (_find_named(root, "PartyReserve") as Control).visible, "solo HUD must not render top-left multiplayer placeholders", failures)
	_assert_true(_find_named(root, "RunTimer") != null and _visible_text(_find_named(root, "RunTimer")).contains(":"), "HUD must show constant run timer", failures)
	_assert_true(not hud_text.contains("Waxlight damage") and not hud_text.contains("Director"), "HUD must not show debug stat text", failures)
	if runtime != null and runtime.has_method("debug_apply_upgrade_choice"):
		runtime.debug_apply_upgrade_choice(&"weapon_upgrade_star_sticker_swarm")
		await physics_frame
		_assert_true(not _visible_text(hud).contains("Waxlight damage"), "direct stat upgrades must stay out of player HUD", failures)

	await _open_draft(runtime, player)
	_assert_true(runtime != null and runtime.has_method("debug_draft_choice_count") and runtime.debug_draft_choice_count() == 3, "draft must show exactly 3 choices", failures)
	var buttons := _draft_buttons(root)
	_assert_equal(buttons.size(), 3, "draft UI must contain exactly 3 choice buttons", failures)
	_assert_true(_buttons_are_horizontal(buttons), "draft cards must be in one horizontal row", failures)
	_assert_true(_buttons_contain_text(buttons, "->"), "draft cards must show current -> new values", failures)
	_assert_true(_buttons_contain_text(buttons, "Icon:") and _buttons_contain_text(buttons, "Tags:"), "draft cards must show icon and tag info", failures)
	_assert_true(not _buttons_contain_text(buttons, "Star Sticker Swarm +1"), "Star upgrade must name its specific stat/scope", failures)
	var candle_visible := _draft_contains_choice(runtime, &"new_passive_candle_spark")
	if candle_visible and runtime != null and runtime.has_method("debug_focus_draft_choice_id"):
		runtime.debug_focus_draft_choice_id(&"new_passive_candle_spark")
	if runtime != null and runtime.has_method("debug_accept_focused_draft_choice"):
		runtime.debug_accept_focused_draft_choice()
	if not candle_visible and runtime != null and runtime.has_method("debug_apply_upgrade_choice"):
		runtime.debug_apply_upgrade_choice(&"new_passive_candle_spark")
	await process_frame
	_assert_true(runtime != null and runtime.has_method("debug_owned_weapon_ids") and runtime.debug_owned_weapon_ids().has(&"star_sticker_swarm"), "run must keep Star starter weapon", failures)
	_assert_true(runtime != null and runtime.has_method("debug_owned_passive_ids") and runtime.debug_owned_passive_ids().has(&"candle_spark"), "selecting Candle Spark must add passive", failures)
	_assert_true(_visible_text(hud).contains("Candle Spark"), "HUD must show selected passive item", failures)

	await _open_draft(runtime, player)
	_assert_true(not _buttons_contain_text(_draft_buttons(root), "Star Sticker Swarm +1"), "owned weapon upgrade card must stay specific after passive selection", failures)
	if _draft_contains_choice(runtime, &"passive_upgrade_candle_spark"):
		_assert_true(_buttons_contain_text(_draft_buttons(root), "Candle Spark +1"), "owned package passive must keep upgrading", failures)
	elif runtime != null and runtime.has_method("debug_apply_upgrade_choice"):
		runtime.debug_apply_upgrade_choice(&"passive_upgrade_candle_spark")
	if runtime != null and runtime.has_method("debug_focus_draft_choice_id"):
		runtime.debug_focus_draft_choice_id(&"weapon_upgrade_star_sticker_swarm")
	if runtime != null and runtime.has_method("debug_accept_focused_draft_choice"):
		runtime.debug_accept_focused_draft_choice()
	await process_frame
	_assert_true(runtime != null and runtime.has_method("debug_owned_weapon_ids") and runtime.debug_owned_weapon_ids().has(&"star_sticker_swarm"), "Star upgrade must preserve starter weapon", failures)

	if runtime != null and runtime.has_method("debug_kill_player"):
		runtime.debug_kill_player()
	await process_frame
	_assert_true(_screen_visible(root, "DeathScreen"), "death screen must show after player death", failures)
	_assert_true(_visible_text(modal_layer).contains("Retry"), "death screen must include Retry", failures)
	_assert_true(_visible_text(modal_layer).contains("Main Menu"), "death screen must include Main Menu", failures)
	if runtime != null and runtime.has_method("debug_retry_run"):
		runtime.debug_retry_run()
	await process_frame
	await physics_frame
	_assert_true(runtime != null and runtime.has_method("debug_xp_total") and runtime.debug_xp_total() == 0, "retry must reset XP", failures)
	_assert_true(runtime != null and runtime.has_method("debug_run_level") and runtime.debug_run_level() == 1, "retry must reset level", failures)
	_assert_true(runtime != null and runtime.has_method("debug_owned_weapon_ids") and runtime.debug_owned_weapon_ids().size() == 1, "retry must reset weapons to starter", failures)

	if runtime != null and runtime.has_method("debug_force_run_time"):
		runtime.debug_force_run_time(300.0)
	await process_frame
	await physics_frame
	_assert_true(runtime != null and runtime.has_method("debug_active_page_event_id") and runtime.debug_active_page_event_id() == &"fill_color_well", "5:00 endpoint must retain documented Page Event state", failures)
	_assert_true(_visible_text(hud).contains("Fill the Color Well"), "HUD must show Page Event objective text by 5:00", failures)
	_assert_true(runtime != null and runtime.has_method("debug_run_ended") and not runtime.debug_run_ended(), "5:00 must not hard-stop the run", failures)
	_assert_true(not _screen_visible(root, "VictoryScreen"), "5:00 must not show vertical-slice summary", failures)

	if runtime != null and runtime.has_method("debug_return_to_main_menu"):
		runtime.debug_return_to_main_menu()
	await process_frame
	_assert_true(_screen_visible(root, "StartScreen"), "Main Menu must return to idle start menu", failures)
	if runtime != null and runtime.has_method("debug_run_started"):
		_assert_true(not runtime.debug_run_started(), "main menu must idle run systems", failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _open_draft(runtime: Node, player: Node) -> void:
	if runtime == null or player == null or not runtime.has_method("debug_spawn_xp_pickup"):
		return
	var guard := 0
	while runtime.has_method("debug_draft_is_open") and not runtime.debug_draft_is_open() and guard < 10:
		runtime.debug_spawn_xp_pickup((player as Node3D).global_position, 5)
		await physics_frame
		guard += 1


func _draft_contains_choice(runtime: Node, choice_id: StringName) -> bool:
	if runtime == null or not runtime.has_method("debug_draft_choice_count") or not runtime.has_method("debug_draft_choice_id_at"):
		return false
	for index in runtime.debug_draft_choice_count():
		if runtime.debug_draft_choice_id_at(index) == choice_id:
			return true
	return false


func _load_main(failures: Array[String]) -> Node:
	var packed_scene := load(MAIN_SCENE) as PackedScene
	_assert_true(packed_scene != null, "Main.tscn must load", failures)
	if packed_scene == null:
		return null
	var root := packed_scene.instantiate()
	get_root().add_child(root)
	return root


func _wait_physics_frames(count: int) -> void:
	for _index in count:
		await physics_frame


func _first_enemy(root: Node, enemy_id: StringName) -> Node3D:
	for child in root.get_node("RunRoot/Actors/Enemies").get_children():
		if child is Node3D and child.has_method("debug_enemy_id") and child.debug_enemy_id() == enemy_id:
			return child
	return null


func _last_enemy(root: Node) -> Node3D:
	var result: Node3D = null
	for child in root.get_node("RunRoot/Actors/Enemies").get_children():
		if child is Node3D:
			result = child
	return result


func _first_living_enemy(root: Node) -> Node3D:
	for child in root.get_node("RunRoot/Actors/Enemies").get_children():
		if child is Node3D:
			var health := _health(child)
			if health != null and health.is_alive() and child.visible:
				return child
	return null


func _active_enemy_count(root: Node) -> int:
	var count := 0
	for child in root.get_node("RunRoot/Actors/Enemies").get_children():
		if child is Node3D and child.visible:
			count += 1
	return count


func _health(node: Node) -> Node:
	if node == null:
		return null
	return node.get_node_or_null("HealthComponent")


func _screen_visible(root: Node, screen_name: String) -> bool:
	var screen := _find_named(root, screen_name) as Control
	return screen != null and screen.visible


func _find_named(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child in node.get_children():
		var found := _find_named(child, node_name)
		if found != null:
			return found
	return null


func _draft_buttons(root: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	_collect_draft_buttons(root, buttons)
	return buttons


func _collect_draft_buttons(node: Node, buttons: Array[Button]) -> void:
	if node is Button and String(node.name).begins_with("DraftChoice") and node.visible:
		buttons.append(node)
	for child in node.get_children():
		_collect_draft_buttons(child, buttons)


func _buttons_are_horizontal(buttons: Array[Button]) -> bool:
	if buttons.size() != 3:
		return false
	return absf(buttons[0].global_position.y - buttons[1].global_position.y) < 8.0 and absf(buttons[1].global_position.y - buttons[2].global_position.y) < 8.0 and buttons[0].global_position.x < buttons[1].global_position.x and buttons[1].global_position.x < buttons[2].global_position.x


func _buttons_contain_text(buttons: Array[Button], text: String) -> bool:
	for button in buttons:
		if _visible_text(button).contains(text):
			return true
	return false


func _visible_text(node: Node) -> String:
	if node == null:
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


func _assert_equal(actual, expected, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s (expected: %s, actual: %s)" % [message, str(expected), str(actual)])


func _assert_float_equal(actual: float, expected: float, tolerance: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > tolerance:
		failures.append("%s (expected: %.3f, actual: %.3f)" % [message, expected, actual])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("vertical slice MVP smoke check passed")
		quit(0)
		return

	push_error("vertical slice MVP smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
