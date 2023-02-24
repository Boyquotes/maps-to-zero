class_name ScreenEffectsClass
extends CanvasLayer

signal screen_transition_finished

enum ScreenTransition { DEFAULT, FADE_IN, FADE_OUT }

@onready var cutscene_bars := $CutsceneBars
@onready var speed_lines := $SpeedLines
@onready var skill_frames := $SkillFrames


func show_cutscene_bars(duration:= 1.0) -> void:
	cutscene_bars.show_cutscene_bars(duration)

func hide_cutscene_bars(duration:= 1.0) -> void:
	cutscene_bars.hide_cutscene_bars(duration)

func show_speedlines() -> void:
	$SpeedLines/GPUParticles2D.emitting = true

func hide_speedlines() -> void:
	$SpeedLines/GPUParticles2D.emitting = false

func show_skill_frame(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		$SkillFrames/AnimationPlayer.play("show")
	else:
		$SkillFrames/AnimationPlayer.speed_scale = 1.0 / duration
		$SkillFrames/AnimationPlayer.play("show")

func hide_skill_frame(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		$SkillFrames.visible = false
	else:
		$SkillFrames/AnimationPlayer.speed_scale = 1.0 / duration
		$SkillFrames/AnimationPlayer.play("hide")

func screen_transition(animation: ScreenTransition, duration:=1.0) -> void:
	var animation_player: AnimationPlayer = $ScreenTransition/AnimationPlayer
	animation_player.speed_scale = 1.0 / duration
	var dict := {
		ScreenTransition.DEFAULT: "fade_in",
		ScreenTransition.FADE_IN: "fade_in",
		ScreenTransition.FADE_OUT: "fade_out"
	}
	animation_player.play(dict[animation])
	await animation_player.animation_finished
	screen_transition_finished.emit()
