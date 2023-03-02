class_name IncreaseBackgroundJumpsTrigger
extends Trigger

func trigger(_dummy_var=null) -> void:
	super.trigger(_dummy_var)
	SaveData.base_background_jumps += 1
