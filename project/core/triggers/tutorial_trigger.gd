class_name TutorialTrigger
extends Trigger

signal closed

@export var tutorial: Tutorial.Screens
@export var disable_player_input_until_closed := true


func trigger(_dummy_var=null) -> void:
	super.trigger(_dummy_var)
	if disable_player_input_until_closed:
		GameUtilities.get_player().disable_input()
	var tutorial_screen = PopupFactory.popup_tutorial(tutorial) as Tutorial
	tutorial_screen.closed.connect(func():
		if disable_player_input_until_closed:
			GameUtilities.get_player().enable_input()
		closed.emit()
	)
