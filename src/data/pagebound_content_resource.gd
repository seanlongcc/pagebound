class_name PageboundContentResource
extends Resource

## Stable lowercase snake_case content ID.
@export var id: StringName
## Temporary display name until localization keys are introduced.
@export var display_name := ""
## Authoring description for draft/debug consumers.
@export_multiline var description := ""
## Shared tag IDs referenced by this content.
@export var tags: Array[StringName] = []
## Draft rarity for cards/resources that can appear in a run draft.
@export var draft_rarity: StringName = &"common"
## Deprecated resources stay loadable but are blocked from new-run pools by default.
@export var deprecated := false
## True when deprecated content is still allowed in new prototype runs.
@export var allow_in_new_runs := true
## Prototype resources may use primitive placeholders and missing final asset refs.
@export var placeholder_assets := true


## Returns every tag ID referenced by this resource.
func referenced_tag_ids() -> Array[StringName]:
	return tags.duplicate()


## Returns a compact label for validation output.
func schema_label() -> String:
	return "%s(%s)" % [get_class(), String(id)]
