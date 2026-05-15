class_name DogSupportPet
extends Node3D

signal pickup_assisted(amount: int, pickup_type: StringName, world_position: Vector3)

const TIER_ONE_RADIUS := 6.0
const TIER_THREE_RADIUS := 8.625
const FOLLOW_OFFSET := Vector3(-0.85, 0.0, 0.65)
const FOLLOW_SMOOTHING := 12.0
const FETCH_SPEED := 7.0
const FETCH_COLLECT_RADIUS := 0.45
const FEEDBACK_SECONDS := 2.5

@export_range(1, 3, 1) var tier := 1

var _player: Node3D
var _pickups_root: Node
var _feedback_label: Label3D
var _feedback_remaining := 0.0
var _fetch_target: Node3D


func _ready() -> void:
	add_to_group("support_pet")
	_ensure_visuals()


func _physics_process(delta: float) -> void:
	_acquire_fetch_target()
	if _fetch_target != null:
		_fetch_pickup(delta)
	else:
		_follow_player(delta)
	_tick_feedback(delta)


func configure(player: Node3D, pickups_root: Node) -> void:
	_player = player
	_pickups_root = pickups_root
	_ensure_visuals()
	set_physics_process(_player != null and _pickups_root != null)


func set_tier(new_tier: int) -> void:
	tier = clampi(new_tier, 1, 3)


func aura_radius() -> float:
	return fetch_range()


func fetch_range() -> float:
	return TIER_THREE_RADIUS if tier >= 3 else TIER_ONE_RADIUS


func accepts_pickup_type(pickup_type: StringName) -> bool:
	if pickup_type == &"color_mote":
		return true
	if pickup_type == &"health":
		return tier >= 2
	return false


func _follow_player(delta: float) -> void:
	if _player == null:
		return
	var desired := _player.global_position + FOLLOW_OFFSET
	desired.y = 0.0
	global_position = global_position.lerp(desired, clampf(delta * FOLLOW_SMOOTHING, 0.0, 1.0))


func _acquire_fetch_target() -> void:
	if _player == null or _pickups_root == null:
		return
	if _is_collectible_fetch_target(_fetch_target):
		return
	_fetch_target = null
	var nearest: Node3D = null
	var nearest_distance := fetch_range()
	for child in _pickups_root.get_children():
		if not _is_acquirable_fetch_target(child):
			continue
		var distance := _player.global_position.distance_to((child as Node3D).global_position)
		if distance <= nearest_distance:
			nearest = child
			nearest_distance = distance
	_fetch_target = nearest


func _fetch_pickup(delta: float) -> void:
	if not _is_collectible_fetch_target(_fetch_target):
		_fetch_target = null
		return
	var desired := _fetch_target.global_position
	desired.y = 0.0
	global_position = global_position.move_toward(desired, FETCH_SPEED * delta)
	if global_position.distance_to(desired) <= FETCH_COLLECT_RADIUS:
		var pickup := _fetch_target
		_fetch_target = null
		_collect_pickup(pickup, _pickup_type(pickup))


func _is_acquirable_fetch_target(candidate: Node) -> bool:
	if _player == null or not _is_collectible_fetch_target(candidate):
		return false
	return _player.global_position.distance_to((candidate as Node3D).global_position) <= fetch_range()


func _is_collectible_fetch_target(candidate: Node) -> bool:
	if candidate == null or not candidate is Node3D:
		return false
	var pickup_type := _pickup_type(candidate)
	if not accepts_pickup_type(pickup_type):
		return false
	if not candidate.has_method("is_collectible") or not candidate.is_collectible():
		return false
	return true


func _collect_pickup(pickup: Node3D, pickup_type: StringName) -> void:
	var amount := int(pickup.get("amount")) if "amount" in pickup else 0
	if pickup.has_method("collect_by_assist") and pickup.collect_by_assist(&"dog"):
		_show_feedback(amount, pickup_type)
		pickup_assisted.emit(amount, pickup_type, pickup.global_position)


func _pickup_type(pickup: Node) -> StringName:
	if pickup.is_in_group("xp_pickup"):
		return &"color_mote"
	if pickup.is_in_group("health_pickup"):
		return &"health"
	return &""


func _show_feedback(amount: int, pickup_type: StringName) -> void:
	if _feedback_label == null:
		return
	if pickup_type == &"color_mote":
		_feedback_label.text = "Dog fetch +%d XP" % amount
	else:
		_feedback_label.text = "Dog fetch"
	_feedback_label.visible = true
	_feedback_remaining = FEEDBACK_SECONDS


func _tick_feedback(delta: float) -> void:
	if _feedback_remaining <= 0.0:
		return
	_feedback_remaining = maxf(0.0, _feedback_remaining - delta)
	if _feedback_remaining <= 0.0 and _feedback_label != null:
		_feedback_label.visible = false


func _ensure_visuals() -> void:
	if get_node_or_null("DogBody") == null:
		var body := MeshInstance3D.new()
		body.name = "DogBody"
		var mesh := CapsuleMesh.new()
		mesh.radius = 0.22
		mesh.height = 0.55
		body.mesh = mesh
		body.position.y = 0.35
		body.material_override = _material(Color(0.56, 0.32, 0.16, 1.0), false)
		add_child(body)
	var stale_aura := get_node_or_null("DogAura")
	if stale_aura != null:
		remove_child(stale_aura)
		stale_aura.queue_free()
	if _feedback_label == null:
		_feedback_label = get_node_or_null("DogFetchFeedback") as Label3D
		if _feedback_label == null:
			_feedback_label = Label3D.new()
			_feedback_label.name = "DogFetchFeedback"
			_feedback_label.position = Vector3(0.0, 1.15, 0.0)
			_feedback_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			_feedback_label.font_size = 24
			_feedback_label.modulate = Color(1.0, 0.86, 0.22, 1.0)
			_feedback_label.visible = false
			add_child(_feedback_label)


func _material(color: Color, transparent: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	if transparent:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.emission_enabled = true
		material.emission = Color(color.r, color.g, color.b, 1.0)
		material.emission_energy_multiplier = 0.35
	return material
