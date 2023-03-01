class_name YesNoMenu
extends Control

@export var queue_free_on_selection: bool

@onready var message_label : RichTextLabel = %MessageLabel
@onready var yes_button : Button = %YesButton
@onready var no_button : Button = %NoButton

var yes_callback: Callable
var no_callback: Callable

func initialize(message: String, _yes_callback: Callable, _no_callback: Callable) -> void:
	message_label.text = message
	yes_callback = _yes_callback
	no_callback = _no_callback
	yes_button.pressed.connect(_on_yes)
	no_button.pressed.connect(_on_no)

func _on_yes() -> void:
	yes_callback.call()
	if queue_free_on_selection:
		queue_free()

func _on_no() -> void:
	no_callback.call()
	if queue_free_on_selection:
		queue_free()
