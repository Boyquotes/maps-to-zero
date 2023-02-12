class_name GameplayCamera2D
extends Camera2D

var screen_shake : ScreenShakeCamera
var sway : SwayCamera
var base_zoom : Vector2
var tween : Tween

func _ready() -> void:
	for child in get_children():
		if child is ScreenShakeCamera:
			screen_shake = child
		elif child is SwayCamera:
			sway = child


func add_trauma(additional_trauma := 0.1) -> void:
	if screen_shake:
		screen_shake.add_trauma(additional_trauma)


func _process(delta):
	offset = Vector2.ZERO
	if screen_shake:
		offset += screen_shake.shake_offset
	if sway:
		offset += sway.shake_offset


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
