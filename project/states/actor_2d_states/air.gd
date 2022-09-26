# air.gd
extends Actor2DState

enum AirState { RISE, FALL }
var state : AirState

@export var jump_animation := "jump"
@export var fall_animation := "fall"
@export var background_jump_animation := "background_jump"
@export var background_fall_animation := "background_jump"
@export var falling_gravity_multiplier := 1.7
@export var jump_buffer_time := 0.1
@export var mid_air_jumps_max := 0
@export var background_jumps_max := 0

var jump_buffer_timer : Timer
var mid_air_jumps := 0
var background_jumps := 0


func _ready():
	super._ready()
	jump_buffer_timer = Timer.new()
	jump_buffer_timer.one_shot = true
	add_child(jump_buffer_timer)


# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	actor_2d.gravity = 2 * actor_2d.jump_max_height / pow(actor_2d.jump_max_height_time, 2) # Gravity = -2h / t^2
	
	if msg.has("do_jump"):
		var _initial_speed = 2 * actor_2d.jump_max_height / actor_2d.jump_max_height_time # Initial velocity = 2h / t
		actor_2d.velocity.y = -_initial_speed
		state = AirState.RISE
	else:
		actor_2d.gravity *= falling_gravity_multiplier
	
	if actor_2d.velocity.y < 0:
		var animation = background_jump_animation if actor_2d.background_jump_area.has_overlapping_bodies() else jump_animation
		actor_2d.play_animation(animation)
	else:
		var animation = background_fall_animation if actor_2d.background_jump_area.has_overlapping_bodies() else fall_animation
		actor_2d.play_animation(animation)


func exit() -> void:
	mid_air_jumps = 0
	background_jumps = 0


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("jump"):
		if actor_2d.background_jump_area.has_overlapping_bodies() and background_jumps < background_jumps_max:
			background_jumps += 1
			enter({"do_jump" = true})
			return
		if mid_air_jumps < mid_air_jumps_max:
			mid_air_jumps += 1
			enter({"do_jump" = true})
			return
		
		jump_buffer_timer.start(jump_buffer_time)
	if _event.is_action_released("jump"):
		if state == AirState.RISE:
			actor_2d.velocity.y /= 3


func physics_update(delta: float) -> void:
	# Horizontal movement.
	
	# We move the run-specific input code to the state.
	var old_velocity = actor_2d.velocity
	actor_2d.velocity.x = actor_2d.speed * actor_2d.input_direction.x
	if sign(actor_2d.velocity.x) != 0 \
			and sign(old_velocity.x) != sign(actor_2d.velocity.x):
		actor_2d.look_direction = Vector2(sign(actor_2d.velocity.x), 0)
	
	# Vertical movement.
	actor_2d.velocity.y += actor_2d.gravity * delta
	actor_2d.velocity.y = min(actor_2d.velocity.y, actor_2d.max_falling_speed)
	
	# Update animation
	if actor_2d.velocity.y < 0:
		if state != AirState.RISE:
			var animation = background_jump_animation if actor_2d.background_jump_area.has_overlapping_bodies() else jump_animation
			actor_2d.play_animation(animation)
			state = AirState.RISE
	else:
		if state != AirState.FALL:
			var animation = background_fall_animation if actor_2d.background_jump_area.has_overlapping_bodies() else fall_animation
			actor_2d.play_animation(animation)
			state = AirState.FALL
			actor_2d.gravity *= falling_gravity_multiplier
	
	# Landing.
	if actor_2d.is_on_floor():
		if jump_buffer_timer.time_left > 0:
			mid_air_jumps = 0
			background_jumps = 0
			enter({do_jump = true})
			return
		if is_equal_approx(actor_2d.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
