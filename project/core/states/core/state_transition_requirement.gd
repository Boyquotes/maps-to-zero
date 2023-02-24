class_name StateTransitionRequirement
extends Node

var actor: Actor2D
var actor_state: Actor2DState
var is_ready : bool:
	get:
		return get_is_ready()


# Called when the node enters the scene tree for the first time.
func _ready():
	actor_state = get_parent()
	assert(actor_state != null)
	actor_state.transition_requirements.append(self)
	await actor_state.ready
	await owner.ready
	actor = actor_state.actor


# Virtual function.
func get_is_ready() -> bool:
	return false


# Virtual function
func enter(msg:={}) -> void:
	pass
