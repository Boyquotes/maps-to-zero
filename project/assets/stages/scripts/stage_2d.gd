class_name Stage
extends Node2D

@export var song : AudioStream

var normal_entry: bool = true
var player_respawning: bool = false
var entry_points: Array:
	get:
		return %EntryPoints.get_children()


@onready var _wall_decals := %WallDecals as Node2D


func _ready():
	if normal_entry:
		if not player_respawning:
			start_gameplay()


func start_gameplay() -> void:
	start_music()


func start_music() -> void:
	MusicManager.play(song)


func get_wall_decals() -> Node2D:
	return _wall_decals
