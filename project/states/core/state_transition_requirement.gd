class_name StateTransitionRequirement
extends Node

var actor_2d: Actor2D
var actor_2d_state: Actor2DState
var is_ready : bool:
	get:
		return get_is_ready()


# Called when the node enters the scene tree for the first time.
func _ready():
	actor_2d_state = get_parent()
	assert(actor_2d_state != null)
	actor_2d_state.transition_requirements.append(self)
	await actor_2d_state.ready
	await owner.ready
	actor_2d = actor_2d_state.actor_2d


# Virtual function.
func get_is_ready() -> bool:
	return false
