extends Node


const TILE_SIZE := Vector2(16, 16)
const SFX_FOLDER := "res://assets/sfx/"

var loaded_sfx := {} # { file_name, load(file_path) }
var particles := {} # { particles_name, load(particles_name) }
