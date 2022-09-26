class_name Spawner2D
extends Marker2D

signal spawned(object)

@export var scene : PackedScene

func spawn(parent):
	var new_object = scene.instantiate()
	
	parent.add_child(new_object)
	new_object.global_position = global_position
	new_object.global_transform = global_transform
	
	spawned.emit(new_object)
	
	return new_object
