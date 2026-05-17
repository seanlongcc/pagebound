extends SceneTree

const AutoWeaponManagerScript := preload("res://src/weapons/auto_weapon_manager.gd")
const DamageModelScript := preload("res://src/combat/damage_model.gd")
const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RuntimeEventBusScript := preload("res://src/events/runtime_event_bus.gd")
const RunUpgradeStateScript := preload("res://src/runtime/run_upgrade_state.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var factory = PrototypeContentFactoryScript.new()
	var waxlight = factory.waxlight_comet_weapon()
	var star = factory.star_sticker_swarm_weapon()

	_assert_true(waxlight != null, "Waxlight Comet resource must load", failures)
	_assert_true(star != null, "Star Sticker Swarm resource must load", failures)
	_assert_true(waxlight != null and "base_damage" in waxlight, "WeaponData must expose one editable base_damage field", failures)
	_assert_true(waxlight != null and "base_cooldown_seconds" in waxlight, "WeaponData must expose one editable base_cooldown_seconds field", failures)
	_assert_true(waxlight != null and "base_mark_radius_meters" in waxlight, "WeaponData must expose one editable base_mark_radius_meters field", failures)
	_assert_true(waxlight != null and "base_range_meters" in waxlight, "WeaponData must expose one editable base_range_meters field", failures)

	var owner := Node3D.new()
	owner.name = "BaseStatsOwner"
	get_root().add_child(owner)
	var enemies_root := Node3D.new()
	enemies_root.name = "BaseStatsEnemies"
	get_root().add_child(enemies_root)
	var event_bus := RuntimeEventBusScript.new()
	get_root().add_child(event_bus)
	var damage_model = DamageModelScript.new()
	damage_model.configure(event_bus)
	var upgrade_state = RunUpgradeStateScript.new()
	upgrade_state.configure(factory)
	var manager = AutoWeaponManagerScript.new()
	get_root().add_child(manager)
	manager.configure(owner, enemies_root, damage_model, star, null, upgrade_state, factory)

	_assert_true(upgrade_state.owned_weapon_ids() == [&"star_sticker_swarm"], "run must start with Star Sticker Swarm only", failures)
	_assert_true(manager.has_method("debug_weapon_cooldown_seconds"), "weapon manager must expose per-weapon cooldown debug", failures)
	var star_damage := manager.debug_weapon_damage(&"star_sticker_swarm")
	var star_cooldown := manager.debug_weapon_cooldown_seconds(&"star_sticker_swarm") if manager.has_method("debug_weapon_cooldown_seconds") else 0.0
	var star_range := manager.debug_weapon_range_meters(&"star_sticker_swarm")
	_assert_true(is_equal_approx(star_damage, 100.0), "Star Sticker Swarm base damage must start at authored base 100", failures)
	_assert_true(is_equal_approx(star_cooldown, 1.0), "Star Sticker Swarm base cooldown must start at tuned base 1.0s", failures)
	_assert_true(is_equal_approx(star_range, 8.0), "Star Sticker Swarm base range must start at tuned base 8.0m", failures)
	_assert_true(is_equal_approx(manager.debug_weapon_damage(&"waxlight_comet"), 45.0), "Waxlight base damage must start at authored AoE base 45", failures)
	_assert_true(is_equal_approx(manager.debug_cooldown_seconds(), 0.9), "Waxlight base cooldown must start at tuned AoE base 0.9s", failures)
	_assert_true(is_equal_approx(manager.debug_weapon_range_meters(&"waxlight_comet"), 6.5), "Waxlight base range must start at tuned 6.5m and stay below Star", failures)

	var first_upgrade: Dictionary = upgrade_state.apply_choice(upgrade_state.debug_weapon_upgrade_choice_id(&"star_sticker_swarm", &"damage"))
	manager.refresh_runtime_modifiers()
	_assert_true(not first_upgrade.is_empty(), "Selected Star Sticker damage upgrade must apply", failures)
	_assert_true(upgrade_state.weapon_level(&"star_sticker_swarm") == 2, "Star progress must increment to level 2 after selected upgrade", failures)
	_assert_true(manager.debug_weapon_damage(&"star_sticker_swarm") > star_damage, "Selected Star damage upgrade must increase Star damage", failures)
	_assert_true(is_equal_approx(manager.debug_weapon_cooldown_seconds(&"star_sticker_swarm"), star_cooldown), "Damage upgrade must not change Star cooldown", failures)
	_assert_true(is_equal_approx(manager.debug_weapon_range_meters(&"star_sticker_swarm"), star_range), "Damage upgrade must not change Star range", failures)

	var damage_after_upgrade := manager.debug_weapon_damage(&"star_sticker_swarm")
	var second_upgrade: Dictionary = upgrade_state.apply_choice(upgrade_state.debug_weapon_upgrade_choice_id(&"star_sticker_swarm", &"range"))
	manager.refresh_runtime_modifiers()
	_assert_true(not second_upgrade.is_empty(), "Selected Star Sticker range upgrade must apply", failures)
	_assert_true(upgrade_state.weapon_level(&"star_sticker_swarm") == 3, "Star progress must increment to level 3 after second upgrade", failures)
	_assert_true(is_equal_approx(manager.debug_weapon_damage(&"star_sticker_swarm"), damage_after_upgrade), "Selected non-damage Star upgrade must not add free damage", failures)
	_assert_true(manager.debug_weapon_range_meters(&"star_sticker_swarm") > star_range, "Selected Star range upgrade must increase node/orbit range", failures)

	manager.queue_free()
	event_bus.queue_free()
	enemies_root.queue_free()
	owner.queue_free()
	await process_frame

	_finish(failures)


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("weapon base stats smoke check passed")
		quit(0)
		return

	push_error("weapon base stats smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
