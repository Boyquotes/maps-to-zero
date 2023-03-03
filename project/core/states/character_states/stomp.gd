# air.gd
extends CharacterState

enum AirState { FALLING, RECOVER }

@export var fall_animation := "stomp"
@export var recover_animation := "stomp_recover"
@export var stomp_speed := 150.0 # In tiles/second
@export var recover_duration := 0.2


var state : AirState


func enter(_msg := {}) -> void:
	state = AirState.FALLING
	_character.play_animation(fall_animation)


func physics_update(_delta: float) -> void:
	# Horizontal movement.
	
	# We move the run-specific input code to the state.
	var old_velocity = _character.velocity
	_character.velocity.x = _character.speed * _character.input_direction.x / 4
	if sign(_character.velocity.x) != 0 \
			and sign(old_velocity.x) != sign(_character.velocity.x):
		_character.look_direction = Vector2(sign(_character.velocity.x), 0)
	
	# Vertical movement.
	_character.velocity.y = stomp_speed * GameUtilities.TILE_SIZE.y
	
	# Landing.
	if _character.is_on_floor():
		if state == AirState.FALLING:
			_character.velocity.y = 0
			state = AirState.RECOVER
			_character.play_animation(recover_animation)
			await get_tree().create_timer(recover_duration).timeout
			if is_equal_approx(_character.velocity.x, 0.0):
				state_machine.transition_to("Idle")
			else:
				state_machine.transition_to("Run")
