class_name TutorialTrigger
extends Trigger

signal closed

@export var tutorial: Tutorial.Screens


func trigger(_dummy_var=null) -> void:
	super.trigger(_dummy_var)
	PopupFactory.popup_tutorial(tutorial)
