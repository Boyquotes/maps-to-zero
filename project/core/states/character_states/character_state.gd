# Boilerplate class to get full autocompletion and type checks for the actor_2d` when coding the player's states.
# Without this, we have to run the game to see typos and other errors the compiler could otherwise catch while scripting.
class_name CharacterState
extends State

# Typed reference to the player node.
var _character : Character


func init(character: Character) -> void:
	_character = character
	for child in get_children():
		if child is StateTransition2D or child is StateTransitionRequirement:
			child.init(self)
