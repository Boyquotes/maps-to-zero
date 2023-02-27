class_name UncoverScreenTrigger
extends Trigger

signal finished

@export var uncover_animation: ScreenEffectsClass.UncoverAnimations
@export var uncover_duration: float = 0.0


func trigger(_dummy_var=null) -> void:
	super.trigger()
	uncover(uncover_duration)

func uncover(duration:=0.0) -> void:
	ScreenEffects.uncover_screen(uncover_animation, duration)
	await ScreenEffects.uncover_finished
	finished.emit()
