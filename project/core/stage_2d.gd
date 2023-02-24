class_name Stage
extends Node2D

@export var song : Music.Songs

var normal_entry: bool = true
var player_respawning: bool = false
var entry_points: Array:
	get:
		return $EntryPoints.get_children()

func _ready():
	if normal_entry:
		if not player_respawning:
			start_gameplay()

func start_gameplay() -> void:
	start_music()

func start_music() -> void:
	if song != Music.Songs.NULL:
		MusicManager.play(song)
