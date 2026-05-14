class_name FirstPlayablePageEventOrchestrator
extends RefCounted

const PageEventControllerScript := preload("res://src/runtime/page_event_controller.gd")
const PageEventAnnouncementScript := preload("res://src/runtime/page_event_announcement.gd")

var _announcement: Node
var _controller: Node


## Ensures prototype Page Event controller and announcement UI are wired.
func ensure(run_root: Node, hud: Control) -> void:
	if run_root == null:
		return
	_ensure_announcement(run_root, hud)
	_ensure_controller(run_root)


## Updates active Page Event state and director pressure.
func tick(run_time_seconds: float, delta: float, director: Node) -> void:
	if _controller == null or not _controller.has_method("update"):
		return
	_controller.update(run_time_seconds, delta)
	if director != null and director.has_method("set_event_pressure_multiplier"):
		director.set_event_pressure_multiplier(1.15 if _controller.is_active() else 1.0)


## Resets Page Event state and hides transient announcement UI.
func reset() -> void:
	if _controller != null and _controller.has_method("reset"):
		_controller.reset()
	if _announcement != null and _announcement.has_method("hide"):
		_announcement.hide()


## Adds objective progress for defeated enemies.
func add_kill_progress() -> void:
	if _controller != null and _controller.has_method("add_kill_progress"):
		_controller.add_kill_progress()


## Forces the prototype event to start.
func force_start() -> void:
	if _controller != null and _controller.has_method("force_start"):
		_controller.force_start()


## Returns active or resolved Page Event ID for smoke checks.
func active_event_id() -> StringName:
	if _controller == null or not _controller.has_method("active_event_id"):
		return &""
	return _controller.active_event_id()


## Returns the Page Event HUD line.
func hud_line() -> String:
	if _controller != null and _controller.has_method("hud_line"):
		return _controller.hud_line()
	return "Event: none"


func _ensure_controller(run_root: Node) -> void:
	_controller = run_root.get_node_or_null("PageEventController")
	if _controller == null:
		_controller = PageEventControllerScript.new()
		_controller.name = "PageEventController"
		run_root.add_child(_controller)
	if _controller.has_signal("event_started") and not _controller.event_started.is_connected(_on_page_event_started):
		_controller.event_started.connect(_on_page_event_started)


func _ensure_announcement(run_root: Node, hud: Control) -> void:
	_announcement = run_root.get_node_or_null("PageEventAnnouncement")
	if _announcement == null:
		_announcement = PageEventAnnouncementScript.new()
		_announcement.name = "PageEventAnnouncement"
		run_root.add_child(_announcement)
	if _announcement.has_method("configure"):
		_announcement.configure(hud)


func _on_page_event_started(event: Dictionary) -> void:
	if _announcement != null and _announcement.has_method("show_event"):
		_announcement.show_event(event.get("title", "Page Event"), event.get("descriptor", ""))
