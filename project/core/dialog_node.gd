class_name DialogNode
extends Node

signal finished
signal finished_and_play_animation(finished_cutscene_animation_name)

@export var timeline_path : String
@export var finished_cutscene_animation_name : String

func trigger():
	var dialog = Dialogic.start(timeline_path)
	Dialogic.timeline_ended.connect(_on_finished)


func _on_finished() -> void:
	finished.emit()
	finished_and_play_animation.emit(finished_cutscene_animation_name)
