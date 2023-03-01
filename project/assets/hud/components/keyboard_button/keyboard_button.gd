@tool
extends Control

@export var text: String:
	set(value):
		text = value
		if not is_ready:
			await ready
		get_node("Icon/Label").text = text


@onready var label: Label = $Icon/Label

var is_ready: bool
func _ready() -> void:
	is_ready = true
