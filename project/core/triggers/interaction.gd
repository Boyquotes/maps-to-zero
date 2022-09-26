class_name Interaction
extends Node2D

signal triggered

func trigger() -> void:
	triggered.emit()
