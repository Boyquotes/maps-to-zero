class_name HideSpeedLinesTrigger
extends Trigger

func trigger(_dummy_var=null) -> void:
	super.trigger()
	ScreenEffects.hide_speedlines()
