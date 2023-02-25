extends Node


@onready var camera2D: Camera2D = $Camera2D

var tween : Tween
var transitioning: bool = false

func switch_camera(to) -> void:
	to.align()
	to.reset_smoothing()
	to.make_current()

func transition_camera2D(from: Camera2D, to: Camera2D, duration: float = 1.0) -> void:
	if is_zero_approx(duration):
		switch_camera(to)
		return
	
	if transitioning:
		# First finish the transition
		camera2D.zoom = to_camera.zoom
		camera2D.offset = to_camera.offset
		camera2D.light_mask = to_camera.light_mask
		camera2D.limit_bottom = to_camera.limit_bottom
		camera2D.limit_left = to_camera.limit_left
		camera2D.limit_right = to_camera.limit_right
		camera2D.limit_top = to_camera.limit_top
		camera2D.global_transform = to_camera.global_transform
	
	set_process(true)
	to_camera = to
	transition_start_time = Time.get_unix_time_from_system()
	transition_end_time = transition_start_time + duration
	transition_start_position = from.global_position
	transition_start_rotation = from.global_rotation
	
	# Copy the parameters of the first camera
	camera2D.zoom = from.zoom
	camera2D.offset = from.offset
	camera2D.light_mask = from.light_mask
	camera2D.limit_bottom = from.limit_bottom
	camera2D.limit_left = from.limit_left
	camera2D.limit_right = from.limit_right
	camera2D.limit_top = from.limit_top
	
	# Move our transition camera to the first camera position
	camera2D.global_transform = from.global_transform
	
	# Make our transition camera current
	camera2D.make_current()
	
	transitioning = true
	
	# Move to the second camera, while also adjusting the parameters to
	# match the second camera
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(camera2D, "zoom", to.zoom, duration)
	tween.tween_property(camera2D, "offset", to.offset, duration)
	tween.tween_property(camera2D, "limit_bottom", to.limit_bottom, duration)
	tween.tween_property(camera2D, "limit_left", to.limit_left, duration)
	tween.tween_property(camera2D, "limit_right", to.limit_right, duration)
	tween.tween_property(camera2D, "limit_top", to.limit_top, duration)
	
	# Wait for the tween to complete
	await tween.finished
	
	# Make the second camera current
	switch_camera(to)
	transitioning = false


var to_camera : Camera2D
var transition_start_time : float
var transition_end_time : float
var transition_start_position : Vector2
var transition_start_rotation : float
func _process(delta):
	if not transitioning:
		set_process(false)
		return
	
	var time_elapsed = Time.get_unix_time_from_system() - transition_start_time
	var duration = transition_end_time - transition_start_time
	camera2D.global_position = lerp(transition_start_position, to_camera.global_position, time_elapsed / duration)
	camera2D.global_rotation = lerp(transition_start_rotation, to_camera.global_rotation, time_elapsed / duration)
