extends StateTransitionRequirement
class_name IsGroundedRequirement


func get_is_ready() -> bool:
	return _character.is_on_floor()
