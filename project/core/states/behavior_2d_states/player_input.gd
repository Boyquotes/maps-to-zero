# player_input.gd
extends Behavior2DScript


func enter(_msg := {}) -> void:
	set_process_input(true)

func exit() -> void:
	set_process_input(false)

func _input(event:InputEvent) -> void:
	if actor.input_enabled:
		actor.unhandled_input(event)

func get_input_direction() -> Vector2:
	if actor.input_enabled:
		var input_direction_x: float = (
			Input.get_action_strength("move_right")
			- Input.get_action_strength("move_left")
		)
		
		var input_direction_y: float = (
			Input.get_action_strength("move_down")
			- Input.get_action_strength("move_up")
		)
		
		return Vector2(input_direction_x, input_direction_y)
	else:
		return Vector2.ZERO
