extends Node2D

@export var is_visible: bool = true:
	set(value):
		visible = value
		for child in get_children():
			child.visible = value
