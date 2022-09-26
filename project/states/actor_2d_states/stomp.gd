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
	actor_2d.play_animation(fall_animation)


func physics_update(_delta: float) -> void:
	# Horizontal movement.
	
	# We move the run-specific input code to the state.
	var old_velocity = actor_2d.velocity
	actor_2d.velocity.x = actor_2d.speed * actor_2d.input_direction.x / 4
	if sign(actor_2d.velocity.x) != 0 \
			and sign(old_velocity.x) != sign(actor_2d.velocity.x):
		actor_2d.look_direction = Vector2(sign(actor_2d.velocity.x), 0)
	
	# Vertical movement.
	actor_2d.velocity.y = stomp_speed * GlobalVariables.TILE_SIZE.y
	
	# Landing.
	if actor_2d.is_on_floor():
		if state == AirState.FALLING:
			actor_2d.velocity.y = 0
			state = AirState.RECOVER
			actor_2d.play_animation(recover_animation)
			await get_tree().create_timer(recover_duration).timeout
			if is_equal_approx(actor_2d.velocity.x, 0.0):
				state_machine.transition_to("Idle")
			else:
				state_machine.transition_to("Run")
