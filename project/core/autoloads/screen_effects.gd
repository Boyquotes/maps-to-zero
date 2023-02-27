class_name ScreenEffectsClass
extends CanvasLayer

signal cover_finished
signal uncover_finished
signal cutscene_bars_show_finished
signal cutscene_bars_hide_finished

enum CoverAnimations { FADE_IN, FADE_IN_WHITE }
const COVER_ANIMATIONS := {
	CoverAnimations.FADE_IN: "fade_in",
	CoverAnimations.FADE_IN_WHITE: "fade_in_white",
}

enum UncoverAnimations { FADE_OUT, FADE_OUT_WHITE }
const UNCOVER_ANIMATIONS := {
	UncoverAnimations.FADE_OUT: "fade_out",
	UncoverAnimations.FADE_OUT_WHITE: "fade_out_white",
}

@onready var cutscene_bars := $CutsceneBars
@onready var speed_lines := $SpeedLines
@onready var skill_frames := $SkillFrames
@onready var cover := $ScreenTransition/Cover
@onready var uncover := $ScreenTransition/Uncover


func show_cutscene_bars(duration:= 1.0) -> void:
	cutscene_bars.show_cutscene_bars(duration)
	if is_zero_approx(duration):
		cutscene_bars_show_finished.emit()
	else:
		await cutscene_bars.show_finished
		cutscene_bars_show_finished.emit()

func hide_cutscene_bars(duration:= 1.0) -> void:
	cutscene_bars.hide_cutscene_bars(duration)
	if is_zero_approx(duration):
		cutscene_bars_hide_finished.emit()
	else:
		await cutscene_bars.hide_finished
		cutscene_bars_hide_finished.emit()

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


func cover_screen(animation: CoverAnimations, duration:= 1.0) -> void:
	uncover.get_node("AnimationPlayer").play("hide")
	var animation_player: AnimationPlayer = cover.get_node("AnimationPlayer")
	animation_player.speed_scale = 1.0 / duration
	animation_player.play(COVER_ANIMATIONS[animation])
	
	await animation_player.animation_finished
	cover_finished.emit()


func uncover_screen(animation: UncoverAnimations, duration:= 1.0) -> void:
	uncover.visible = true
	cover.get_node("AnimationPlayer").play("hide")
	var animation_player: AnimationPlayer = uncover.get_node("AnimationPlayer")
	animation_player.speed_scale = 1.0 / duration
	animation_player.play(UNCOVER_ANIMATIONS[animation])
	await animation_player.animation_finished
	uncover_finished.emit()
	uncover.visible = false
