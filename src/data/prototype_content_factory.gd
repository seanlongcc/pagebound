class_name PrototypeContentFactory
extends RefCounted

const EnemyDataScript := preload("res://src/data/enemy_data.gd")
const PageboundTagDataScript := preload("res://src/data/pagebound_tag_data.gd")
const PassiveItemDataScript := preload("res://src/data/passive_item_data.gd")
const UpgradeChoiceDataScript := preload("res://src/data/upgrade_choice_data.gd")
const WeaponDataScript := preload("res://src/data/weapon_data.gd")

const PAGECRAFT_TAG_WAXLIGHT := &"waxlight"
const PAGECRAFT_TAG_STAR_STICKER := &"star_sticker"
const PAGECRAFT_TAG_DREAMSAP := &"dreamsap"
const PAGECRAFT_TAG_COLOR_BLOOM := &"color_bloom"
const TAG_FIRELIGHT := &"firelight"
const TAG_LIGHT := &"light"
const TAG_DREAMLIGHT := &"dreamlight"
const TAG_DREAM := &"dream"
const TAG_THREAD := &"thread"
const TAG_ECHO := &"echo"
const TAG_WONDER := &"wonder"
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
const PASSIVE_CLOUD_SEED := &"cloud_seed"
const PASSIVE_DREAM_THREAD := &"dream_thread"
const PASSIVE_RIBBON_SPOOL := &"ribbon_spool"
const PASSIVE_MOON_BUTTON := &"moon_button"
const ENEMY_WAX_IMP := &"wax_imp"
const ENEMY_FLICKER_IMP := &"flicker_imp"
const WAXLIGHT_RESOURCE_PATH := "res://data/weapons/prototype_waxlight_comet.tres"
const STAR_STICKER_RESOURCE_PATH := "res://data/weapons/prototype_star_sticker_swarm.tres"
const WAX_IMP_RESOURCE_PATH := "res://data/enemies/prototype_wax_imp.tres"
const FLICKER_IMP_RESOURCE_PATH := "res://data/enemies/prototype_flicker_imp.tres"
const CANDLE_SPARK_RESOURCE_PATH := "res://data/passives/prototype_candle_spark.tres"
const CLOUD_SEED_RESOURCE_PATH := "res://data/passives/prototype_cloud_seed.tres"
const DREAM_THREAD_RESOURCE_PATH := "res://data/passives/prototype_dream_thread.tres"
const RIBBON_SPOOL_RESOURCE_PATH := "res://data/passives/prototype_ribbon_spool.tres"
const MOON_BUTTON_RESOURCE_PATH := "res://data/passives/prototype_moon_button.tres"
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


## Creates the documented opening Wax Imp enemy data.
func wax_imp_enemy() -> Resource:
	var resource := _load_resource(WAX_IMP_RESOURCE_PATH)
	return resource if resource != null else _wax_imp_enemy()


## Creates the documented delayed Flicker Imp enemy data.
func flicker_imp_enemy() -> Resource:
	var resource := _load_resource(FLICKER_IMP_RESOURCE_PATH)
	return resource if resource != null else _flicker_imp_enemy()


## Creates or loads the documented Candle Spark passive data.
func candle_spark_passive() -> Resource:
	var resource := _load_resource(CANDLE_SPARK_RESOURCE_PATH)
	return resource if resource != null else _candle_spark_passive()


func cloud_seed_passive() -> Resource:
	return _load_or_make_passive(CLOUD_SEED_RESOURCE_PATH, PASSIVE_CLOUD_SEED, "Cloud Seed", "Common size passive.", [TAG_BLOOM, TAG_WONDER], &"size")


func dream_thread_passive() -> Resource:
	return _load_or_make_passive(DREAM_THREAD_RESOURCE_PATH, PASSIVE_DREAM_THREAD, "Dream Thread", "Common duration passive.", [TAG_DREAM, TAG_THREAD], &"duration")


func ribbon_spool_passive() -> Resource:
	return _load_or_make_passive(RIBBON_SPOOL_RESOURCE_PATH, PASSIVE_RIBBON_SPOOL, "Ribbon Spool", "Common range passive.", [TAG_THREAD, TAG_STAR], &"range")


func moon_button_passive() -> Resource:
	return _load_or_make_passive(MOON_BUTTON_RESOURCE_PATH, PASSIVE_MOON_BUTTON, "Moon Button", "Common cadence passive.", [TAG_MOON, TAG_ECHO], &"cadence")


func passive_for_id(passive_id: StringName) -> Resource:
	match passive_id:
		PASSIVE_CANDLE_SPARK:
			return candle_spark_passive()
		PASSIVE_CLOUD_SEED:
			return cloud_seed_passive()
		PASSIVE_DREAM_THREAD:
			return dream_thread_passive()
		PASSIVE_RIBBON_SPOOL:
			return ribbon_spool_passive()
		PASSIVE_MOON_BUTTON:
			return moon_button_passive()
	return null


## Creates weapons in the locked first-polished exemplar package.
func weapon_pool() -> Array[Resource]:
	return [
		star_sticker_swarm_weapon(),
		waxlight_comet_weapon(),
	]


## Creates all currently playable prototype passives.
func passive_items() -> Array[Resource]:
	return [
		candle_spark_passive(),
		cloud_seed_passive(),
		dream_thread_passive(),
		ribbon_spool_passive(),
		moon_button_passive(),
	]


## Creates all currently playable enemy families.
func all_enemy_families() -> Array[Resource]:
	return [
		wax_imp_enemy(),
		flicker_imp_enemy(),
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
		wax_imp_enemy(),
		flicker_imp_enemy(),
	]


## Creates the opening enemy pool. Fast/weak family is intentionally delayed.
func opening_enemy_pool() -> Array[Resource]:
	return [
		wax_imp_enemy(),
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
		_make_tag(TAG_LIGHT, "Light", "catalyst", "Radiant light evolution catalyst."),
		_make_tag(TAG_DREAMLIGHT, "Dreamlight", "material", "Soft storybook dream glow."),
		_make_tag(TAG_DREAM, "Dream", "catalyst", "Dream evolution catalyst."),
		_make_tag(TAG_THREAD, "Thread", "catalyst", "Thread evolution catalyst."),
		_make_tag(TAG_ECHO, "Echo", "catalyst", "Echo evolution catalyst."),
		_make_tag(TAG_WONDER, "Wonder", "catalyst", "Wonder evolution catalyst."),
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
	weapon.description = "Early AoE/Pagecraft weapon that marks clustered enemies for later dash bursts."
	weapon.tags = _string_name_array([TAG_PROTOTYPE])
	weapon.weapon_type_id = &"direct_nearest"
	weapon.attack_behavior_id = &"nearest_direct_hit"
	weapon.material_tags = _string_name_array([PAGECRAFT_TAG_WAXLIGHT, TAG_FIRELIGHT])
	weapon.catalyst_tags = _string_name_array([TAG_FIRELIGHT, TAG_LIGHT])
	weapon.pagecraft_material_tag = PAGECRAFT_TAG_WAXLIGHT
	weapon.dash_interaction_id = &"waxlight_dash_pulse"
	weapon.base_damage = 45.0
	weapon.base_cooldown_seconds = 0.9
	weapon.base_mark_radius_meters = 0.98
	weapon.base_range_meters = 6.5
	return weapon


func _star_sticker_swarm_weapon() -> Resource:
	var weapon = WeaponDataScript.new()
	weapon.id = WEAPON_STAR_STICKER_SWARM
	weapon.display_name = "Star Sticker Swarm"
	weapon.description = "Starter baseline weapon. Orbit stars hit reliably, then grow into persistent ricochet nodes."
	weapon.tags = _string_name_array([TAG_PROTOTYPE])
	weapon.weapon_type_id = &"orbit_attach"
	weapon.attack_behavior_id = &"star_sticker_burst"
	weapon.material_tags = _string_name_array([PAGECRAFT_TAG_STAR_STICKER, TAG_STAR])
	weapon.catalyst_tags = _string_name_array([TAG_STAR, TAG_MOON])
	weapon.pagecraft_material_tag = PAGECRAFT_TAG_STAR_STICKER
	weapon.dash_interaction_id = &"sticker_dash_launch"
	weapon.base_damage = 100.0
	weapon.base_cooldown_seconds = 1.0
	weapon.base_mark_radius_meters = 0.6
	weapon.base_range_meters = 8.0
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
	weapon.base_damage = 60.0
	weapon.base_cooldown_seconds = 2.0
	weapon.base_mark_radius_meters = 1.2
	weapon.base_range_meters = 9.75
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
	weapon.base_damage = 70.0
	weapon.base_cooldown_seconds = 1.8
	weapon.base_mark_radius_meters = 1.125
	weapon.base_range_meters = 9.75
	return weapon


func _wax_imp_enemy() -> Resource:
	var enemy = EnemyDataScript.new()
	enemy.id = ENEMY_WAX_IMP
	enemy.display_name = "Wax Imp"
	enemy.description = "Authored opening slow normal enemy. Tuned to die to one baseline Star Sticker hit."
	enemy.tags = _string_name_array([TAG_HOSTILE_INK, TAG_PROTOTYPE])
	enemy.behavior_id = &"chaser"
	enemy.max_health = 70.0
	enemy.move_speed = 1.45
	enemy.contact_damage = 90.0
	enemy.reward_xp = 5
	enemy.pagecraft_interaction_tags = _string_name_array([PAGECRAFT_TAG_WAXLIGHT])
	return enemy


func _flicker_imp_enemy() -> Resource:
	var enemy = EnemyDataScript.new()
	enemy.id = ENEMY_FLICKER_IMP
	enemy.display_name = "Flicker Imp"
	enemy.description = "Authored delayed fast weak pressure enemy."
	enemy.tags = _string_name_array([TAG_HOSTILE_INK, TAG_PROTOTYPE])
	enemy.behavior_id = &"swarmer"
	enemy.max_health = 45.0
	enemy.move_speed = 3.2
	enemy.contact_damage = 90.0
	enemy.reward_xp = 5
	enemy.pagecraft_interaction_tags = _string_name_array([PAGECRAFT_TAG_WAXLIGHT])
	return enemy


func _candle_spark_passive() -> Resource:
	var passive = PassiveItemDataScript.new()
	passive.id = PASSIVE_CANDLE_SPARK
	passive.display_name = "Candle Spark"
	passive.description = "Documented Firelight/Light passive. In prototype it gives a broad player-owned damage boost."
	passive.tags = _string_name_array([TAG_PROTOTYPE])
	passive.draft_rarity = &"common"
	passive.catalyst_tags = _string_name_array([TAG_FIRELIGHT, TAG_LIGHT])
	passive.stat_id = &"damage"
	passive.level_values = [0.10, 0.20, 0.30, 0.40, 0.50]
	return passive


func _load_or_make_passive(path: String, passive_id: StringName, display_name: String, description: String, catalyst_tags: Array, stat_id: StringName) -> Resource:
	var resource := _load_resource(path)
	if resource != null:
		return resource
	var passive = PassiveItemDataScript.new()
	passive.id = passive_id
	passive.display_name = display_name
	passive.description = description
	passive.tags = _string_name_array([TAG_PROTOTYPE])
	passive.draft_rarity = &"common"
	passive.catalyst_tags = _string_name_array(catalyst_tags)
	passive.stat_id = stat_id
	passive.level_values = [0.10, 0.20, 0.30, 0.40, 0.50]
	return passive


func _opening_enemy_health() -> float:
	return 70.0


func _fallback_upgrade_choices() -> Array[Resource]:
	return [
		_upgrade_choice(&"waxlight_damage_plus_1", "Waxlight damage +2", "Waxlight hits and active wax hit harder.", &"stat", &"waxlight_damage_plus_1", &"", &"", &"waxlight_damage", 2.0),
		_upgrade_choice(&"waxlight_cooldown_minus_10", "Waxlight cooldown -0.25s", "Waxlight Comet fires more often.", &"stat", &"waxlight_cooldown_minus_10", &"", &"", &"waxlight_cooldown", -0.25),
		_upgrade_choice(&"waxlight_duration_plus_1", "Waxlight duration +1s", "Active Waxlight marks tick longer before expiring.", &"stat", &"waxlight_duration_plus_1", &"", &"", &"waxlight_duration", 1.0),
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
