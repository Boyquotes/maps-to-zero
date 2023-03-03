class_name StatRequirement
extends StateTransitionRequirement

@export var stat_type : CharacterStats.Types
@export var amount : float = 0.0
@export var reduce_on_transition : bool = true


func get_is_ready() -> bool:
	return actor.get_stat(stat_type) >= amount


func enter(msg:={}) -> void:
	if reduce_on_transition:
		actor.change_stat_by(stat_type, -amount)
