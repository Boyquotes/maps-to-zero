# idle_input.gd
extends Behavior2DScript


func get_input_direction() -> Vector2:
	return Vector2(sign(actor.target_manager.get_direction().x), 0)
