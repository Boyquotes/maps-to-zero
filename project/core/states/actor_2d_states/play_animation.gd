# play_animation.gd
extends Actor2DState

@export var animation := "defeat"

func enter(_msg := {}) -> void:
	actor.play_animation(animation)
