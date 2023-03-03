# air.gd
extends Actor2DState

enum AirState { RISE, FALL }
var state : AirState

@export var jump_animation := "jump"
@export var fall_animation := "fall"
@export var background_jump_animation := "background_jump"
@export var background_fall_animation := "background_jump"
@export var falling_gravity_multiplier := 1.5
@export var jump_buffer_time := 0.1
@export var mid_air_jumps_max := 0
@export var background_jumps_max := 0:
	get:
		if actor == GameManager.player:
			return SaveData.base_background_jumps
		else:
			return background_jumps_max
@export var jump_speed_boost := 0.0 # In number of tiles

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
	actor.gravity = 2 * actor.jump_max_height / pow(actor.jump_max_height_time, 2) # Gravity = -2h / t^2
	
	if msg.has("do_jump"):
		actor.velocity.x += jump_speed_boost * GameUtilities.TILE_SIZE.x * actor.input_direction.x
		
		var _initial_speed = 2 * actor.jump_max_height / actor.jump_max_height_time # Initial velocity = 2h / t
		actor.velocity.y = -_initial_speed
		if not Input.is_action_pressed("jump"):
			actor.velocity.y /= 2
		state = AirState.RISE
		if actor.animation_effects:
			actor.animation_effects.play("jump")
	else:
		actor.gravity *= falling_gravity_multiplier
	
	if actor.velocity.y < 0:
		if can_background_jump():
			actor.play_animation(background_jump_animation)
		else:
			actor.play_animation(jump_animation)
	else:
		if can_background_jump():
			actor.play_animation(background_fall_animation)
		else:
			actor.play_animation(fall_animation)


func exit() -> void:
	reset_jumps()
	if actor.has_node("Inner/Visuals/GrindParticles"):
		actor.get_node("Inner/Visuals/GrindParticles").deactivate()


func reset_jumps() -> void:
	mid_air_jumps = 0
	background_jumps = 0


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("jump"):
		if actor.has_node("FloorRaycast"):
			if actor.get_node("FloorRaycast").is_colliding():
				reset_jumps()
				enter({"do_jump" = true})
				return
		if can_background_jump():
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
	actor.velocity.x = max(actor.speed, abs(actor.velocity.x)) * actor.input_direction.x
	if sign(actor.velocity.x) != 0 and sign(actor.velocity.x) != sign(actor.look_direction.x):
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
	if not can_background_jump(): # Default
		if state == AirState.RISE:
			if not(current_animation == jump_animation or current_animation == "RESET"): 
				actor.play_animation(jump_animation)
		else:
			if not current_animation == fall_animation or current_animation == "RESET": 
				actor.play_animation(fall_animation)
	else:
		if state == AirState.RISE:
			if not(current_animation == background_jump_animation or current_animation == "RESET"): 
				actor.play_animation(background_jump_animation)
		else:
			if not current_animation == background_fall_animation or current_animation == "RESET": 
				actor.play_animation(background_fall_animation)
	
	# Landing.
	if actor.is_on_floor():
		if jump_buffer_timer.time_left > 0:
			reset_jumps()
			enter({do_jump = true})
			return
		if is_equal_approx(actor.velocity.x, 0.0):
			if actor.animation_effects:
				actor.animation_effects.play("land")
			state_machine.transition_to("Idle")
		else:
			if actor.animation_effects:
				actor.animation_effects.play("land")
			state_machine.transition_to("Run")


func can_background_jump() -> bool:
	var value = background_jumps < background_jumps_max and (actor.background_jump_area.has_overlapping_bodies() \
				or actor.background_jump_area.has_overlapping_areas())
	if not value:
		if actor.has_node("Inner/Visuals/GrindParticles"):
			actor.get_node("Inner/Visuals/GrindParticles").deactivate()
	return value

func can_mid_air_jump() -> bool:
	return mid_air_jumps < mid_air_jumps_max
