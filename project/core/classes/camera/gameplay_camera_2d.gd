class_name GameplayCamera2D
extends Camera2D

@export var get_limits_from_main:=true

var screen_shake : ScreenShakeCamera
var sway : SwayCamera
var base_zoom : Vector2
var tween : Tween

func _ready() -> void:
	set_physics_process(false)
	for child in get_children():
		if child is ScreenShakeCamera:
			screen_shake = child
		elif child is SwayCamera:
			sway = child


func add_trauma(additional_trauma := 0.1) -> void:
	if screen_shake:
		screen_shake.add_trauma(additional_trauma)


func _process(_delta):
	offset = Vector2.ZERO
	if screen_shake:
		offset += screen_shake.shake_offset
	if sway:
		offset += sway.shake_offset


func change_limits(new_limits: Dictionary, tween_duration: float) -> void:
	if is_zero_approx(tween_duration):
		limit_left = new_limits.left
		limit_top = new_limits.top
		limit_right = new_limits.right
		limit_bottom = new_limits.bottom
	else:
		var tweener = create_tween()
		tweener.tween_property(self, "limit_left", new_limits.left, tween_duration)
		tweener.tween_property(self, "limit_top", new_limits.top, tween_duration)
		tweener.tween_property(self, "limit_right", new_limits.right, tween_duration)
		tweener.tween_property(self, "limit_bottom", new_limits.bottom, tween_duration)


func change_zoom(new_zoom: Vector2, tween_duration: float, change_base_zoom : bool) -> void:
	if tween:
		tween.stop()
	tween = create_tween()
	tween.tween_property(self, "zoom", new_zoom, tween_duration) \
		.from_current().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if change_base_zoom:
		base_zoom = new_zoom

func reset_zoom(tween_duration: float = 0.2) -> void:
	if tween:
		tween.stop()
	tween = create_tween()
	tween.tween_property(self, "zoom", base_zoom, tween_duration) \
		.from_current().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func set_current(value: bool, duration := 1.0):
	var main_camera = GameUtilities.get_main_camera()
	if value:
		if not self == main_camera and get_limits_from_main:
			change_limits({
				"left": main_camera.limit_left,
				"top": main_camera.limit_top,
				"right": main_camera.limit_right,
				"bottom": main_camera.limit_bottom,
			}, 0.0)
		CameraTransition.transition_camera2D(main_camera, self, duration)
	else:
		if is_current():
			CameraTransition.transition_camera2D(self, main_camera, duration)
