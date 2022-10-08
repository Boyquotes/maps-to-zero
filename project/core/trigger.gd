extends Node

signal triggered

func trigger(_dummy_var=null) -> void:
	triggered.emit()
