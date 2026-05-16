class_name StarterWeaponSelection
extends RefCounted

const DEFAULT_STARTER_WEAPON_ID := &"star_sticker_swarm"
const STARTER_WEAPON_IDS := [
	&"star_sticker_swarm",
	&"waxlight_comet",
]


func starter_weapon_options(content_factory) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	for weapon_id in STARTER_WEAPON_IDS:
		var weapon := _weapon_for_id(content_factory, weapon_id)
		if weapon == null:
			continue
		options.append({
			"id": weapon.id,
			"display_name": weapon.display_name,
			"detail": "%s damage / %.2fs / %.1fm" % [str(int(weapon.base_damage)), weapon.base_cooldown_seconds, weapon.base_range_meters],
		})
	return options


func starter_weapon_data(content_factory, upgrade_state) -> Resource:
	var starter_weapon_id := DEFAULT_STARTER_WEAPON_ID
	if upgrade_state != null and upgrade_state.has_method("starter_weapon_id"):
		starter_weapon_id = upgrade_state.starter_weapon_id()
	var weapon := _weapon_for_id(content_factory, starter_weapon_id)
	if weapon != null:
		return weapon
	return _weapon_for_id(content_factory, DEFAULT_STARTER_WEAPON_ID)


func _weapon_for_id(content_factory, weapon_id: StringName) -> Resource:
	if content_factory != null and content_factory.has_method("weapon_for_id"):
		return content_factory.weapon_for_id(weapon_id)
	return null
