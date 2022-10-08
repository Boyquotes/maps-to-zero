extends Node

@export var visible: bool = true:
	set(value):
		visible = value
		for child in get_children():
			child.visible = value
