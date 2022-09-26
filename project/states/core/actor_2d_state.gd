# Boilerplate class to get full autocompletion and type checks for the actor_2d` when coding the player's states.
# Without this, we have to run the game to see typos and other errors the compiler could otherwise catch while scripting.
class_name Actor2DState
extends State

# Typed reference to the player node.
var actor_2d : Actor2D


func _ready() -> void:
	# The states are children of the Actor2D` node so their `_ready()` callback will execute first.
	# That's why we wait for the `owner` to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the Actor2D` type.
	# If the `owner` is not a Actor2D`, we'll get `null`.
	actor_2d = owner as Actor2D
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than Actor2D.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(actor_2d != null)
