# air.gd
extends Actor2DState

enum AirState { RISE, FALL }
var state : AirState

@export var jump_off_animation := "jump"
@export var jump_animation := "jump"
@export var fall_animation := "fall"
@export var background_jump_off_animation := "background_jump"
@export var background_jump_animation := "background_jump"
@export var background_fall_animation := "background_jump"
@export var falling_gravity_multiplier := 1.7
@export var jump_buffer_time := 0.1
@export var mid_air_jumps_max := 0
@export var background_jumps_max := 0:
	get:
		if actor == GameManager.player:
			return SaveData.base_background_jumps
		else:
			return background_jumps_max

var jump_buffer_timer : Timer
var mid_air_jumps := 0
var background_jumps := 0
var background_jump_ready: bool:
	get:
		return actor.background_jump_area.has_overlapping_bodies() and background_jumps < background_jumps_max


func _ready():
	super._ready()
	jump_buffer_timer = Timer.new()
	jump_buffer_timer.one_shot = true
	add_child(jump_buffer_timer)


# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	actor.gravity = 2 * actor.jump_max_height / pow(actor.jump_max_height_time, 2) # Gravity = -2h / t^2
	
	if msg.has("do_jump"):
		var _initial_speed = 2 * actor.jump_max_height / actor.jump_max_height_time # Initial velocity = 2h / t
		actor.velocity.y = -_initial_speed
		state = AirState.RISE
	else:
		actor.gravity *= falling_gravity_multiplier
	
	if actor.velocity.y < 0:
		var animation = jump_off_animation
		if background_jump_ready:
			animation = background_jump_off_animation
		actor.play_animation(animation)
	else:
		var animation = fall_animation
		if actor.background_jump_area.has_overlapping_areas():
			animation = background_fall_animation
		actor.play_animation(animation)


func exit() -> void:
	mid_air_jumps = 0
	background_jumps = 0


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("jump"):
		if background_jump_ready:
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
			actor.velocity.y /= 3


func physics_update(delta: float) -> void:
	# Horizontal movement.
	
	# We move the run-specific input code to the state.
	var old_velocity = actor.velocity
	actor.velocity.x = actor.speed * actor.input_direction.x
	if sign(actor.velocity.x) != 0 \
			and sign(old_velocity.x) != sign(actor.velocity.x):
		actor.look_direction = Vector2(sign(actor.velocity.x), 0)
	
	# Vertical movement.
	actor.velocity.y += actor.gravity * delta
	actor.velocity.y = min(actor.velocity.y, actor.max_falling_speed)
	
	if actor.velocity.y < 0:
		if state != AirState.RISE:
			state = AirState.RISE
	else:
		if state != AirState.FALL:
			state = AirState.FALL
			actor.gravity *= falling_gravity_multiplier
	# Update animation
	
	var current_animation = actor.animation_player.current_animation
	if not background_jump_ready: # Default
		if state == AirState.RISE:
			if not(current_animation == jump_animation or current_animation == jump_off_animation or current_animation == "RESET"): 
				actor.play_animation(jump_animation)
		else:
			if not current_animation == fall_animation or current_animation == "RESET": 
				actor.play_animation(fall_animation)
	else:
		if state == AirState.RISE:
			if not(current_animation == background_jump_animation or current_animation == background_jump_off_animation or current_animation == "RESET"): 
				actor.play_animation(background_jump_animation)
		else:
			if not current_animation == background_fall_animation or current_animation == "RESET": 
				actor.play_animation(background_fall_animation)
	
	# Landing.
	if actor.is_on_floor():
		if jump_buffer_timer.time_left > 0:
			mid_air_jumps = 0
			background_jumps = 0
			enter({do_jump = true})
			return
		if is_equal_approx(actor.velocity.x, 0.0):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
