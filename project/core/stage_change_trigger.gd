class_name StageChangeTrigger
extends Trigger

@export var stage_file_path: String = ""
@export var destination_entry_point: int


func trigger(_dummy_var=null) -> void:
	GameManager.request_stage_change(stage_file_path, destination_entry_point)
	super.trigger()
