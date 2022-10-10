class_name Trigger
extends Node2D

signal triggered

func trigger(_dummy_var=null) -> void:
	triggered.emit()
