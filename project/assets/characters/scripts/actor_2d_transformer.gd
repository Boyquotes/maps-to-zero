@tool
class_name ActorTransformer2D
extends ActorCutsceneTransformer


@export var move_with_look_direction: bool = true


func _physics_process(delta):
	if not _enabled or Engine.is_editor_hint():
		set_physics_process(false)
		return
	
	if _last_frame_position.is_equal_approx(position - center_offset):
		_character.velocity = Vector2.ZERO
	else:
		var position_delta = (position - center_offset) - _last_frame_position
		if move_with_look_direction:
			position_delta.x *= sign(_character.look_direction.x)
		_character.velocity = position_delta / delta
	_last_frame_position = position - center_offset
	
	_character.rotation = rotation
#	_character.inner.scale = scale


func enable() -> void:
	_enabled = true
	set_physics_process(true)
	_last_frame_position = position - center_offset
	if animation:
		_character.play_animation(animation)


func disable() -> void:
	_enabled = false
	set_physics_process(false)
	_character.rotation = 0


func look_other_way() -> void:
	_character.look_direction.x *= -1
