class_name StageExitPoint
extends Node2D

enum Animations { FAST_FADE_TO_BLACK, BLINK, FADE_TO_BLACK, SMOKE_TELEPORT_RIGHT, SMOKE_TELEPORT_LEFT, RUN_RIGHT, RUN_LEFT, WALK_RIGHT, WALK_LEFT }
const ANIMATIONS := {
	Animations.FAST_FADE_TO_BLACK : "fast_fade_to_black",
	Animations.BLINK : "blink",
	Animations.FADE_TO_BLACK : "fade_to_black",
	Animations.SMOKE_TELEPORT_RIGHT : "smoke_teleport_right",
	Animations.SMOKE_TELEPORT_LEFT : "smoke_teleport_left",
	Animations.RUN_RIGHT : "run_right",
	Animations.RUN_LEFT : "run_left",
	Animations.WALK_RIGHT : "walk_right",
	Animations.WALK_LEFT : "walk_left",
}

@export var animation : Animations
@export var stage_file_path: String
@export var destination_entry_point: int
@export var fade_out_song: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stage_change_trigger: StageChangeTrigger = $StageChangeTrigger
@onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	stage_change_trigger.stage_file_path = stage_file_path
	stage_change_trigger.destination_entry_point = destination_entry_point


func trigger(_dummy_var=null):
	animation_player.play(ANIMATIONS[animation])
	area_2d.set_collision_mask_value(4, false)
	if fade_out_song:
		var current_animation := animation_player.get_animation(animation_player.current_animation) as Animation
		MusicManager.play(null, current_animation.length)
