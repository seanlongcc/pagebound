class_name PrototypeContentFactory
extends RefCounted

const EnemyDataScript := preload("res://src/data/enemy_data.gd")
const PageboundTagDataScript := preload("res://src/data/pagebound_tag_data.gd")
const PassiveItemDataScript := preload("res://src/data/passive_item_data.gd")
const UpgradeChoiceDataScript := preload("res://src/data/upgrade_choice_data.gd")
const WeaponDataScript := preload("res://src/data/weapon_data.gd")
const WeaponLevelDataScript := preload("res://src/data/weapon_level_data.gd")

const PAGECRAFT_TAG_WAXLIGHT := &"waxlight"
const PAGECRAFT_TAG_STAR_STICKER := &"star_sticker"
const PAGECRAFT_TAG_DREAMSAP := &"dreamsap"
const PAGECRAFT_TAG_COLOR_BLOOM := &"color_bloom"
const TAG_FIRELIGHT := &"firelight"
const TAG_DREAMLIGHT := &"dreamlight"
const TAG_BINDING := &"binding"
const TAG_WATER := &"water"
const TAG_BLOOM := &"bloom"
const TAG_CLOUD := &"cloud"
const TAG_STAR := &"star"
const TAG_MOON := &"moon"
const TAG_HOSTILE_INK := &"hostile_ink"
const TAG_PROTOTYPE := &"prototype"
const WEAPON_WAXLIGHT_COMET := &"waxlight_comet"
const WEAPON_STAR_STICKER_SWARM := &"star_sticker_swarm"
const WEAPON_DREAMSAP_GLOB := &"dreamsap_glob"
const WEAPON_COLOR_BLOOM := &"color_bloom"
const PASSIVE_CANDLE_SPARK := &"candle_spark"
const ENEMY_INKLING_CHASER := &"inkling_chaser"
const ENEMY_PAPER_SCRAP_SWARMER := &"paper_scrap_swarmer"
const WAXLIGHT_RESOURCE_PATH := "res://data/weapons/prototype_waxlight_comet.tres"
const STAR_STICKER_RESOURCE_PATH := "res://data/weapons/prototype_star_sticker_swarm.tres"
const INKLING_RESOURCE_PATH := "res://data/enemies/prototype_inkling_chaser.tres"
const SWARMER_RESOURCE_PATH := "res://data/enemies/prototype_paper_scrap_swarmer.tres"
const CANDLE_SPARK_RESOURCE_PATH := "res://data/passives/prototype_candle_spark.tres"
const UPGRADE_RESOURCE_PATHS := [
	"res://data/upgrades/waxlight_damage_plus_1.tres",
	"res://data/upgrades/waxlight_cooldown_minus_10.tres",
	"res://data/upgrades/waxlight_duration_plus_1.tres",
	"res://data/upgrades/waxlight_mark_cap_plus_2.tres",
	"res://data/upgrades/player_max_hp_plus_10.tres",
]


## Registers minimal first-playable content into a schema registry.
func register_minimal_first_playable_content(registry) -> void:
	for tag in _prototype_tags():
		registry.register_tag(tag)
	for weapon in weapon_pool():
		registry.register_weapon(weapon)
	for enemy in all_enemy_families():
		registry.register_enemy(enemy)
	for passive in passive_items():
		registry.register_passive(passive)
	for upgrade in upgrade_choices():
		registry.register_upgrade(upgrade)


## Creates the placeholder Waxlight Comet weapon data.
func waxlight_comet_weapon() -> Resource:
	var resource := _load_resource(WAXLIGHT_RESOURCE_PATH)
	return resource if resource != null else _waxlight_comet_weapon()


## Creates or loads the documented Star Sticker Swarm weapon data.
func star_sticker_swarm_weapon() -> Resource:
	var resource := _load_resource(STAR_STICKER_RESOURCE_PATH)
	return resource if resource != null else _star_sticker_swarm_weapon()


## Creates the documented Dreamsap Glob weapon data.
func dreamsap_glob_weapon() -> Resource:
	return _dreamsap_glob_weapon()


## Creates the documented Color Bloom weapon data.
func color_bloom_weapon() -> Resource:
	return _color_bloom_weapon()


## Returns a weapon by stable content ID.
func weapon_for_id(weapon_id: StringName) -> Resource:
	match weapon_id:
		WEAPON_WAXLIGHT_COMET:
			return waxlight_comet_weapon()
		WEAPON_STAR_STICKER_SWARM:
			return star_sticker_swarm_weapon()
		WEAPON_DREAMSAP_GLOB:
			return dreamsap_glob_weapon()
		WEAPON_COLOR_BLOOM:
			return color_bloom_weapon()
	return null


## Creates the placeholder Inkling Chaser enemy data.
func inkling_chaser_enemy() -> Resource:
	var resource := _load_resource(INKLING_RESOURCE_PATH)
	return resource if resource != null else _inkling_chaser_enemy()


## Creates the placeholder Paper Scrap Swarmer enemy data.
func paper_scrap_swarmer_enemy() -> Resource:
	var resource := _load_resource(SWARMER_RESOURCE_PATH)
	return resource if resource != null else _paper_scrap_swarmer_enemy()


## Creates or loads the documented Candle Spark passive data.
func candle_spark_passive() -> Resource:
	var resource := _load_resource(CANDLE_SPARK_RESOURCE_PATH)
	return resource if resource != null else _candle_spark_passive()


## Creates all currently playable prototype weapons.
func weapon_pool() -> Array[Resource]:
	return [
		waxlight_comet_weapon(),
		star_sticker_swarm_weapon(),
		dreamsap_glob_weapon(),
		color_bloom_weapon(),
	]


## Creates all currently playable prototype passives.
func passive_items() -> Array[Resource]:
	return [
		candle_spark_passive(),
	]


## Creates all currently playable enemy families.
func all_enemy_families() -> Array[Resource]:
	return [
		inkling_chaser_enemy(),
		paper_scrap_swarmer_enemy(),
	]


## Creates prototype upgrade metadata from .tres resources or fallback data.
func upgrade_choices() -> Array[Resource]:
	var choices: Array[Resource] = []
	for path in UPGRADE_RESOURCE_PATHS:
		var resource := _load_resource(path)
		if resource != null:
			choices.append(resource)
	if choices.size() == UPGRADE_RESOURCE_PATHS.size():
		return choices
	return _fallback_upgrade_choices()


## Creates the first-playable director enemy pool.
func first_playable_enemy_pool() -> Array[Resource]:
	return [
		inkling_chaser_enemy(),
		paper_scrap_swarmer_enemy(),
	]


## Creates the opening enemy pool. Fast/weak family is intentionally delayed.
func opening_enemy_pool() -> Array[Resource]:
	return [
		inkling_chaser_enemy(),
	]


## Creates the pressure enemy pool after the first minute.
func pressure_enemy_pool() -> Array[Resource]:
	return first_playable_enemy_pool()


func _prototype_tags() -> Array[Resource]:
	return [
		_make_tag(PAGECRAFT_TAG_WAXLIGHT, "Waxlight", "material", "Friendly glowing wax mark."),
		_make_tag(PAGECRAFT_TAG_STAR_STICKER, "Star Sticker", "material", "Raised glossy sticker mark."),
		_make_tag(PAGECRAFT_TAG_DREAMSAP, "Dreamsap", "material", "Sticky dream sap puddle."),
		_make_tag(PAGECRAFT_TAG_COLOR_BLOOM, "Color Bloom", "material", "Growing color bloom zone."),
		_make_tag(TAG_FIRELIGHT, "Firelight", "catalyst", "Prototype fire/light evolution catalyst."),
		_make_tag(TAG_DREAMLIGHT, "Dreamlight", "material", "Soft storybook dream glow."),
		_make_tag(TAG_BINDING, "Binding", "catalyst", "Binding evolution catalyst."),
		_make_tag(TAG_WATER, "Water", "catalyst", "Water evolution catalyst."),
		_make_tag(TAG_BLOOM, "Bloom", "catalyst", "Bloom evolution catalyst."),
		_make_tag(TAG_CLOUD, "Cloud", "catalyst", "Cloud evolution catalyst."),
		_make_tag(TAG_STAR, "Star", "catalyst", "Star evolution catalyst."),
		_make_tag(TAG_MOON, "Moon", "catalyst", "Moon evolution catalyst."),
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


func _star_sticker_swarm_weapon() -> Resource:
	var weapon = WeaponDataScript.new()
	weapon.id = WEAPON_STAR_STICKER_SWARM
	weapon.display_name = "Star Sticker Swarm"
	weapon.description = "Documented orbit/attach weapon prototype. Sticker nodes strike nearby enemies and pop as primitive stars."
	weapon.tags = _string_name_array([TAG_PROTOTYPE])
	weapon.weapon_type_id = &"orbit_attach"
	weapon.attack_behavior_id = &"star_sticker_burst"
	weapon.material_tags = _string_name_array([PAGECRAFT_TAG_STAR_STICKER, TAG_DREAMLIGHT])
	weapon.catalyst_tags = _string_name_array([TAG_STAR, TAG_MOON])
	weapon.pagecraft_material_tag = PAGECRAFT_TAG_STAR_STICKER
	weapon.dash_interaction_id = &"sticker_dash_launch"
	weapon.levels = _star_sticker_levels()
	return weapon


func _dreamsap_glob_weapon() -> Resource:
	var weapon = WeaponDataScript.new()
	weapon.id = WEAPON_DREAMSAP_GLOB
	weapon.display_name = "Dreamsap Glob"
	weapon.description = "Documented puddle/snare weapon prototype. Drops sticky Dreamsap near enemy clusters."
	weapon.tags = _string_name_array([TAG_PROTOTYPE])
	weapon.weapon_type_id = &"puddle_snare"
	weapon.attack_behavior_id = &"dreamsap_glob"
	weapon.material_tags = _string_name_array([PAGECRAFT_TAG_DREAMSAP, TAG_BINDING])
	weapon.catalyst_tags = _string_name_array([TAG_BINDING, TAG_WATER])
	weapon.pagecraft_material_tag = PAGECRAFT_TAG_DREAMSAP
	weapon.dash_interaction_id = &"dreamsap_dash_snare"
	weapon.levels = _dreamsap_levels()
	return weapon


func _color_bloom_weapon() -> Resource:
	var weapon = WeaponDataScript.new()
	weapon.id = WEAPON_COLOR_BLOOM
	weapon.display_name = "Color Bloom"
	weapon.description = "Documented burst/growing-zone weapon prototype. Creates colorful blooms under enemy clusters."
	weapon.tags = _string_name_array([TAG_PROTOTYPE])
	weapon.weapon_type_id = &"burst_zone"
	weapon.attack_behavior_id = &"color_bloom"
	weapon.material_tags = _string_name_array([PAGECRAFT_TAG_COLOR_BLOOM, TAG_BLOOM])
	weapon.catalyst_tags = _string_name_array([TAG_BLOOM, TAG_CLOUD])
	weapon.pagecraft_material_tag = PAGECRAFT_TAG_COLOR_BLOOM
	weapon.dash_interaction_id = &"color_bloom_dash_splash"
	weapon.levels = _color_bloom_levels()
	return weapon


func _inkling_chaser_enemy() -> Resource:
	var enemy = EnemyDataScript.new()
	enemy.id = ENEMY_INKLING_CHASER
	enemy.display_name = "Inkling Chaser"
	enemy.description = "Primitive chaser enemy for first playable validation."
	enemy.tags = _string_name_array([TAG_HOSTILE_INK, TAG_PROTOTYPE])
	enemy.behavior_id = &"chaser"
	enemy.max_health = _opening_enemy_health()
	enemy.move_speed = 1.45
	enemy.contact_damage = 3.0
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
	enemy.move_speed = 3.2
	enemy.contact_damage = 3.0
	enemy.reward_xp = 1
	enemy.pagecraft_interaction_tags = _string_name_array([PAGECRAFT_TAG_WAXLIGHT])
	return enemy


func _candle_spark_passive() -> Resource:
	var passive = PassiveItemDataScript.new()
	passive.id = PASSIVE_CANDLE_SPARK
	passive.display_name = "Candle Spark"
	passive.description = "Documented Firelight/Waxlight passive. In prototype it gives a chunky Waxlight glow damage boost."
	passive.tags = _string_name_array([TAG_PROTOTYPE])
	passive.catalyst_tags = _string_name_array([TAG_FIRELIGHT, PAGECRAFT_TAG_WAXLIGHT])
	passive.stat_id = &"glow_damage_multiplier"
	passive.level_values = [0.15, 0.30, 0.45, 0.60, 0.75]
	return passive


func _weapon_levels() -> Array[Resource]:
	var levels: Array[Resource] = []
	for level in range(1, 11):
		var level_data = WeaponLevelDataScript.new()
		level_data.level = level
		level_data.base_damage = 5.0 + float(level - 1)
		level_data.cooldown_seconds = maxf(0.45, 1.15 - float(level - 1) * 0.04)
		level_data.mark_radius_meters = 0.65 + float(level - 1) * 0.03
		level_data.range_meters = 8.0 + float(level - 1) * 0.1
		levels.append(level_data)
	return levels


func _star_sticker_levels() -> Array[Resource]:
	var levels: Array[Resource] = []
	for level in range(1, 11):
		var level_data = WeaponLevelDataScript.new()
		level_data.level = level
		level_data.base_damage = 4.0 + float(level - 1) * 2.0
		level_data.cooldown_seconds = maxf(0.85, 2.0 - float(level - 1) * 0.06)
		level_data.mark_radius_meters = 0.4 + float(level - 1) * 0.02
		level_data.range_meters = 7.0 + float(level - 1) * 0.1
		levels.append(level_data)
	return levels


func _dreamsap_levels() -> Array[Resource]:
	var levels: Array[Resource] = []
	for level in range(1, 11):
		var level_data = WeaponLevelDataScript.new()
		level_data.level = level
		level_data.base_damage = 3.0 + float(level - 1) * 1.1
		level_data.cooldown_seconds = maxf(0.85, 2.0 - float(level - 1) * 0.05)
		level_data.mark_radius_meters = 0.8 + float(level - 1) * 0.03
		level_data.range_meters = 6.5 + float(level - 1) * 0.1
		levels.append(level_data)
	return levels


func _color_bloom_levels() -> Array[Resource]:
	var levels: Array[Resource] = []
	for level in range(1, 11):
		var level_data = WeaponLevelDataScript.new()
		level_data.level = level
		level_data.base_damage = 3.5 + float(level - 1) * 1.2
		level_data.cooldown_seconds = maxf(0.8, 1.8 - float(level - 1) * 0.05)
		level_data.mark_radius_meters = 0.75 + float(level - 1) * 0.04
		level_data.range_meters = 6.5 + float(level - 1) * 0.1
		levels.append(level_data)
	return levels


func _opening_enemy_health() -> float:
	var waxlight = waxlight_comet_weapon()
	if waxlight != null:
		return float(waxlight.level_data_for(1).base_damage) * 2.0
	return 10.0


func _fallback_upgrade_choices() -> Array[Resource]:
	return [
		_upgrade_choice(&"waxlight_damage_plus_1", "Waxlight damage +2", "Waxlight hits and active wax hit harder.", &"stat", &"waxlight_damage_plus_1", &"", &"", &"waxlight_damage", 2.0),
		_upgrade_choice(&"waxlight_cooldown_minus_10", "Waxlight cooldown -0.25s", "Waxlight Comet fires more often.", &"stat", &"waxlight_cooldown_minus_10", &"", &"", &"waxlight_cooldown", -0.25),
		_upgrade_choice(&"waxlight_duration_plus_1", "Waxlight duration +1s", "Activated wax stays dangerous longer.", &"stat", &"waxlight_duration_plus_1", &"", &"", &"waxlight_duration", 1.0),
		_upgrade_choice(&"waxlight_mark_cap_plus_2", "Max unactivated wax +3", "More dormant wax marks can exist at once.", &"stat", &"waxlight_mark_cap_plus_2", &"", &"", &"waxlight_mark_cap", 3.0),
		_upgrade_choice(&"player_max_hp_plus_10", "Player max HP +20", "Increase maximum HP and refill the new amount.", &"stat", &"player_max_hp_plus_10", &"", &"", &"player_max_hp", 20.0),
	]


func _upgrade_choice(
	id: StringName,
	display_name: String,
	description: String,
	choice_type: StringName,
	effect_id: StringName,
	weapon_id: StringName,
	passive_id: StringName,
	stat_id: StringName,
	value: float
) -> Resource:
	var choice = UpgradeChoiceDataScript.new()
	choice.id = id
	choice.display_name = display_name
	choice.description = description
	choice.tags = _string_name_array([TAG_PROTOTYPE])
	choice.choice_type = choice_type
	choice.effect_id = effect_id
	choice.weapon_id = weapon_id
	choice.passive_id = passive_id
	choice.stat_id = stat_id
	choice.value = value
	choice.effect_text = description
	choice.draft_weight = 1.0
	return choice


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


func _load_resource(path: String) -> Resource:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Resource
