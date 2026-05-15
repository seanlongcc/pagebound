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

	_assert_true(waxlight != null, "Waxlight Comet resource must load", failures)
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
	manager.configure(owner, enemies_root, damage_model, waxlight, null, upgrade_state, factory)

	var base_damage := manager.debug_weapon_damage(&"waxlight_comet")
	var base_cooldown := manager.debug_cooldown_seconds()
	var base_range := manager.debug_weapon_range_meters(&"waxlight_comet")
	_assert_true(is_equal_approx(base_damage, 100.0), "Waxlight base damage must start at authored base 100", failures)
	_assert_true(is_equal_approx(base_cooldown, 1.15), "Waxlight base cooldown must start at authored base 1.15s", failures)
	_assert_true(is_equal_approx(base_range, 12.0), "Waxlight base range must start at authored base 12m", failures)

	var first_upgrade: Dictionary = upgrade_state.apply_choice(&"weapon_upgrade_waxlight_comet")
	manager.refresh_runtime_modifiers()
	_assert_true(not first_upgrade.is_empty(), "First Waxlight upgrade must apply", failures)
	_assert_true(upgrade_state.weapon_level(&"waxlight_comet") == 2, "Weapon progress must increment to level 2 after first upgrade", failures)
	_assert_true(is_equal_approx(manager.debug_weapon_damage(&"waxlight_comet"), 110.0), "First +10% damage upgrade must produce 100 * 1.10 = 110, with no free level-row damage", failures)
	_assert_true(is_equal_approx(manager.debug_cooldown_seconds(), base_cooldown), "Damage upgrade must not change cooldown", failures)
	_assert_true(is_equal_approx(manager.debug_weapon_range_meters(&"waxlight_comet"), base_range), "Damage upgrade must not change range", failures)

	var second_upgrade: Dictionary = upgrade_state.apply_choice(&"weapon_upgrade_waxlight_comet")
	manager.refresh_runtime_modifiers()
	_assert_true(not second_upgrade.is_empty(), "Second Waxlight upgrade must apply", failures)
	_assert_true(upgrade_state.weapon_level(&"waxlight_comet") == 3, "Weapon progress must increment to level 3 after second upgrade", failures)
	_assert_true(is_equal_approx(manager.debug_weapon_damage(&"waxlight_comet"), 110.0), "Second non-damage upgrade must not add free damage", failures)
	_assert_true(is_equal_approx(manager.debug_cooldown_seconds(), base_cooldown), "Second non-cadence upgrade must not change cooldown", failures)
	_assert_true(is_equal_approx(manager.debug_weapon_range_meters(&"waxlight_comet"), base_range), "Second non-range upgrade must not change range", failures)

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
