# player_input.gd
extends Behavior2DScript


func _ready() -> void:
	set_process_input(false)


func enter(_msg := {}) -> void:
	set_process_input(true)


func exit() -> void:
	set_process_input(false)


func _input(event:InputEvent) -> void:
	_character.unhandled_input(event)


func get_input_direction() -> Vector2:
	var input_direction_x: float = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)
	
	var input_direction_y: float = (
		Input.get_action_strength("move_down")
		- Input.get_action_strength("move_up")
	)
	
	return Vector2(input_direction_x, input_direction_y)


func get_walk_modifer_pressed() -> bool:	
	return Input.is_action_pressed("walk_modifier")
