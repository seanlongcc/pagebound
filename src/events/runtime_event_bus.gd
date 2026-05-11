class_name RuntimeEventBus
extends Node

signal damage_resolved(event: Dictionary)
signal entity_died(event: Dictionary)
signal xp_awarded(event: Dictionary)
signal run_level_gained(event: Dictionary)
signal draft_opened(event: Dictionary)
signal draft_choice_selected(event: Dictionary)
signal upgrade_applied(event: Dictionary)
signal run_ended(event: Dictionary)
signal pagecraft_mark_deposited(event: Dictionary)
signal pagecraft_mark_activated(event: Dictionary)


## Emits a resolved damage fact after DamageModel calculation.
func emit_damage_resolved(event: Dictionary) -> void:
	damage_resolved.emit(event)


## Emits a death fact once for one entity life.
func emit_entity_died(event: Dictionary) -> void:
	entity_died.emit(event)


## Emits an XP reward fact.
func emit_xp_awarded(event: Dictionary) -> void:
	xp_awarded.emit(event)


## Emits a run level-up fact.
func emit_run_level_gained(event: Dictionary) -> void:
	run_level_gained.emit(event)


## Emits a draft opened fact.
func emit_draft_opened(event: Dictionary) -> void:
	draft_opened.emit(event)


## Emits a draft choice selected fact.
func emit_draft_choice_selected(event: Dictionary) -> void:
	draft_choice_selected.emit(event)


## Emits a runtime upgrade applied fact.
func emit_upgrade_applied(event: Dictionary) -> void:
	upgrade_applied.emit(event)


## Emits a run ended fact.
func emit_run_ended(event: Dictionary) -> void:
	run_ended.emit(event)


## Emits a Pagecraft mark deposit fact.
func emit_pagecraft_mark_deposited(event: Dictionary) -> void:
	pagecraft_mark_deposited.emit(event)


## Emits a Pagecraft mark activation fact.
func emit_pagecraft_mark_activated(event: Dictionary) -> void:
	pagecraft_mark_activated.emit(event)
