class_name ScreenShakeTrigger
extends Trigger

@export var trauma := 0.0

func trigger(_dummy_var=null) -> void:
	GameManager.screen_shake(trauma)
	super.trigger()
