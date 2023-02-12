extends Node

signal screen_transition_finished

func show_cutscene_bars(duration:= 1.0) -> void:
	GameManager.show_cutscene_bars(duration)


func hide_cutscene_bars(duration:= 1.0) -> void:
	GameManager.hide_cutscene_bars(duration)

func show_speedlines() -> void:
	GameManager.show_speedlines()

func hide_speedlines() -> void:
	GameManager.hide_speedlines()

func show_skill_frame(duration:= 1.0) -> void:
	GameManager.show_skill_frame(duration)

func hide_skill_frame(duration:= 1.0) -> void:
	GameManager.hide_skill_frame(duration)
