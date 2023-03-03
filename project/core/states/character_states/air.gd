# air.gd
extends CharacterState

enum AirState { RISE, FALL }
var state : AirState

@export var jump_animation := "jump"
@export var fall_animation := "fall"
@export var background_jump_animation := "background_jump"
@export var background_fall_animation := "background_jump"
@export var falling_gravity_multiplier := 1.5
@export var jump_buffer_time := 0.1
@export var jump_speed_boost := 0.0 # In number of tiles

var _jump_buffer_timer : Timer


func _ready():
	_jump_buffer_timer = Timer.new()
	_jump_buffer_timer.one_shot = true
	add_child(_jump_buffer_timer)


# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	_character.gravity = 2 * _character.jump_max_height / pow(_character.jump_max_height_time, 2) # Gravity = -2h / t^2
	
	if msg.has("do_jump"):
		_character.velocity.x += jump_speed_boost * GameUtilities.TILE_SIZE.x * _character.input_direction.x
		
		var _initial_speed = 2 * _character.jump_max_height / _character.jump_max_height_time # Initial velocity = 2h / t
		_character.velocity.y = -_initial_speed
		if not Input.is_action_pressed("jump"):
			_character.velocity.y /= 2
		state = AirState.RISE
		_character.play_animation_effect("jump")
	else:
		_character.gravity *= falling_gravity_multiplier
	
	if _character.velocity.y < 0:
		if can_background_jump():
			_character.play_animation(background_jump_animation)
		else:
			_character.play_animation(jump_animation)
	else:
		if can_background_jump():
			_character.play_animation(background_fall_animation)
		else:
			_character.play_animation(fall_animation)


func exit() -> void:
	reset_jumps()
	if _character.has_node("Inner/Visuals/GrindParticles"):
		_character.get_node("Inner/Visuals/GrindParticles").deactivate()


func reset_jumps() -> void:
	_character.current_mid_air_jumps = 0
	_character.current_background_jumps = 0


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("jump"):
		if _character.has_node("FloorRaycast"):
			if _character.get_node("FloorRaycast").is_colliding():
				reset_jumps()
				enter({"do_jump" = true})
				return
		if can_background_jump():
			_character.current_background_jumps += 1
			enter({"do_jump" = true})
			return
		if _character.current_mid_air_jumps < _character.max_mid_air_jumps:
			_character.current_mid_air_jumps += 1
			enter({"do_jump" = true})
			return
		
		_jump_buffer_timer.start(jump_buffer_time)
	if _event.is_action_released("jump"):
		if state == AirState.RISE:
			_character.velocity.y /= 3


func physics_update(delta: float) -> void:
	# Horizontal movement.
	_character.velocity.x = max(_character.speed, abs(_character.velocity.x)) * _character.input_direction.x
	if sign(_character.velocity.x) != 0 and sign(_character.velocity.x) != sign(_character.look_direction.x):
		_character.look_direction = Vector2(sign(_character.velocity.x), 0)
	
	# Vertical movement.
	_character.velocity.y += _character.gravity * delta
	_character.velocity.y = min(_character.velocity.y, _character.max_falling_speed)
	
	if _character.velocity.y < 0:
		if state != AirState.RISE:
			state = AirState.RISE
	else:
		if state != AirState.FALL:
			state = AirState.FALL
			_character.gravity *= falling_gravity_multiplier
	# Update animation
	
	if not can_background_jump(): # Default
		if state == AirState.RISE:
			_character.play_animation(jump_animation, false)
		else:
			_character.play_animation(fall_animation, false)
	else:
		if state == AirState.RISE:
			_character.play_animation(background_jump_animation, false)
		else:
			_character.play_animation(background_fall_animation, false)
	
	# Landing.
	if _character.is_on_floor():
		if _jump_buffer_timer.time_left > 0:
			reset_jumps()
			enter({do_jump = true})
			return
		if is_equal_approx(_character.velocity.x, 0.0):
			_character.play_animation_effect("land")
			state_machine.transition_to("Idle")
		else:
			_character.play_animation_effect("land")
			state_machine.transition_to("Run")


func can_background_jump() -> bool:
	var value = _character.current_background_jumps < _character.max_background_jumps \
			and _character.is_on_background_jump_terrain()
	if not value:
		if _character.has_node("Inner/Visuals/GrindParticles"):
			_character.get_node("Inner/Visuals/GrindParticles").deactivate()
	return value

func can_mid_air_jump() -> bool:
	return _character.current_mid_air_jumps < _character.max_mid_air_jumps
