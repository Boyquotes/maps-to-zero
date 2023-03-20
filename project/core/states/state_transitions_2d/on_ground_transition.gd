extends StateTransition2D
class_name OnGroundTransition


@export var next_state := ""

func physics_update(delta: float) -> void:
	if _character.is_on_floor():
		_character.request_state_transition(next_state)
