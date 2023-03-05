class_name Ticker
extends Area2D


func _ready():
	_set_collision()


func _set_collision() -> void:
	collision_layer = 0
#	set_collision_layer_value(GameUtilities.PhysicsLayers.TRIGGERS, true)
	collision_mask = 0
	set_collision_mask_value(GameUtilities.PhysicsLayers.TRIGGERS, true)
