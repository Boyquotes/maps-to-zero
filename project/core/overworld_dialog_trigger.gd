extends Trigger

@export var dialog: Resource
@export var title := "start"
@export var next_line_delay := 5.0


func trigger(_dummy_var=null) -> void:
	DialogUtilities.show_overworld_dialog_balloon(dialog, title, next_line_delay)
	super.trigger()
