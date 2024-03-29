# play_animation.gd
extends CharacterState

@export var animation := "defeat"


func enter(_msg := {}) -> void:
	_character.play_animation(animation)
	_character.velocity = Vector2.ZERO


func physics_update(_delta: float) -> void:
	_character.velocity = Vector2.ZERO
