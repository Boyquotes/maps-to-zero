extends Behavior2DScript

var direction: Vector2 = Vector2.ZERO


func enter(msg:={}):
	if "direction" in msg:
		direction = msg.direction
	super.enter(msg)


func get_input_direction() -> Vector2:
	return direction
