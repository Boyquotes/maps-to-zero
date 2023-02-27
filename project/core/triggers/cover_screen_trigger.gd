class_name CoverScreenTrigger
extends Trigger

signal finished

@export var cover_animation: ScreenEffectsClass.CoverAnimations
@export var cover_duration: float = 0.0


func trigger(_dummy_var=null) -> void:
	super.trigger()
	cover(cover_duration)

func cover(duration:=0.0) -> void:
	ScreenEffects.cover_screen(cover_animation, duration)
	await ScreenEffects.cover_finished
	finished.emit()
