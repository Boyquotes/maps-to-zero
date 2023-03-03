class_name StateTransitionRequirement
extends Node

var actor: Actor2D
var actor_state: Actor2DState
var is_ready : bool:
	get:
		return get_is_ready()


# Called when the node enters the scene tree for the first time.
func init(state: Actor2DState):
	actor_state = state
	actor_state.transition_requirements.append(self)
	actor = actor_state.actor


# Virtual function.
func get_is_ready() -> bool:
	return false


# Virtual function
func enter(msg:={}) -> void:
	pass
