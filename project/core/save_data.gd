extends Node

const SAVE_GAME_FOLDER := "user://saves/"
var _file := File.new()


var version := 1
var base_background_jumps := 1
var stage_name := ""

var horizon_hills_alisa_summoned := true
var horizon_hills_demon_portal_open := true
var horizon_hills_alisa_falling_cutscene_watched := true





func save_exists(save_file_number: int) -> bool:
	var save_file_path := SAVE_GAME_FOLDER + "save_" + save_file_number + ".json"
	return _file.file_exists(save_file_path)


func write_savegame(save_file_number: int) -> void:
	var save_file_path := SAVE_GAME_FOLDER + "save_" + save_file_number + ".json"
	
	var error := _file.open(save_file_path, File.WRITE)
	if error != OK:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [save_file_path, error])
		return

	var data := {
		"version" : version,
		"stage_name" : stage_name,
		"horizon_hills_alisa_summoned" : horizon_hills_alisa_summoned,
		"base_background_jumps" : base_background_jumps,
		"horizon_hills_alisa_falling_cutscene_watched": horizon_hills_alisa_falling_cutscene_watched
	}
	
	var json_string := JSON.stringify(data)
	_file.store_string(json_string)
	_file.close()


func load_savegame(save_file_number: int) -> void:
	var save_file_path := SAVE_GAME_FOLDER + "save_" + save_file_number + ".json"
	
	var error := _file.open(save_file_path, File.READ)
	if error != OK:
		printerr("Could not open the file %s. Aborting load operation. Error code: %s" % [save_file_path, error])
		return

	var content := _file.get_as_text()
	_file.close()

	var data: Dictionary = JSON.parse_string(content).result
	
	version = data.version
	stage_name = data.stage_name
	horizon_hills_alisa_summoned = data.horizon_hills_alisa_summoned
	base_background_jumps = data.base_background_jumps
	horizon_hills_alisa_falling_cutscene_watched = data.horizon_hills_alisa_falling_cutscene_watched
