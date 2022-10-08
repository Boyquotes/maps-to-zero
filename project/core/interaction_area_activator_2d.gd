class_name InteractionAreaActivator2D
extends Area2D

signal triggered


func _ready():
	monitoring = false
	monitorable = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(4, true)
