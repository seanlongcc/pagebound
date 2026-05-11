class_name ShellValidationResult
extends RefCounted

## One result per required shell validation check.
var check_results: Array[Dictionary] = []
## Number of required checks evaluated.
var required_checks := 0
## Number of required checks that passed.
var passed_checks := 0
## Number of required checks that failed.
var failed_checks := 0
## Reporting score only: passed_checks / required_checks.
var boot_readiness := 0.0
## Blocking shell error count.
var boot_error_count := 0
## True only when every required check passed.
var shell_ready_allowed := false
## Typed shell handoff payload built during validation.
var shell_refs


## Adds a required shell validation check result.
func add_check(check_id: String, passed: bool, error_code: String = "", message: String = "", details: Dictionary = {}) -> void:
	check_results.append({
		"id": check_id,
		"passed": passed,
		"error_code": error_code,
		"message": message,
		"details": details,
	})


## Recomputes derived validation counts and readiness.
func finalize() -> void:
	required_checks = check_results.size()
	passed_checks = 0

	if required_checks == 0:
		add_check(
			"invalid_check_config",
			false,
			"BOOT_SHELL_INVALID_CHECK_CONFIG",
			"Shell validation produced no required checks."
		)
		required_checks = check_results.size()

	for check in check_results:
		if check.get("passed", false):
			passed_checks += 1

	failed_checks = required_checks - passed_checks
	if _has_invalid_counts():
		_append_invalid_count_failure()

	boot_error_count = failed_checks
	boot_readiness = 0.0
	if required_checks > 0:
		boot_readiness = float(passed_checks) / float(required_checks)
	shell_ready_allowed = failed_checks == 0 and passed_checks == required_checks


## Returns true if a check ID exists in this result.
func has_check_id(check_id: String) -> bool:
	for check in check_results:
		if check.get("id", "") == check_id:
			return true
	return false


## Returns true only if a check ID exists and passed.
func check_passed(check_id: String) -> bool:
	for check in check_results:
		if check.get("id", "") == check_id:
			return check.get("passed", false)
	return false


## Returns failed check IDs in validation order.
func failed_check_ids() -> Array[String]:
	var ids: Array[String] = []
	for check in check_results:
		if not check.get("passed", false):
			ids.append(check.get("id", ""))
	return ids


## Returns failed check messages in validation order.
func failed_messages() -> Array[String]:
	var messages: Array[String] = []
	for check in check_results:
		if not check.get("passed", false):
			messages.append("%s: %s" % [check.get("id", ""), check.get("message", "")])
	return messages


func _has_invalid_counts() -> bool:
	return (
		passed_checks < 0
		or passed_checks > required_checks
		or failed_checks != required_checks - passed_checks
	)


func _append_invalid_count_failure() -> void:
	check_results.append({
		"id": "invalid_check_counts",
		"passed": false,
		"error_code": "BOOT_SHELL_INVALID_CHECK_COUNTS",
		"message": "Shell validation formula counts are inconsistent.",
		"details": {},
	})
	required_checks = check_results.size()
	failed_checks += 1
