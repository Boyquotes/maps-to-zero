# Boilerplate class to get full autocompletion and type checks for the actor_2d` when coding the player's states.
# Without this, we have to run the game to see typos and other errors the compiler could otherwise catch while scripting.
class_name Actor2DState
extends State

# Typed reference to the player node.
var actor : Actor2D


func init(character: Actor2D) -> void:
	self.actor = character
