extends Control

signal show_finished
signal hide_finished

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func show_cutscene_bars(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		visible = true
		animation_player.play("showing")
		show_finished.emit()
	else:
		animation_player.speed_scale = 1.0 / duration
		animation_player.play("show_bars")
		visible = true
		await animation_player.animation_finished
		show_finished.emit()


func hide_cutscene_bars(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		visible = false
		hide_finished.emit()
	else:
		animation_player.speed_scale = 1.0 / duration
		animation_player.play("hide_bars")
		visible = true
		await animation_player.animation_finished
		hide_finished.emit()
