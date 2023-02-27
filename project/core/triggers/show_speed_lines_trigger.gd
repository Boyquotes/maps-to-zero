class_name ShowSpeedLinesTrigger
extends Trigger

func trigger(_dummy_var=null) -> void:
	super.trigger()
	ScreenEffects.show_speedlines()
