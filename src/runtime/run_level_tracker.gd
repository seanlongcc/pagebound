class_name RunLevelTracker
extends RefCounted

const DEFAULT_THRESHOLDS := [3, 6, 10, 15, 21, 28]

var _event_bus: Node
var _thresholds: Array[int] = []
var _run_level := 1
var _total_xp := 0
var _current_level_xp := 0
var _level_up_count := 0


## Configures the run-level tracker and optional prototype XP curve.
func configure(event_bus: Node, thresholds: Array[int] = []) -> void:
	_event_bus = event_bus
	_thresholds = _normalized_thresholds(thresholds)
	if _thresholds.is_empty():
		_thresholds = _normalized_thresholds(DEFAULT_THRESHOLDS)


## Adds run XP and emits XP/level facts.
func add_xp(amount: int, source_id: StringName) -> Array[Dictionary]:
	var awarded := maxi(0, amount)
	if awarded == 0:
		return []
	_total_xp += awarded
	_current_level_xp += awarded
	_emit_xp_awarded(awarded, source_id)

	var level_events: Array[Dictionary] = []
	while _current_level_xp >= xp_threshold_for_next_level():
		var spent_threshold := xp_threshold_for_next_level()
		_current_level_xp -= spent_threshold
		_run_level += 1
		_level_up_count += 1
		var event := _level_event(spent_threshold, source_id)
		level_events.append(event)
		_emit_level_gained(event)
	return level_events


## Returns current one-based run level.
func run_level() -> int:
	return _run_level


## Returns total XP collected this run.
func total_xp() -> int:
	return _total_xp


## Returns XP progress within the current level.
func current_level_xp() -> int:
	return _current_level_xp


## Returns XP needed to reach the next run level.
func xp_threshold_for_next_level() -> int:
	var index := maxi(0, _run_level - 1)
	if index < _thresholds.size():
		return _thresholds[index]
	var last_threshold := _thresholds[_thresholds.size() - 1]
	var overflow_index := index - _thresholds.size() + 1
	return last_threshold + overflow_index * 10


## Returns emitted level-up count for smoke/debug checks.
func level_up_count() -> int:
	return _level_up_count


func _normalized_thresholds(thresholds: Array) -> Array[int]:
	var normalized: Array[int] = []
	for threshold in thresholds:
		var value := int(threshold)
		if value > 0:
			normalized.append(value)
	return normalized


func _emit_xp_awarded(amount: int, source_id: StringName) -> void:
	if _event_bus != null and _event_bus.has_method("emit_xp_awarded"):
		_event_bus.emit_xp_awarded({
			"amount": amount,
			"total": _total_xp,
			"level": _run_level,
			"current_level_xp": _current_level_xp,
			"threshold": xp_threshold_for_next_level(),
			"source_id": source_id,
		})


func _emit_level_gained(event: Dictionary) -> void:
	if _event_bus != null and _event_bus.has_method("emit_run_level_gained"):
		_event_bus.emit_run_level_gained(event)


func _level_event(spent_threshold: int, source_id: StringName) -> Dictionary:
	return {
		"level": _run_level,
		"total_xp": _total_xp,
		"current_level_xp": _current_level_xp,
		"spent_threshold": spent_threshold,
		"next_threshold": xp_threshold_for_next_level(),
		"source_id": source_id,
	}
