class_name IncreaseBackgroundJumpsTrigger
extends Trigger

func trigger(_dummy_var=null) -> void:
	super.trigger(_dummy_var)
	SaveData.player_data.base_max_background_jumps += 1
