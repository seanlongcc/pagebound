class_name FirstPlayableCameraController
extends RefCounted

const GameplayCameraFollowScript := preload("res://src/camera/gameplay_camera_follow.gd")
const CAMERA_LOCAL_POSITION := Vector3(0.0, 13.0, 6.4)
const CAMERA_FOLLOW_HALF_EXTENTS := Vector2(28.0, 16.0)
const CAMERA_FOV_DEGREES := 62.0


## Ensures the camera follow node exists and tracks the current player target.
func ensure_follow(target: Node3D, camera_rig: Node3D) -> void:
	if target == null or camera_rig == null:
		return
	var follow := camera_rig.get_node_or_null("GameplayCameraFollow")
	if follow == null:
		follow = Node.new()
		follow.name = "GameplayCameraFollow"
		follow.set_script(GameplayCameraFollowScript)
		camera_rig.add_child(follow)
	if follow.has_method("configure"):
		follow.configure(target, camera_rig)
	if "page_half_extents" in follow:
		follow.page_half_extents = CAMERA_FOLLOW_HALF_EXTENTS


## Snaps the camera rig to the supplied target and refreshes camera framing.
func snap_to_target(target: Node3D, camera_rig: Node3D, camera: Camera3D) -> void:
	if target == null or camera_rig == null:
		return
	camera_rig.global_position = Vector3(target.global_position.x, 0.0, target.global_position.z)
	var follow := camera_rig.get_node_or_null("GameplayCameraFollow")
	if follow != null and follow.has_method("snap_to_target"):
		follow.snap_to_target()
	configure_camera(camera, camera_rig)


## Applies prototype gameplay camera framing.
func configure_camera(camera: Camera3D, camera_rig: Node3D) -> void:
	if camera == null or camera_rig == null:
		return
	camera.position = CAMERA_LOCAL_POSITION
	camera.fov = CAMERA_FOV_DEGREES
	camera.look_at(camera_rig.global_position, Vector3.UP)


## Removes old follow state during run reset.
func clear_follow(camera_rig: Node3D) -> void:
	if camera_rig == null:
		return
	var follow := camera_rig.get_node_or_null("GameplayCameraFollow")
	if follow != null:
		camera_rig.remove_child(follow)
		follow.queue_free()
