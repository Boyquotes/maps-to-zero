class_name CutsceneBars
extends Control

signal show_finished
signal hide_finished

@onready var _animation_player : AnimationPlayer = $AnimationPlayer


func show_cutscene_bars(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		visible = true
		_animation_player.play("showing")
		show_finished.emit()
	else:
		_animation_player.speed_scale = 1.0 / duration
		_animation_player.play("show_bars")
		visible = true
		await _animation_player.animation_finished
		show_finished.emit()


func hide_cutscene_bars(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		visible = false
		hide_finished.emit()
	else:
		_animation_player.speed_scale = 1.0 / duration
		_animation_player.play("hide_bars")
		visible = true
		await _animation_player.animation_finished
		hide_finished.emit()
