class_name PageboundTagData
extends Resource

## Stable lowercase snake_case tag ID.
@export var id: StringName
## Human-readable authoring label.
@export var display_name := ""
## Broad tag category such as material, catalyst, damage, trait, or prototype.
@export var category := ""
## Optional authoring note for validation/debug tools.
@export_multiline var description := ""


## Returns a compact label for validation output.
func schema_label() -> String:
	return "PageboundTagData(%s)" % String(id)
