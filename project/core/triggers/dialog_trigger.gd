class_name DialogTrigger
extends Trigger

signal finished
signal finished_and_play_animation(finished_cutscene_animation_name)

@export var timeline : Resource
@export var finished_cutscene_animation_name : String


func trigger(_dummy_var=null) -> void:
	super.trigger(_dummy_var)
	var dialog = Dialogic.start(timeline)
	Dialogic.timeline_ended.connect(_on_finished)


func _on_finished() -> void:
	Dialogic.timeline_ended.disconnect(_on_finished)
	finished.emit()
	finished_and_play_animation.emit(finished_cutscene_animation_name)