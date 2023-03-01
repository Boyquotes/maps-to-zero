extends Behavior2DScript

var target_global_position: Vector2

func get_input_direction() -> Vector2:
	return Vector2(sign(actor.global_position.direction_to(target_global_position).x), 0)
