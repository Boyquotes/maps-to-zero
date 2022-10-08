class_name Stage
extends Node2D

@export var song : Music.Songs

var normal_entry: bool = true

var entry_points: Array

func _ready():
	for entry_point in $EntryPoints.get_children():
		entry_points.append(entry_point)
	
	if normal_entry:
		start_gameplay()

func start_gameplay() -> void:
	if song != Music.Songs.NULL:
		MusicManager.play(song)
