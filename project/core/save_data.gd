extends Node

const SAVE_GAME_FOLDER := "user://saves/"

signal loaded_data

# Save file data
var version := 1
var base_background_jumps := 1
var stage_file_path : String
var player_saved_position: Vector2
var player_data: Dictionary
var camera_zoom: Vector2

# Event flags
var movement_tutorial_cutscene_watched := false





func save_exists(save_file_number: int) -> bool:
	var save_file_path := SAVE_GAME_FOLDER + "save_" + str(save_file_number) + ".json"
	return FileAccess.file_exists(save_file_path)


func write_savegame(save_file_number: int) -> void:
	var save_file_path := SAVE_GAME_FOLDER + "save_" + str(save_file_number) + ".json"
	
	var file := FileAccess.open(save_file_path, FileAccess.WRITE)
	if file == null:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [save_file_path, FileAccess.get_open_error()])
		return
	
	var data := {
		"version" : version,
		"stage_file_path" : stage_file_path,
		"player_saved_position": player_saved_position,
		"player_data": player_data,
		
		"base_background_jumps" : base_background_jumps,
		
		"movement_tutorial_cutscene_watched" : movement_tutorial_cutscene_watched,
	}
	
	var json_string := JSON.stringify(data)
	file.store_string(json_string)
	file = null


func load_savegame(save_file_number: int) -> void:
	var save_file_path := SAVE_GAME_FOLDER + "save_" + str(save_file_number) + ".json"
	
	var file := FileAccess.open(save_file_path, FileAccess.READ)
	if file == null:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [save_file_path, FileAccess.get_open_error()])
		return
	
	var content := file.get_as_text()
	file = null
	
	var data: Dictionary = JSON.parse_string(content).result
	
	version = data.version
	stage_file_path = data.stage_file_path
	player_saved_position = data.player_saved_position
	player_data = data.player_data
	
	base_background_jumps = data.base_background_jumps
	
	movement_tutorial_cutscene_watched = data.movement_tutorial_cutscene_watched
	
	loaded_data.emit()
