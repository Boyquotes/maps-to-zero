class_name Stage
extends Node2D

@export var song : Music.Songs

var normal_entry: bool = true
var player_respawning: bool = false
var entry_points: Array

func _ready():
	for entry_point in $EntryPoints.get_children():
		entry_points.append(entry_point)
	
	if normal_entry:
		if not player_respawning:
			start_gameplay()

func start_gameplay() -> void:
	start_music()

func start_music() -> void:
	if song != Music.Songs.NULL:
		MusicManager.play(song)
