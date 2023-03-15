extends Trigger
class_name PrintDebugTrigger


@export var message := ""


func trigger(_dummy_var=null) -> void:
	super.trigger()
	print_debug(message)
