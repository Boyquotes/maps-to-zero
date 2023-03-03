class_name StateTransitionRequirement
extends Node

var _character: Character
var _state: CharacterState
var is_ready : bool:
	get:
		return get_is_ready()


# Called when the node enters the scene tree for the first time.
func init(state: CharacterState):
	_state = state
	_state.transition_requirements.append(self)
	_character = _state._character


# Virtual function.
func get_is_ready() -> bool:
	return false


# Virtual function
func enter(msg:={}) -> void:
	pass
