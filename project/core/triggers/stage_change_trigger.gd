class_name StageChangeTrigger
extends Trigger

@export var stage_file_path: String
@export var destination_entry_point: int
@export var screen_transition: ScreenEffectsClass.ScreenTransitions
@export var transition_duration: float = 0.0


func trigger(_dummy_var=null) -> void:
	GameManager.cutscene_mode = true
	GameManager.player.cutscene_mode = true
	ScreenEffects.screen_transition(screen_transition, transition_duration)
	await ScreenEffects.screen_transition_finished
	GameManager.request_stage_change(stage_file_path, destination_entry_point)
	super.trigger()
