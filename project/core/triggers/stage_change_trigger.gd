class_name StageChangeTrigger
extends Trigger

@export var stage_file_path: String
@export var destination_entry_point: int
@export var cover_animation: ScreenEffectsClass.CoverAnimations
@export var cover_duration: float = 0.0


func trigger(_dummy_var=null) -> void:
	GameManager.cutscene_mode = true
	GameManager.player.cutscene_mode = true
	ScreenEffects.cover_screen(cover_animation, cover_duration)
	await ScreenEffects.cover_finished
	GameManager.request_stage_change(stage_file_path, destination_entry_point)
	super.trigger()
