@tool
class_name ActorTransformer2D
extends ActorCutsceneTransformer


@export var move_with_look_direction: bool = true

func _physics_process(delta):
	if last_frame_position.is_equal_approx(position - center_offset):
		actor.velocity = Vector2.ZERO
	else:
		var position_delta = (position - center_offset) - last_frame_position
		if move_with_look_direction:
			position_delta.x *= sign(actor.look_direction.x)
		actor.velocity = position_delta / delta
	last_frame_position = position - center_offset
	
	actor.rotation = rotation
#	actor.inner.scale = scale

func enable() -> void:
	set_physics_process(true)
	last_frame_position = position - center_offset

func disable() -> void:
	set_physics_process(false)
	actor.rotation = 0
#	actor.velocity = Vector2.ZERO


func look_other_way() -> void:
	actor.look_direction.x *= -1
