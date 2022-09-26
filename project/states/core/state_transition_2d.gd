class_name StateTransition2D
extends Node

var actor_2d: Actor2D
var state: Actor2DState


# Called when the node enters the scene tree for the first time.
func _ready():
	state = get_parent()
	assert(state != null)
	state.state_transitions.append(self)
	await state.ready
	await owner.ready
	actor_2d = state.actor_2d


func enter(_msg:={}) -> void:
	pass

func exit() -> void:
	pass

# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	pass
