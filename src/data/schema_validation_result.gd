class_name SchemaValidationResult
extends RefCounted

## Validation checks in run order.
var check_results: Array[Dictionary] = []
## Number of checks evaluated.
var required_checks := 0
## Number of passing checks.
var passed_checks := 0
## Number of failing checks.
var failed_checks := 0
## Blocking validation error count.
var error_count := 0
## Non-blocking validation warning count.
var warning_count := 0
## True when every blocking schema check passed.
var schema_ready_allowed := false


## Adds one schema validation check.
func add_check(check_id: String, passed: bool, message: String = "", details: Dictionary = {}) -> void:
	check_results.append({
		"id": check_id,
		"passed": passed,
		"message": message,
		"details": details,
	})


## Recomputes derived validation counts.
func finalize() -> void:
	required_checks = check_results.size()
	passed_checks = 0
	for check in check_results:
		if check.get("passed", false):
			passed_checks += 1
	failed_checks = required_checks - passed_checks
	error_count = failed_checks
	warning_count = 0
	schema_ready_allowed = error_count == 0 and required_checks > 0


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


## Returns failed check messages in validation order.
func failed_messages() -> Array[String]:
	var messages: Array[String] = []
	for check in check_results:
		if not check.get("passed", false):
			messages.append("%s: %s" % [check.get("id", ""), check.get("message", "")])
	return messages
