extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const HealthComponentScript := preload("res://src/combat/health_component.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var root := _load_main(failures)
	if root == null:
		_finish(failures)
		return

	await process_frame
	await physics_frame

	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var player := root.get_node_or_null("RunRoot/Actors/Players/Player") as CharacterBody3D
	var weapon_manager := root.get_node_or_null("RunRoot/Projectiles/WeaponManager")
	var pagecraft_manager := root.get_node_or_null("RunRoot/Pagecraft/PagecraftManager")
	var enemies_root := root.get_node_or_null("RunRoot/Actors/Enemies")
	var event_bus := root.get_node_or_null("RunRoot/RuntimeEventBus")
	var hud := root.get_node_or_null("UI/HUD")
	var upgrade_events: Array[Dictionary] = []

	_assert_true(runtime != null and runtime.has_method("debug_focus_draft_choice_index"), "runtime must expose draft focus helper", failures)
	_assert_true(runtime != null and runtime.has_method("debug_waxlight_damage_bonus"), "runtime must expose Waxlight damage bonus", failures)
	_assert_true(runtime != null and runtime.has_method("debug_waxlight_cooldown_multiplier"), "runtime must expose Waxlight cooldown multiplier", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_next_hit_damage"), "weapon manager must expose next hit damage", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_cooldown_seconds"), "weapon manager must expose runtime cooldown", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_fire_at"), "weapon manager must expose smoke fire helper", failures)
	_assert_true(pagecraft_manager != null and pagecraft_manager.has_method("debug_last_mark_position"), "Pagecraft manager must expose last mark position", failures)
	_assert_true(event_bus != null and event_bus.has_signal("upgrade_applied"), "event bus must emit upgrade applied event", failures)

	if event_bus != null and event_bus.has_signal("upgrade_applied"):
		event_bus.upgrade_applied.connect(func(event: Dictionary) -> void:
			upgrade_events.append(event)
		)

	var base_damage := 0.0
	var base_cooldown := 0.0
	if weapon_manager != null and weapon_manager.has_method("debug_next_hit_damage"):
		base_damage = weapon_manager.debug_next_hit_damage()
	if weapon_manager != null and weapon_manager.has_method("debug_cooldown_seconds"):
		base_cooldown = weapon_manager.debug_cooldown_seconds()

	await _collect_motes(runtime, player, 3)
	if runtime != null and runtime.has_method("debug_accept_focused_draft_choice"):
		runtime.debug_accept_focused_draft_choice()
		await process_frame

	if runtime != null and runtime.has_method("debug_waxlight_damage_bonus"):
		_assert_true(is_equal_approx(runtime.debug_waxlight_damage_bonus(), 1.0), "Waxlight damage choice must add +1 runtime damage", failures)
	if weapon_manager != null and weapon_manager.has_method("debug_next_hit_damage"):
		_assert_true(is_equal_approx(weapon_manager.debug_next_hit_damage(), base_damage + 1.0), "future Waxlight hits must use upgraded damage", failures)

	var hit_victim := _spawn_victim(enemies_root, "UpgradeHitVictim", player.global_position + Vector3.RIGHT * 1.2, 20.0)
	if weapon_manager != null and weapon_manager.has_method("debug_fire_at"):
		weapon_manager.debug_fire_at(hit_victim)
		await process_frame
	if hit_victim != null:
		var hit_health := hit_victim.get_node("HealthComponent")
		_assert_true(is_equal_approx(hit_health.current_health, 20.0 - (base_damage + 1.0)), "upgraded Waxlight hit must damage enemy for upgraded amount", failures)

	var mark_position := Vector3.ZERO
	if pagecraft_manager != null and pagecraft_manager.has_method("debug_last_mark_position"):
		mark_position = pagecraft_manager.debug_last_mark_position()
	var dash_victim := _spawn_victim(enemies_root, "UpgradeDashVictim", mark_position + Vector3(0.2, 0.0, 0.0), 20.0)
	if pagecraft_manager != null and pagecraft_manager.has_method("activate_path"):
		pagecraft_manager.activate_path(mark_position - Vector3.RIGHT * 0.8, mark_position + Vector3.RIGHT * 0.8)
		await process_frame
		await physics_frame
	if dash_victim != null:
		var dash_health := dash_victim.get_node("HealthComponent")
		_assert_true(dash_health.current_health <= 20.0 - (base_damage + 1.0), "upgraded Waxlight mark activation must damage enemy with upgraded profile", failures)
	if pagecraft_manager != null and pagecraft_manager.has_method("debug_last_activation_damage"):
		_assert_true(is_equal_approx(pagecraft_manager.debug_last_activation_damage(), base_damage + 1.0), "upgraded Waxlight activation damage amount must use same damage profile", failures)

	await _collect_motes(runtime, player, 6)
	if runtime != null and runtime.has_method("debug_focus_draft_choice_index"):
		runtime.debug_focus_draft_choice_index(0)
	if runtime != null and runtime.has_method("debug_accept_focused_draft_choice"):
		runtime.debug_accept_focused_draft_choice()
		await process_frame
	if runtime != null and runtime.has_method("debug_waxlight_cooldown_multiplier"):
		_assert_true(is_equal_approx(runtime.debug_waxlight_cooldown_multiplier(), 0.9), "Waxlight cooldown choice must apply -10% multiplier", failures)
	if weapon_manager != null and weapon_manager.has_method("debug_cooldown_seconds"):
		_assert_true(is_equal_approx(weapon_manager.debug_cooldown_seconds(), base_cooldown * 0.9), "weapon cooldown must use runtime cooldown upgrade", failures)

	await _collect_motes(runtime, player, 10)
	if runtime != null and runtime.has_method("debug_focus_draft_choice_index"):
		runtime.debug_focus_draft_choice_index(0)
	if runtime != null and runtime.has_method("debug_accept_focused_draft_choice"):
		runtime.debug_accept_focused_draft_choice()
		await process_frame
	if runtime != null and runtime.has_method("debug_player_max_health"):
		_assert_true(is_equal_approx(runtime.debug_player_max_health(), 60.0), "HP upgrade must raise HealthComponent max HP to 60", failures)
	_assert_true(_hud_has_text(hud, "/60"), "HUD must show upgraded max HP", failures)
	_assert_true(upgrade_events.size() == 3, "each selected draft choice must emit upgrade applied event", failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _collect_motes(runtime: Node, player: CharacterBody3D, amount: int) -> void:
	if runtime == null or player == null or not runtime.has_method("debug_spawn_xp_pickup"):
		return
	for mote_index in amount:
		runtime.debug_spawn_xp_pickup(player.global_position, 1)
		for frame_index in 3:
			await physics_frame


func _spawn_victim(enemies_root: Node, node_name: String, position: Vector3, max_health: float) -> CharacterBody3D:
	if enemies_root == null:
		return null
	var victim := CharacterBody3D.new()
	victim.name = node_name
	enemies_root.add_child(victim)
	victim.global_position = position
	var health := HealthComponentScript.new()
	health.name = "HealthComponent"
	victim.add_child(health)
	health.configure(StringName(node_name.to_snake_case()), max_health, &"enemy")
	return victim


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
		print("upgrade effects smoke check passed")
		quit(0)
		return

	push_error("upgrade effects smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
