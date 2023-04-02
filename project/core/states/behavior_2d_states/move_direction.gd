extends Behavior2DScript

var direction: Vector2 = Vector2.ZERO
var _walking : bool


func enter(msg:={}):
	if "direction" in msg:
		direction = msg.direction
	if "walking" in msg:
		_walking = msg.walking
	super.enter(msg)


func get_input_direction() -> Vector2:
	return direction


func get_walk_modifer_pressed() -> bool:
	return _walking
