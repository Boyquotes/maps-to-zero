class_name StageEntryPoint
extends Node2D

enum Animations { DEFAULT, FACE_RIGHT, FACE_LEFT, WALK_IN_FROM_LEFT, WALK_IN_FROM_RIGHT }
const ANIMATIONS := {
	Animations.DEFAULT : "face_right",
	Animations.FACE_RIGHT : "face_right",
	Animations.FACE_LEFT : "face_left",
	Animations.WALK_IN_FROM_LEFT : "walk_in_from_left",
	Animations.WALK_IN_FROM_RIGHT : "walk_in_from_right",
}

@export var animation : Animations
@export var transition_animation: ScreenEffectsClass.ScreenTransitions
@export var transition_duration := 1.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null


func enter(character: Actor2D):
	character.global_position = global_position
	
	GameUtilities.get_main_camera().align()
	GameUtilities.get_main_camera().reset_smoothing()
	GameUtilities.get_main_camera().make_current()
	
	animation_player.play(ANIMATIONS[animation])
	
	ScreenEffects.screen_transition(transition_animation, transition_duration)
	
	ScreenEffects.show_cutscene_bars(0)
	await animation_player.animation_finished
	ScreenEffects.hide_cutscene_bars(1)
