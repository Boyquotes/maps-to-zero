# play_animation.gd
extends CharacterState

@export var animation := "defeat"


func enter(_msg := {}) -> void:
	_character.play_animation(animation)
