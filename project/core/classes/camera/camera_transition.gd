extends Node


@onready var transition_camera: Camera2D = $TransitionCamera

var tween : Tween
var transitioning: bool = false

func switch_camera(to) -> void:
	to.align()
	to.reset_smoothing()
	to.make_current()

func transition_camera2D(from: Camera2D, to: Camera2D, duration: float = 1.0) -> void:
	if tween:
		tween.kill()
	
	if is_zero_approx(duration):
		switch_camera(to)
		return
	
	if transitioning:
		# First finish the transition
		transition_camera.zoom = to_camera.zoom
		transition_camera.offset = to_camera.offset
		transition_camera.light_mask = to_camera.light_mask
		transition_camera.limit_bottom = to_camera.limit_bottom
		transition_camera.limit_left = to_camera.limit_left
		transition_camera.limit_right = to_camera.limit_right
		transition_camera.limit_top = to_camera.limit_top
		transition_camera.global_transform = to_camera.global_transform
	
	set_process(true)
	to_camera = to
	transition_start_time = Time.get_unix_time_from_system()
	transition_end_time = transition_start_time + duration
	transition_start_position = from.global_position
	transition_start_rotation = from.global_rotation
	transition_start_zoom = from.zoom
	
	# Copy the parameters of the first camera
	transition_camera.zoom = from.zoom
	transition_camera.offset = from.offset
	transition_camera.light_mask = from.light_mask
	transition_camera.limit_bottom = from.limit_bottom
	transition_camera.limit_left = from.limit_left
	transition_camera.limit_right = from.limit_right
	transition_camera.limit_top = from.limit_top
	
	# Move our transition camera to the first camera position
	transition_camera.global_transform = from.global_transform
	
	# Make our transition camera current
	transition_camera.make_current()
	
	transitioning = true
	
	# Move to the second camera, while also adjusting the parameters to
	# match the second camera
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(transition_camera, "offset", to.offset, duration)
	tween.tween_property(transition_camera, "limit_bottom", to.limit_bottom, duration)
	tween.tween_property(transition_camera, "limit_left", to.limit_left, duration)
	tween.tween_property(transition_camera, "limit_right", to.limit_right, duration)
	tween.tween_property(transition_camera, "limit_top", to.limit_top, duration)
	tween.finished.connect(func():
		transitioning = false
		switch_camera(to)
		)

var to_camera : Camera2D
var transition_start_time : float
var transition_end_time : float
var transition_start_position : Vector2
var transition_start_rotation : float
var transition_start_zoom : Vector2
func _process(delta):
	if not transitioning:
		set_process(false)
		return
	
	var time_elapsed = Time.get_unix_time_from_system() - transition_start_time
	var duration = transition_end_time - transition_start_time
	var lerp_step = time_elapsed / duration
	transition_camera.global_position = lerp(transition_start_position, to_camera.global_position, lerp_step)
	transition_camera.global_rotation = lerp(transition_start_rotation, to_camera.global_rotation, lerp_step)
	transition_camera.zoom = lerp(transition_start_zoom, to_camera.zoom, lerp_step)
