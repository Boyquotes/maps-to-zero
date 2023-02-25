extends Node

var actors := {}
var actors_original_cutscene_mode_value := {}
var sidescroller_main: SidescrollerMain
var popup_canvas: CanvasLayer

var cutscene_mode: bool:
	set(value):
		cutscene_mode = value
		if value:
			actors_original_cutscene_mode_value.clear()
			for actor in actors.values():
				actors_original_cutscene_mode_value[actor] = actor.cutscene_mode
				actor.set_cutscene_mode(true)
			ScreenEffects.show_cutscene_bars(1.0)
		else:
			for actor in actors.values():
				if actors_original_cutscene_mode_value.has(actor):
					actor.set_cutscene_mode(actors_original_cutscene_mode_value[actor])
				else:
					actor.set_cutscene_mode(false)
			ScreenEffects.hide_cutscene_bars(1.0)

var player: Actor2D
var gameplay_camera: GameplayCamera2D
var transition_camera: Camera2D

func enable_gameplay_camera_current(transition_time := 1.0) -> void:
	set_gameplay_camera_current(true, transition_time)

func set_gameplay_camera_current(value: bool, _transition_time := 1.0) -> void:
	if value:
		gameplay_camera.current = true
	else:
		gameplay_camera.current = false


func request_stage_change(stage_file_path: String, player_entry_point := 0) -> void:
	SaveData.current_stage_file_path = stage_file_path
	sidescroller_main.change_stage(load(stage_file_path), player_entry_point)

func reload() -> void:
	sidescroller_main.change_stage(load(SaveData.stage_file_path), 0, true)

func screen_shake(trauma := 0.5):
	sidescroller_main.gameplay_camera.add_trauma(trauma)