# Boilerplate class to get full autocompletion and type checks for the actor` when coding the player's states.
# Without this, we have to run the game to see typos and other errors the compiler could otherwise catch while scripting.
class_name Behavior2DScript
extends CharacterState

var input_direction : Vector2 :
	get:
		return get_input_direction()


# Virtual function
func get_input_direction() -> Vector2:
	return Vector2.ZERO


func simulate_input(event: InputEvent) -> void:
	_character.unhandled_input(event)


func simulate_action_press(name: StringName) -> void:
	var event = InputEventAction.new()
	event.action = name
	event.pressed = true
	_character.unhandled_input(event)
