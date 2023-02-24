extends Control

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func show_cutscene_bars(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		visible = true
		animation_player.play("showing")
	else:
		animation_player.speed_scale = 1.0 / duration
		animation_player.play("show_bars")
		visible = true


func hide_cutscene_bars(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		visible = false
	else:
		animation_player.speed_scale = 1.0 / duration
		animation_player.play("hide_bars")
		visible = true
