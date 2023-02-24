extends Area2D
class_name SoftCollision

@export var owner_only_pushed_horizontally : bool = true
@export var push_force := 500.0
@export var force_multiplier_on_self := 1.0


func is_colliding() -> bool:
	return get_overlapping_areas().size() > 0

func get_push_vector() -> Vector2:
	var areas = get_overlapping_areas()
	if areas.size() > 0:
		var push_vector = Vector2.ZERO
		for area in areas:
			if not area is SoftCollision:
				continue
			var vector_from_this_area = Vector2.ZERO
			if owner_only_pushed_horizontally:
				vector_from_this_area = Vector2(area.global_position.direction_to(global_position).x, 0)
			else:
				vector_from_this_area = area.global_position.direction_to(global_position)
			push_vector += vector_from_this_area * area.push_force
		return push_vector * force_multiplier_on_self
	return Vector2.ZERO
