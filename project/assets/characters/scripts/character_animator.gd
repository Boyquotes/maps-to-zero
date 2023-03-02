@tool
class_name CharacterAnimator
extends Marker2D

enum MovementModes { DISABLED, MATCH, MOVE_TO_GLOBAL_POSITION, MOVE_RIGHT, MOVE_LEFT }

@export var actor_name: String = ""
@export var center_offset: Vector2 = Vector2(0, 16)
@export_enum("Right", "Left") var look_direction:
	set(value):
		look_direction = value
		update_look_direction()
@export var animation := "":
	set(value):
		animation = value
		if not _movement_mode == MovementModes.DISABLED or Engine.is_editor_hint():
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
			if GameManager.actors.has(actor_name):
				_character = GameManager.actors[actor_name]
		return _character as Actor2D
var _move_to_position_buffer := Vector2(8, 8) as Vector2
var _movement_mode: MovementModes


func _physics_process(delta):
	if _movement_mode == MovementModes.MOVE_TO_GLOBAL_POSITION:
		_move_character_to_global_position()
		return

	if _movement_mode == MovementModes.DISABLED or Engine.is_editor_hint():
		set_physics_process(false)
		return
	
	if _last_frame_position.is_equal_approx(position - center_offset):
		_character.velocity = Vector2.ZERO
	else:
		var position_delta = (position - center_offset) - _last_frame_position
		if _character == owner:
			# Move direction relative to right direction
			position_delta.x *= sign(_character.look_direction.x)
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


func enable(disable_input:=true) -> void:
	_movement_mode = MovementModes.MATCH
	set_physics_process(true)
	_last_frame_position = position - center_offset
	_character.play_animation(animation)
	if disable_input:
		_character.input_state_machine.transition_to("NoInput")


func enable_cutscene_mode() -> void:
	_character.state_machine.transition_to("Cutscene")
	enable()


func disable(reset_state_machine:=true) -> void:
	_movement_mode == MovementModes.DISABLED
	set_physics_process(false)
	_character.rotation = 0
	_character.input_state_machine.reset()
	if reset_state_machine:
		_character.state_machine.reset()
	


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
	_movement_mode = MovementModes.MOVE_TO_GLOBAL_POSITION
	var move_to_position_state = _character.input_state_machine.get_state("MoveToPosition")
	move_to_position_state.target_global_position = global_position
	_character.input_state_machine.transition_to("MoveToPosition")
	set_physics_process(true)


func update_look_direction() -> void:
	if not _character:
		return
	match look_direction:
		0:
			_character.look_direction = Vector2.RIGHT
		1:
			_character.look_direction = Vector2.LEFT
		_:
			_character.look_direction = Vector2.RIGHT


func move_right() -> void:
	_movement_mode = MovementModes.MOVE_RIGHT
	var move_direction_state = _character.input_state_machine.get_state("MoveDirection")
	_character.input_state_machine.transition_to("MoveDirection", {
		"direction": Vector2.RIGHT
	})
	set_physics_process(false)


func move_left() -> void:
	_movement_mode = MovementModes.MOVE_LEFT
	var move_direction_state = _character.input_state_machine.get_state("MoveDirection")
	_character.input_state_machine.transition_to("MoveDirection", {
		"direction": Vector2.LEFT
	})
	set_physics_process(false)


func _move_character_to_global_position() -> void:
	var move_to_position_state = _character.input_state_machine.get_state("MoveToPosition")
	move_to_position_state.target_global_position = global_position
	var position_difference = _character.global_position - (global_position - center_offset)
	if abs(position_difference.x) < _move_to_position_buffer.x and \
			abs(position_difference.y) < _move_to_position_buffer.y:
		_character.global_position = (global_position - center_offset)
		update_look_direction()
		enable()
