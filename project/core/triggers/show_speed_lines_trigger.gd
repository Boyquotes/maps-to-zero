extends Trigger
class_name ShowSpeedLinesTrigger

func trigger(_dummy_var=null) -> void:
	super.trigger()
	ScreenEffects.show_speedlines()
