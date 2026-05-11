class_name PrototypeContentFactory
extends RefCounted

const EnemyDataScript := preload("res://src/data/enemy_data.gd")
const PageboundTagDataScript := preload("res://src/data/pagebound_tag_data.gd")
const WeaponDataScript := preload("res://src/data/weapon_data.gd")
const WeaponLevelDataScript := preload("res://src/data/weapon_level_data.gd")

const PAGECRAFT_TAG_WAXLIGHT := &"waxlight"
const TAG_FIRELIGHT := &"firelight"
const TAG_HOSTILE_INK := &"hostile_ink"
const TAG_PROTOTYPE := &"prototype"
const WEAPON_WAXLIGHT_COMET := &"waxlight_comet"
const ENEMY_INKLING_CHASER := &"inkling_chaser"
const ENEMY_PAPER_SCRAP_SWARMER := &"paper_scrap_swarmer"


## Registers minimal first-playable content into a schema registry.
func register_minimal_first_playable_content(registry) -> void:
	for tag in _prototype_tags():
		registry.register_tag(tag)
	registry.register_weapon(_waxlight_comet_weapon())
	registry.register_enemy(_inkling_chaser_enemy())
	registry.register_enemy(_paper_scrap_swarmer_enemy())


## Creates the placeholder Waxlight Comet weapon data.
func waxlight_comet_weapon() -> Resource:
	return _waxlight_comet_weapon()


## Creates the placeholder Inkling Chaser enemy data.
func inkling_chaser_enemy() -> Resource:
	return _inkling_chaser_enemy()


## Creates the placeholder Paper Scrap Swarmer enemy data.
func paper_scrap_swarmer_enemy() -> Resource:
	return _paper_scrap_swarmer_enemy()


## Creates the first-playable director enemy pool.
func first_playable_enemy_pool() -> Array[Resource]:
	return [
		_inkling_chaser_enemy(),
		_paper_scrap_swarmer_enemy(),
	]


func _prototype_tags() -> Array[Resource]:
	return [
		_make_tag(PAGECRAFT_TAG_WAXLIGHT, "Waxlight", "material", "Friendly glowing wax mark."),
		_make_tag(TAG_FIRELIGHT, "Firelight", "catalyst", "Prototype fire/light evolution catalyst."),
		_make_tag(TAG_HOSTILE_INK, "Hostile Ink", "trait", "Ink enemy trait."),
		_make_tag(TAG_PROTOTYPE, "Prototype", "authoring", "Primitive placeholder content."),
	]


func _waxlight_comet_weapon() -> Resource:
	var weapon = WeaponDataScript.new()
	weapon.id = WEAPON_WAXLIGHT_COMET
	weapon.display_name = "Waxlight Comet"
	weapon.description = "Prototype auto-attack that strikes the nearest enemy and leaves a waxlight mark."
	weapon.tags = _string_name_array([TAG_PROTOTYPE])
	weapon.weapon_type_id = &"direct_nearest"
	weapon.attack_behavior_id = &"nearest_direct_hit"
	weapon.material_tags = _string_name_array([PAGECRAFT_TAG_WAXLIGHT, TAG_FIRELIGHT])
	weapon.catalyst_tags = _string_name_array([TAG_FIRELIGHT, PAGECRAFT_TAG_WAXLIGHT])
	weapon.pagecraft_material_tag = PAGECRAFT_TAG_WAXLIGHT
	weapon.dash_interaction_id = &"waxlight_dash_pulse"
	weapon.levels = _weapon_levels()
	return weapon


func _inkling_chaser_enemy() -> Resource:
	var enemy = EnemyDataScript.new()
	enemy.id = ENEMY_INKLING_CHASER
	enemy.display_name = "Inkling Chaser"
	enemy.description = "Primitive chaser enemy for first playable validation."
	enemy.tags = _string_name_array([TAG_HOSTILE_INK, TAG_PROTOTYPE])
	enemy.behavior_id = &"chaser"
	enemy.max_health = 18.0
	enemy.move_speed = 2.1
	enemy.contact_damage = 5.0
	enemy.reward_xp = 1
	enemy.pagecraft_interaction_tags = _string_name_array([PAGECRAFT_TAG_WAXLIGHT])
	return enemy


func _paper_scrap_swarmer_enemy() -> Resource:
	var enemy = EnemyDataScript.new()
	enemy.id = ENEMY_PAPER_SCRAP_SWARMER
	enemy.display_name = "Paper Scrap Swarmer"
	enemy.description = "Primitive fast weak swarmer enemy for first playable validation."
	enemy.tags = _string_name_array([TAG_HOSTILE_INK, TAG_PROTOTYPE])
	enemy.behavior_id = &"swarmer"
	enemy.max_health = 8.0
	enemy.move_speed = 4.3
	enemy.contact_damage = 5.0
	enemy.reward_xp = 1
	enemy.pagecraft_interaction_tags = _string_name_array([PAGECRAFT_TAG_WAXLIGHT])
	return enemy


func _weapon_levels() -> Array[Resource]:
	var levels: Array[Resource] = []
	for level in range(1, 11):
		var level_data = WeaponLevelDataScript.new()
		level_data.level = level
		level_data.base_damage = 5.0 + float(level - 1)
		level_data.cooldown_seconds = maxf(0.45, 1.15 - float(level - 1) * 0.04)
		level_data.mark_radius_meters = 0.65 + float(level - 1) * 0.03
		levels.append(level_data)
	return levels


func _make_tag(id: StringName, display_name: String, category: String, description: String) -> Resource:
	var tag = PageboundTagDataScript.new()
	tag.id = id
	tag.display_name = display_name
	tag.category = category
	tag.description = description
	return tag


func _string_name_array(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		result.append(value)
	return result
