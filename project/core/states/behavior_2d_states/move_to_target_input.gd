# idle_input.gd
extends Behavior2DScript


func get_input_direction() -> Vector2:
	return Vector2(sign(actor.get_direction_to_target().x), 0)
