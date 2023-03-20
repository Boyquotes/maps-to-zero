class_name HideSkillFrameTrigger
extends Trigger

signal finished

@export var duration: float = 0.0


func trigger(_dummy_var=null) -> void:
	super.trigger()
	hide_skill_frame(duration)

func hide_skill_frame(_duration:=0.0) -> void:
	ScreenEffects.hide_border_frame(_duration)
	if is_zero_approx(_duration):
		finished.emit()
	else:
		await ScreenEffects.border_frame_hide_finished
		finished.emit()
