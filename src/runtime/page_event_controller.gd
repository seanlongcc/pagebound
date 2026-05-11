class_name PageEventController
extends Node

signal event_started(event: Dictionary)

const EVENT_FILL_COLOR_WELL := &"fill_color_well"
const EVENT_TITLE := "Page Event: Fill the Color Well"
const EVENT_DESCRIPTOR := "Defeat enemies and trigger Waxlight marks to fill the well."
const EVENT_DURATION_SECONDS := 180.0
const REQUIRED_PROGRESS := 5.0

@export_range(1.0, 1200.0, 1.0) var first_event_time_seconds := 60.0

var _active := false
var _completed := false
var _expired := false
var _elapsed_active := 0.0
var _progress := 0.0


func reset() -> void:
	_active = false
	_completed = false
	_expired = false
	_elapsed_active = 0.0
	_progress = 0.0


func update(run_time_seconds: float, delta: float) -> void:
	if not _active and not _completed and not _expired and run_time_seconds >= first_event_time_seconds:
		_start_event()
	if not _active:
		return
	_elapsed_active += delta
	if _progress >= REQUIRED_PROGRESS:
		_complete()
	elif _elapsed_active >= EVENT_DURATION_SECONDS:
		_expired = true
		_active = false


func add_kill_progress(amount: float = 1.0) -> void:
	if not _active:
		return
	_progress = minf(REQUIRED_PROGRESS, _progress + amount)
	if _progress >= REQUIRED_PROGRESS:
		_complete()


func force_start() -> void:
	if not _active and not _completed and not _expired:
		_start_event()


func force_complete() -> void:
	if _active:
		_progress = REQUIRED_PROGRESS
		_complete()


func active_event_id() -> StringName:
	if _active or _completed or _expired:
		return EVENT_FILL_COLOR_WELL
	return &""


func is_active() -> bool:
	return _active


func is_completed() -> bool:
	return _completed


func is_expired() -> bool:
	return _expired


func progress_ratio() -> float:
	return clampf(_progress / REQUIRED_PROGRESS, 0.0, 1.0)


func debug_first_event_time_seconds() -> float:
	return first_event_time_seconds


func hud_line() -> String:
	if active_event_id() == &"":
		return "Event: none"
	var state := "Active"
	if _completed:
		state = "Complete"
	elif _expired:
		state = "Expired"
	return "Event: Fill the Color Well (%s) %.0f/%.0f" % [state, _progress, REQUIRED_PROGRESS]


func _start_event() -> void:
	_active = true
	_completed = false
	_expired = false
	_elapsed_active = 0.0
	_progress = 0.0
	event_started.emit({
		"id": EVENT_FILL_COLOR_WELL,
		"title": EVENT_TITLE,
		"descriptor": EVENT_DESCRIPTOR,
	})


func _complete() -> void:
	_completed = true
	_active = false
