extends Node

const SAVE_GAME_FOLDER := "user://saves/"

signal loaded_data

# Save file data
var version := 1
var current_stage_file_path : String
var player_saved_position: Vector2
var camera_zoom: Vector2
var player_data := {
	"base_max_background_jumps" = 1,
	"base_max_mid_air_jumps" = 0,
}

# Event flags
var cutscenes := {} # True if watched at least once, false otherwise





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
		"current_stage_file_path" : current_stage_file_path,
		"player_saved_position": player_saved_position,
		"player_data": player_data,
		"cutscenes" : cutscenes,
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
	current_stage_file_path = data.current_stage_file_path
	player_saved_position = data.player_saved_position
	player_data = data.player_data
	cutscenes = data.cutscenes
	
	loaded_data.emit()
