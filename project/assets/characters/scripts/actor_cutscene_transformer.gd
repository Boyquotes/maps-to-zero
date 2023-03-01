@tool
class_name ActorCutsceneTransformer
extends Marker2D

@export var actor_name: String = ""
@export var center_offset: Vector2 = Vector2(0, 16)
@export_enum("Right", "Left") var look_direction:
	set(value):
		look_direction = value
		if _enabled or Engine.is_editor_hint():
			update_look_direction()
@export var animation := "":
	set(value):
		animation = value
		if _enabled or Engine.is_editor_hint():
			_character.play_animation(animation)


var _last_frame_position : Vector2
var _character: Actor2D:
	get:
		if _character:
			return _character as Actor2D
		if Engine.is_editor_hint():
			if get_child_count() == 1 and get_child(0) is Actor2D:
				_character = get_child(0)
			elif owner is Actor2D:
				_character = owner
			return _character as Actor2D
		if actor_name == "":
			_character = owner
		elif actor_name == "PLAYER":
			_character = GameManager.player
		else:
			_character = GameManager.actors[actor_name]
		return _character as Actor2D
var _move_to_global_position: bool = false
var _move_to_position_buffer := 32.0
var _enabled: bool = false


func _physics_process(delta):
	if not _enabled or Engine.is_editor_hint():
		set_physics_process(false)
		return
	
	if _move_to_global_position:
		_move_character_to_global_position()
		return
	
	if _last_frame_position.is_equal_approx(position - center_offset):
		_character.velocity = Vector2.ZERO
	else:
		var position_delta = (position - center_offset) - _last_frame_position
		_character.velocity = position_delta / delta
	_last_frame_position = position - center_offset
	
	_character.rotation = rotation
#	_character.inner.scale = scale


func actor_queue_free() -> void:
	set_physics_process(false)
	_character.queue_free()


func teleport() -> void:
	_last_frame_position = position - center_offset
	_character.velocity = Vector2.ZERO
	_character.global_position = global_position - center_offset


func enable() -> void:
	_enabled = true
	_character.set_cutscene_mode(true)
	set_physics_process(true)
	_last_frame_position = position - center_offset
	_character.play_animation(animation)


func disable() -> void:
	_enabled = false
	_character.set_cutscene_mode(false)
	set_physics_process(false)
	_character.rotation = 0


func show_character() -> void:
	_character.visible = true


func hide_character() -> void:
	_character.visible = false


func enable_input() -> void:
	_character.enable_input()


func disable_input() -> void:
	_character.disable_input()


func reset_speed() -> void:
	_character.velocity = Vector2.ZERO


func move_to_global_position() -> void:
	_move_to_global_position = true


func update_look_direction() -> void:
	match look_direction:
		0:
			_character.look_direction = Vector2.RIGHT
		1:
			_character.look_direction = Vector2.LEFT
		_:
			_character.look_direction = Vector2.RIGHT


func _move_character_to_global_position() -> void:
	var move_to_position_state = _character.input_state_machine.get_state("MoveToPosition")
	move_to_position_state.target_global_position = global_position
	_character.input_state_machine.transition_to("MoveToPosition")
	
	if _character.global_position.distance_to(global_position - center_offset) < _move_to_position_buffer:
		_character.global_position = global_position - center_offset
		update_look_direction()
		_character.set_cutscene_mode(true)
		_character.play_animation(animation)
