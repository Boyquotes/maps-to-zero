# air.gd
extends Actor2DState

enum AirState { FALLING, RECOVER }
var state : AirState

@export var fall_animation := "stomp"
@export var recover_animation := "stomp_recover"
@export var stomp_speed := 150.0 # In tiles/second
@export var recover_duration := 0.2


func enter(_msg := {}) -> void:
	state = AirState.FALLING
	actor.play_animation(fall_animation)


func physics_update(_delta: float) -> void:
	# Horizontal movement.
	
	# We move the run-specific input code to the state.
	var old_velocity = actor.velocity
	actor.velocity.x = actor.speed * actor.input_direction.x / 4
	if sign(actor.velocity.x) != 0 \
			and sign(old_velocity.x) != sign(actor.velocity.x):
		actor.look_direction = Vector2(sign(actor.velocity.x), 0)
	
	# Vertical movement.
	actor.velocity.y = stomp_speed * GlobalVariables.TILE_SIZE.y
	
	# Landing.
	if actor.is_on_floor():
		if state == AirState.FALLING:
			actor.velocity.y = 0
			state = AirState.RECOVER
			actor.play_animation(recover_animation)
			await get_tree().create_timer(recover_duration).timeout
			if is_equal_approx(actor.velocity.x, 0.0):
				state_machine.transition_to("Idle")
			else:
				state_machine.transition_to("Run")
