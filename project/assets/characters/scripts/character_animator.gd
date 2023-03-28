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
			if _character:
				_character.play_animation(animation)
@export var attack_input_listening : bool:
	set(value):
		attack_input_listening = value
#		if not _movement_mode == MovementModes.DISABLED:
#			_character.attack_input_listening = attack_input_listening
@export var can_cancel_out_of_attack : bool:
	set(value):
		can_cancel_out_of_attack = value
		if not _movement_mode == MovementModes.DISABLED:
			_character.set_can_cancel_attack(can_cancel_out_of_attack)
@export var can_go_to_next_attack : bool:
	set(value):
		can_go_to_next_attack = value
		if not _movement_mode == MovementModes.DISABLED:
			_character.attack_can_go_to_next = can_go_to_next_attack


var _last_frame_position : Vector2
var _character: Character:
	get:
		if _character:
			return _character as Character
		if Engine.is_editor_hint():
			if get_child_count() == 1 and get_child(0) is Character:
				_character = get_child(0)
			elif owner is Character:
				_character = owner
			return _character as Character
		if actor_name == "" and owner is Character:
			_character = owner
		elif actor_name == "PLAYER":
			_character = GameManager.player
		elif get_child_count() == 1 and get_child(0) is Character:
			_character = get_child(0)
		else:
			if GameManager.actors.has(actor_name):
				_character = GameManager.actors[actor_name]
		return _character as Character
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


func enable() -> void:
	_movement_mode = MovementModes.MATCH
	set_physics_process(true)
	_last_frame_position = position - center_offset
	_character.play_animation(animation)


func enable_cutscene_mode() -> void:
	_character.disable_input()
	_character.state_machine.transition_to("Cutscene")
	enable()


func disable_cutscene_mode() -> void:
	_character.enable_input()
	disable()


func disable() -> void:
	disable_without_resetting_state()
	_character.state_machine.reset()


func disable_without_resetting_state() -> void:
	_movement_mode = MovementModes.DISABLED
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


func play_animation(_animation:="") -> void:
	if _animation == "":
		_character.play_animation(animation)
	else:
		_character.play_animation(_animation)


func move_right() -> void:
	_movement_mode = MovementModes.MOVE_RIGHT
	_character.input_state_machine.transition_to("MoveDirection", {
		"direction": Vector2.RIGHT
	})
	set_physics_process(false)


func move_left() -> void:
	_movement_mode = MovementModes.MOVE_LEFT
	_character.input_state_machine.transition_to("MoveDirection", {
		"direction": Vector2.LEFT
	})
	set_physics_process(false)


func look_towards_position() -> void:
	_character.look_direction = Vector2(
		sign(_character.global_position.direction_to(global_position).x), 0)


func set_look_direction(target_direction: Vector2) -> void:
	if sign(target_direction.x) > 0:
		look_direction = 0
	elif sign(target_direction.x) < 0:
		look_direction = 1


func face_target() -> void:
	_character.face_target()


func _move_character_to_global_position() -> void:
	var move_to_position_state = _character.input_state_machine.get_state("MoveToPosition")
	move_to_position_state.target_global_position = global_position
	var position_difference = _character.global_position - (global_position - center_offset)
	if abs(position_difference.x) < _move_to_position_buffer.x and \
			abs(position_difference.y) < _move_to_position_buffer.y:
		_character.global_position = (global_position - center_offset)
		update_look_direction()
		enable()
