class_name IsNotGroundedRequirement
extends StateTransitionRequirement


func get_is_ready() -> bool:
	return not _character.is_on_floor()
