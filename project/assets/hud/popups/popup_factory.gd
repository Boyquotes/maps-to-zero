class_name PopupFactory
extends Node

const YES_NO_PATH = "res://core/popups/yes_no_menu.tscn"

static func MakeYesNo(message: String, yes_callback: Callable, no_callback: Callable, args := {}) -> YesNoMenu:
	var popup: YesNoMenu = load(YES_NO_PATH).instantiate()
	GameManager.popup_canvas.add_child(popup)
	popup.initialize(message, yes_callback, no_callback)
	popup.queue_free_on_selection = true
	return popup
