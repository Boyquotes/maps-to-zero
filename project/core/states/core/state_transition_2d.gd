class_name StateTransition2D
extends Node

var _character: Character
var _state: CharacterState


func init(state: CharacterState):
	_state = state
	_state.state_transitions.append(self)
	_character = _state._character


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
