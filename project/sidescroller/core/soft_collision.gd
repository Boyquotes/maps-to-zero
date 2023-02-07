extends Area2D
class_name SoftCollision

@export var push_horizontally_only : bool = false
@export var push_force:= 600.0

func is_colliding() -> bool:
	var areas = get_overlapping_areas()
	return areas.size() > 0


func get_push_vector() -> Vector2:
	var areas = get_overlapping_areas()
	var push_vector = Vector2.ZERO
	if is_colliding():
		var area = areas[0]
		if push_horizontally_only:
			push_vector = Vector2(area.global_position.direction_to(global_position).x, 0)
		else:
			push_vector = area.global_position.direction_to(global_position)
		push_vector = push_vector.normalized()
	return push_vector * push_force
