class_name ShowSkillFrameTrigger
extends Trigger

signal finished

@export var duration: float = 0.0


func trigger(_dummy_var=null) -> void:
	super.trigger()
	show_skill_frame(duration)

func show_skill_frame(_duration:=0.0) -> void:
	ScreenEffects.show_border_frame(_duration)
	if is_zero_approx(_duration):
		finished.emit()
	else:
		await ScreenEffects.border_frame_show_finished
		finished.emit()
