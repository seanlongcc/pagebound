extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const SnapshotScript := preload("res://src/runtime/performance_profile_snapshot.gd")

const DEFAULT_SCENARIO := "baseline"
const DEFAULT_RUN_TIME_SECONDS := 27.0 * 60.0
const DEFAULT_WARMUP_FRAMES := 24
const DEFAULT_DEATH_CYCLES := 8
const DEFAULT_KILLS_PER_CYCLE := 40
const DEFAULT_SAMPLE_FRAMES := 120
const LOW_ENEMY_CAP := 120

const SCENARIOS := {
	"baseline": {
		"pickups": true,
		"damage_numbers": true,
		"shadows": true,
		"vfx_pagecraft": true,
		"enemy_cap": 0,
	},
	"no_pickups": {
		"pickups": false,
		"damage_numbers": true,
		"shadows": true,
		"vfx_pagecraft": true,
		"enemy_cap": 0,
	},
	"no_damage_numbers": {
		"pickups": true,
		"damage_numbers": false,
		"shadows": true,
		"vfx_pagecraft": true,
		"enemy_cap": 0,
	},
	"no_shadows": {
		"pickups": true,
		"damage_numbers": true,
		"shadows": false,
		"vfx_pagecraft": true,
		"enemy_cap": 0,
	},
	"no_vfx_pagecraft": {
		"pickups": true,
		"damage_numbers": true,
		"shadows": true,
		"vfx_pagecraft": false,
		"enemy_cap": 0,
	},
	"low_enemy_cap": {
		"pickups": true,
		"damage_numbers": true,
		"shadows": true,
		"vfx_pagecraft": true,
		"enemy_cap": LOW_ENEMY_CAP,
	},
	"minimal_presentation": {
		"pickups": false,
		"damage_numbers": false,
		"shadows": false,
		"vfx_pagecraft": false,
		"enemy_cap": LOW_ENEMY_CAP,
	},
}


func _initialize() -> void:
	var failures: Array[String] = []
	var options := _profile_options()
	var root := _load_main(failures)
	if root == null:
		_finish(failures)
		return

	await process_frame
	await physics_frame

	var run_root := root.get_node_or_null("RunRoot")
	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	_assert_true(run_root != null, "Main.tscn must expose RunRoot", failures)
	_assert_true(runtime != null and runtime.has_method("debug_start_run"), "runtime must expose debug_start_run", failures)
	_assert_true(runtime != null and runtime.has_method("debug_force_run_time"), "runtime must expose debug_force_run_time", failures)
	_assert_true(runtime != null and runtime.has_method("damage_model"), "runtime must expose damage_model", failures)
	if not failures.is_empty():
		_finish_after_root(root, failures)
		return

	runtime.debug_start_run()
	await process_frame
	await physics_frame
	_apply_scenario_once(root, run_root, options)
	runtime.debug_force_run_time(float(options.get("run_time_seconds", DEFAULT_RUN_TIME_SECONDS)))
	await physics_frame

	for _index in int(options.get("warmup_frames", DEFAULT_WARMUP_FRAMES)):
		_apply_scenario_each_frame(run_root, options)
		await physics_frame

	var snapshotter = SnapshotScript.new()
	var initial_snapshot: Dictionary = snapshotter.capture(run_root, "initial")
	var stress_result: Dictionary = await _run_stress(runtime, run_root, options)
	var final_snapshot: Dictionary = snapshotter.capture(run_root, "final")
	var report := {
		"profile": "end_game_performance",
		"scenario": options.get("scenario", DEFAULT_SCENARIO),
		"options": options,
		"design_source_consulted": [
			"PAGEBOUND_CODEX_GDD_v1_5.md section 49",
			"design/gdd/object-pooling-and-performance-debug.md",
		],
		"snapshots": {
			"initial": initial_snapshot,
			"final": final_snapshot,
		},
		"stress": stress_result,
		"delta": _snapshot_delta(initial_snapshot, final_snapshot),
	}

	_print_report(report)
	_write_report_if_requested(report, String(options.get("output", "")))
	_assert_profile_report(report, failures)
	_finish_after_root(root, failures)


func _run_stress(runtime: Node, run_root: Node, options: Dictionary) -> Dictionary:
	var process_samples_us: Array[int] = []
	var physics_samples_us: Array[int] = []
	var killed_total := 0
	var snapshotter = SnapshotScript.new()
	var checkpoints: Array[Dictionary] = []
	var death_cycles := int(options.get("death_cycles", DEFAULT_DEATH_CYCLES))
	var kills_per_cycle := int(options.get("kills_per_cycle", DEFAULT_KILLS_PER_CYCLE))
	var sample_frames := int(options.get("sample_frames", DEFAULT_SAMPLE_FRAMES))

	for cycle in death_cycles:
		await physics_frame
		killed_total += _kill_visible_enemies(runtime, run_root, kills_per_cycle)
		_apply_scenario_each_frame(run_root, options)
		await process_frame
		await physics_frame
		if cycle == 0 or cycle == death_cycles - 1:
			checkpoints.append(snapshotter.capture(run_root, "cycle_%02d" % cycle))

	for _sample in sample_frames:
		var process_start := Time.get_ticks_usec()
		await process_frame
		process_samples_us.append(Time.get_ticks_usec() - process_start)
		_apply_scenario_each_frame(run_root, options)

		var physics_start := Time.get_ticks_usec()
		await physics_frame
		physics_samples_us.append(Time.get_ticks_usec() - physics_start)
		_apply_scenario_each_frame(run_root, options)

	return {
		"killed_total": killed_total,
		"death_cycles": death_cycles,
		"kills_per_cycle": kills_per_cycle,
		"sample_frames": sample_frames,
		"process_frame_wall_ms": _sample_stats_ms(process_samples_us),
		"physics_frame_wall_ms": _sample_stats_ms(physics_samples_us),
		"checkpoints": checkpoints,
	}


func _kill_visible_enemies(runtime: Node, run_root: Node, limit: int) -> int:
	var enemies_root := run_root.get_node_or_null("Actors/Enemies")
	if enemies_root == null or runtime == null or not runtime.has_method("damage_model"):
		return 0
	var damage_model = runtime.damage_model()
	if damage_model == null or not damage_model.has_method("apply_damage"):
		return 0
	var killed := 0
	for child in enemies_root.get_children():
		if killed >= limit:
			break
		if not child is Node3D or not (child as Node3D).visible:
			continue
		var health := child.get_node_or_null("HealthComponent")
		if health == null or not health.has_method("is_alive") or not health.is_alive():
			continue
		damage_model.apply_damage(health, &"performance_profile", 999999.0, [&"debug", &"profile"])
		killed += 1
	return killed


func _apply_scenario_once(root: Node, run_root: Node, options: Dictionary) -> void:
	if not bool(options.get("shadows", true)):
		_disable_shadows(root)
	var enemy_cap := int(options.get("enemy_cap", 0))
	if enemy_cap > 0:
		var director := run_root.get_node_or_null("RunDirector")
		if director != null and "safety_enemy_cap" in director:
			director.safety_enemy_cap = enemy_cap
	if not bool(options.get("damage_numbers", true)):
		_disconnect_damage_numbers(run_root)
	if not bool(options.get("vfx_pagecraft", true)):
		var pagecraft := run_root.get_node_or_null("Pagecraft/PagecraftManager")
		if pagecraft != null:
			pagecraft.set_physics_process(false)
	_apply_scenario_each_frame(run_root, options)


func _apply_scenario_each_frame(run_root: Node, options: Dictionary) -> void:
	if not bool(options.get("pickups", true)):
		_clear_children(run_root.get_node_or_null("Pickups"))
	if not bool(options.get("damage_numbers", true)):
		_clear_children(run_root.get_node_or_null("DamageNumbers"))
	if not bool(options.get("vfx_pagecraft", true)):
		var pagecraft := run_root.get_node_or_null("Pagecraft/PagecraftManager")
		if pagecraft != null and pagecraft.has_method("debug_clear_marks"):
			pagecraft.debug_clear_marks()
		_clear_children(run_root.get_node_or_null("VFX"))


func _disable_shadows(root: Node) -> void:
	if root is Light3D:
		(root as Light3D).shadow_enabled = false
	if root is GeometryInstance3D:
		(root as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child in root.get_children():
		_disable_shadows(child)


func _disconnect_damage_numbers(run_root: Node) -> void:
	var bus := run_root.get_node_or_null("RuntimeEventBus")
	var manager := run_root.get_node_or_null("DamageNumbers/DamageNumberManager")
	if bus == null or manager == null or not bus.has_signal("damage_resolved"):
		return
	var callable := Callable(manager, "_on_damage_resolved")
	if bus.damage_resolved.is_connected(callable):
		bus.damage_resolved.disconnect(callable)


func _snapshot_delta(initial_snapshot: Dictionary, final_snapshot: Dictionary) -> Dictionary:
	return {
		"node_count": int(final_snapshot.get("node_count", 0)) - int(initial_snapshot.get("node_count", 0)),
		"object_count": int(final_snapshot.get("object_count", 0)) - int(initial_snapshot.get("object_count", 0)),
		"resource_count": int(final_snapshot.get("resource_count", 0)) - int(initial_snapshot.get("resource_count", 0)),
		"roots": _root_deltas(
			initial_snapshot.get("roots", {}),
			final_snapshot.get("roots", {})
		),
	}


func _root_deltas(initial_roots: Dictionary, final_roots: Dictionary) -> Dictionary:
	var deltas := {}
	for root_name in final_roots.keys():
		var initial_counts: Dictionary = initial_roots.get(root_name, {})
		var final_counts: Dictionary = final_roots.get(root_name, {})
		deltas[root_name] = {
			"total_children": int(final_counts.get("total_children", 0)) - int(initial_counts.get("total_children", 0)),
			"visible_children": int(final_counts.get("visible_children", 0)) - int(initial_counts.get("visible_children", 0)),
			"hidden_children": int(final_counts.get("hidden_children", 0)) - int(initial_counts.get("hidden_children", 0)),
			"active_children": int(final_counts.get("active_children", 0)) - int(initial_counts.get("active_children", 0)),
		}
	return deltas


func _sample_stats_ms(samples_us: Array[int]) -> Dictionary:
	if samples_us.is_empty():
		return {"count": 0, "avg": 0.0, "max": 0.0, "p95": 0.0}
	samples_us.sort()
	var total := 0
	for sample in samples_us:
		total += sample
	var p95_index := clampi(ceili(float(samples_us.size()) * 0.95) - 1, 0, samples_us.size() - 1)
	return {
		"count": samples_us.size(),
		"avg": (float(total) / float(samples_us.size())) / 1000.0,
		"max": float(samples_us[samples_us.size() - 1]) / 1000.0,
		"p95": float(samples_us[p95_index]) / 1000.0,
	}


func _profile_options() -> Dictionary:
	var scenario := DEFAULT_SCENARIO
	var output := ""
	var options := {
		"scenario": scenario,
		"run_time_seconds": DEFAULT_RUN_TIME_SECONDS,
		"warmup_frames": DEFAULT_WARMUP_FRAMES,
		"death_cycles": DEFAULT_DEATH_CYCLES,
		"kills_per_cycle": DEFAULT_KILLS_PER_CYCLE,
		"sample_frames": DEFAULT_SAMPLE_FRAMES,
		"output": output,
	}
	for arg in _all_user_args():
		if arg.begins_with("--scenario="):
			scenario = arg.trim_prefix("--scenario=")
		elif arg.begins_with("--run-time="):
			options["run_time_seconds"] = float(arg.trim_prefix("--run-time="))
		elif arg.begins_with("--warmup-frames="):
			options["warmup_frames"] = int(arg.trim_prefix("--warmup-frames="))
		elif arg.begins_with("--death-cycles="):
			options["death_cycles"] = int(arg.trim_prefix("--death-cycles="))
		elif arg.begins_with("--kills-per-cycle="):
			options["kills_per_cycle"] = int(arg.trim_prefix("--kills-per-cycle="))
		elif arg.begins_with("--sample-frames="):
			options["sample_frames"] = int(arg.trim_prefix("--sample-frames="))
		elif arg.begins_with("--output="):
			output = arg.trim_prefix("--output=")

	if not SCENARIOS.has(scenario):
		scenario = DEFAULT_SCENARIO
	options.merge(SCENARIOS[scenario], true)
	options["scenario"] = scenario
	options["output"] = output
	return options


func _all_user_args() -> Array[String]:
	var args: Array[String] = []
	for arg in OS.get_cmdline_user_args():
		args.append(arg)
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--scenario=") or arg.begins_with("--run-time=") or arg.begins_with("--warmup-frames=") or arg.begins_with("--death-cycles=") or arg.begins_with("--kills-per-cycle=") or arg.begins_with("--sample-frames=") or arg.begins_with("--output="):
			args.append(arg)
	return args


func _print_report(report: Dictionary) -> void:
	var final_roots: Dictionary = report.get("snapshots", {}).get("final", {}).get("roots", {})
	var stress: Dictionary = report.get("stress", {})
	print("PROFILE_SUMMARY scenario=%s killed=%d enemies_total=%d enemies_hidden=%d pickups_total=%d process_p95_ms=%.3f physics_p95_ms=%.3f" % [
		report.get("scenario", DEFAULT_SCENARIO),
		int(stress.get("killed_total", 0)),
		int(final_roots.get("enemies", {}).get("total_children", 0)),
		int(final_roots.get("enemies", {}).get("hidden_children", 0)),
		int(final_roots.get("pickups", {}).get("total_children", 0)),
		float(stress.get("process_frame_wall_ms", {}).get("p95", 0.0)),
		float(stress.get("physics_frame_wall_ms", {}).get("p95", 0.0)),
	])
	print("PROFILE_JSON " + JSON.stringify(report))


func _write_report_if_requested(report: Dictionary, output_path: String) -> void:
	if output_path.is_empty():
		return
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_warning("profile output path not writable; JSON report was still printed: %s" % output_path)
		return
	file.store_string(JSON.stringify(report, "\t"))


func _assert_profile_report(report: Dictionary, failures: Array[String]) -> void:
	var snapshots: Dictionary = report.get("snapshots", {})
	var final_snapshot: Dictionary = snapshots.get("final", {})
	var final_roots: Dictionary = final_snapshot.get("roots", {})
	var final_enemies: Dictionary = final_roots.get("enemies", {})
	var stress: Dictionary = report.get("stress", {})
	_assert_true(int(stress.get("killed_total", 0)) > 0, "profile harness must kill at least one enemy", failures)
	_assert_true(int(final_enemies.get("total_children", 0)) > 0, "profile harness must measure enemy children", failures)
	_assert_true(stress.get("process_frame_wall_ms", {}).has("p95"), "profile harness must measure process frame p95", failures)
	_assert_true(stress.get("physics_frame_wall_ms", {}).has("p95"), "profile harness must measure physics frame p95", failures)


func _load_main(failures: Array[String]) -> Node:
	var packed_scene := load(MAIN_SCENE) as PackedScene
	_assert_true(packed_scene != null, "Main.tscn must load", failures)
	if packed_scene == null:
		return null
	var root := packed_scene.instantiate()
	get_root().add_child(root)
	return root


func _clear_children(root: Node) -> void:
	if root == null:
		return
	for child in root.get_children():
		root.remove_child(child)
		child.queue_free()


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish_after_root(root: Node, failures: Array[String]) -> void:
	root.queue_free()
	await process_frame
	_finish(failures)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("end-game profile check passed")
		quit(0)
		return

	push_error("end-game profile check failed:\n- " + "\n- ".join(failures))
	quit(1)
