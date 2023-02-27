class_name HideCutsceneBarsTrigger
extends Trigger

signal finished

@export var duration: float = 0.0


func trigger(_dummy_var=null) -> void:
	super.trigger()
	hide_cutscene_bars(duration)

func hide_cutscene_bars(_duration:=0.0) -> void:
	ScreenEffects.hide_cutscene_bars(_duration)
	if is_zero_approx(_duration):
		finished.emit()
	else:
		await ScreenEffects.cutscene_bars_hide_finished
		finished.emit()
