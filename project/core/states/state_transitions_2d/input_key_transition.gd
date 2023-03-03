class_name InputKeyTransition
extends StateTransition2D

@export var action: String
@export var go_to_state: String



func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed(action):
		_character.request_state_transition(go_to_state)
