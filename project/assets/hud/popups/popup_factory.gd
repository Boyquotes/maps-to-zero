class_name PopupFactory
extends Node

const YES_NO_PATH = "res://assets/hud/components/yes_no_menu/yes_no_menu.tscn"


static func popup_tutorial(tutorial: Tutorial.Screens) -> Tutorial:
	var tutorial_prompt := load(Tutorial.TUTORIAL_PATHS[tutorial]).instantiate() as Tutorial
	GameUtilities.get_popup_canvas().add_child(tutorial_prompt)
	return tutorial_prompt


static func popup_yes_no_menu(message: String, yes_callback: Callable, no_callback: Callable) -> YesNoMenu:
	var yes_no_menu := load(YES_NO_PATH).instantiate() as YesNoMenu
	GameUtilities.get_popup_canvas().add_child(yes_no_menu)
	yes_no_menu.initialize(message, yes_callback, no_callback)
	yes_no_menu.queue_free_on_selection = true
	return yes_no_menu

