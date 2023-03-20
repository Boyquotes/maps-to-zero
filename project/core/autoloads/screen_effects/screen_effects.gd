class_name ScreenEffectsClass
extends CanvasLayer

signal cover_finished
signal uncover_finished
signal cutscene_bars_show_finished
signal cutscene_bars_hide_finished
signal border_frame_show_finished
signal border_frame_hide_finished

enum CoverAnimations { FADE_TO_BLACK, FADE_TO_WHITE }
enum UncoverAnimations { FADE_OUT_BLACK, FADE_OUT_WHITE }

const COVER_ANIMATIONS := {
	CoverAnimations.FADE_TO_BLACK: "fade_to_black",
	CoverAnimations.FADE_TO_WHITE: "fade_to_white",
}

const UNCOVER_ANIMATIONS := {
	UncoverAnimations.FADE_OUT_BLACK: "fade_out_black",
	UncoverAnimations.FADE_OUT_WHITE: "fade_out_white",
}

@onready var _cutscene_bars := $CutsceneBars as CutsceneBars
@onready var _speed_lines := $SpeedLines
@onready var _skill_frames := $SkillFrames
@onready var _cover := $ScreenTransition/Cover
@onready var _uncover := $ScreenTransition/Uncover


func show_cutscene_bars(duration:= 1.0) -> void:
	_cutscene_bars.show_cutscene_bars(duration)
	if is_zero_approx(duration):
		cutscene_bars_show_finished.emit()
	else:
		await _cutscene_bars.show_finished
		cutscene_bars_show_finished.emit()


func hide_cutscene_bars(duration:= 1.0) -> void:
	_cutscene_bars.hide_cutscene_bars(duration)
	if is_zero_approx(duration):
		cutscene_bars_hide_finished.emit()
	else:
		await _cutscene_bars.hide_finished
		cutscene_bars_hide_finished.emit()


func show_speedlines() -> void:
	_speed_lines.get_node("GPUParticles2D").emitting = true


func hide_speedlines() -> void:
	_speed_lines.get_node("GPUParticles2D").emitting = false


func show_border_frame(duration:= 1.0) -> void:
	var animation_player := _skill_frames.get_node("AnimationPlayer") as AnimationPlayer
	if is_equal_approx(duration, 0.0):
		animation_player.play("show")
		border_frame_show_finished.emit()
	else:
		animation_player.speed_scale = 1.0 / duration
		animation_player.play("show")
		await animation_player.animation_finished
		border_frame_show_finished.emit()


func hide_border_frame(duration:= 1.0) -> void:
	var animation_player := _skill_frames.get_node("AnimationPlayer") as AnimationPlayer
	if is_equal_approx(duration, 0.0):
		_skill_frames.visible = false
		border_frame_hide_finished.emit()
	else:
		animation_player.speed_scale = 1.0 / duration
		animation_player.play("hide")
		await animation_player.animation_finished
		border_frame_hide_finished.emit()


func cover_screen(animation: CoverAnimations, duration:= 1.0) -> void:
	_uncover.get_node("AnimationPlayer").play("hide")
	var animation_player: AnimationPlayer = _cover.get_node("AnimationPlayer")
	animation_player.speed_scale = 1.0 / duration
	animation_player.play(COVER_ANIMATIONS[animation])
	
	await animation_player.animation_finished
	cover_finished.emit()


func uncover_screen(animation: UncoverAnimations, duration:= 1.0) -> void:
	_uncover.visible = true
	_cover.get_node("AnimationPlayer").play("hide")
	var animation_player: AnimationPlayer = _uncover.get_node("AnimationPlayer")
	animation_player.speed_scale = 1.0 / duration
	animation_player.play(UNCOVER_ANIMATIONS[animation])
	await animation_player.animation_finished
	uncover_finished.emit()
	_uncover.visible = false
