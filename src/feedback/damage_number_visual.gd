class_name DamageNumberVisual
extends Label3D

signal expired(visual: Node)

var _age := 0.0
var _lifetime := 0.75
var _velocity := Vector3(0.0, 1.4, 0.0)


## Activates this visual for one resolved damage fact.
func activate(world_position: Vector3, amount: float, color: Color, lifetime_seconds: float) -> void:
	global_position = world_position + Vector3.UP * 0.8
	text = str(roundi(amount))
	modulate = color
	_age = 0.0
	_lifetime = maxf(0.05, lifetime_seconds)
	visible = true
	set_process(true)


## Resets transient visual state before pooling.
func reset_for_pool() -> void:
	text = ""
	_age = 0.0
	visible = false
	set_process(false)


func _process(delta: float) -> void:
	_age += delta
	global_position += _velocity * delta
	var alpha := clampf(1.0 - (_age / _lifetime), 0.0, 1.0)
	modulate.a = alpha
	if _age >= _lifetime:
		expired.emit(self)
