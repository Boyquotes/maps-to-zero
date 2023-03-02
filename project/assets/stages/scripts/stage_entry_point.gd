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
@export var uncover_animation: ScreenEffectsClass.UncoverAnimations
@export var uncover_duration := 1.0
@export var entry_camera_settings: NodePath
@export var show_game_hud_duration := 1.0

@onready var _animation_player := $AnimationPlayer as AnimationPlayer
@onready var _show_game_hud_trigger := $ShowGameHudTrigger as ShowGameHudTrigger


func enter(character: Actor2D):
	var camera_settings := get_node(entry_camera_settings) as CameraSettingsTrigger
	if camera_settings:
		camera_settings.change_limits_immediately()
		camera_settings.change_zoom_immediately()
	
	character.global_position = global_position
	
	GameUtilities.get_main_camera().align()
	GameUtilities.get_main_camera().reset_smoothing()
	GameUtilities.get_main_camera().make_current()
	
	_animation_player.play(ANIMATIONS[animation])
	
	ScreenEffects.uncover_screen(uncover_animation, uncover_duration)
	
	ScreenEffects.show_cutscene_bars(0)
	await ScreenEffects.uncover_finished
	ScreenEffects.hide_cutscene_bars(1)
	_show_game_hud_trigger.show_game_hud(show_game_hud_duration)
