extends StateTransition2D

@export var inputs : Dictionary



func handle_input(_event: InputEvent) -> void:
	for input in inputs.keys():
		if _event.is_action_pressed(input):
			actor.request_state_transition(inputs[input])
