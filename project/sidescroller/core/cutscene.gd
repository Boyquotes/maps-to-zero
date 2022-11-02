class_name Cutscene
extends Node2D

signal finished

@export var cutscene_mode: bool = false:
	set(value):
		cutscene_mode = value
		if _is_ready:
			GameManager.cutscene_mode = value

var skipping: bool = false
var _is_ready: bool = false

func _ready():
	set_process_input(false)
	await get_tree().create_timer(1.1).timeout
	_is_ready = true

func start(_dummy_var=null) -> void:
	_is_ready = true
	assert ($AnimationPlayer.has_animation("start"))
	$AnimationPlayer.play("start")
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_cutscene"):
		skip()

func end() -> void:
	DialogUtilities.end()
	set_process_input(false)
	$AnimationPlayer.play("end")

func skip() -> void:
	skipping = true
	GameManager.screen_transition(Enums.ScreenTransition.FADE_IN, 0.3)
	await GameManager.screen_transition_finished
	await get_tree().create_timer(0.1).timeout
	end()
	await get_tree().create_timer(0.4).timeout
	GameManager.gameplay_camera.force_update_scroll()
	GameManager.gameplay_camera.reset_smoothing()
	GameManager.screen_transition(Enums.ScreenTransition.FADE_OUT, 0.3)
	finished.emit()

func enable_gameplay_current_camera(transition_time := 1.0) -> void:
	GameManager.enable_gameplay_camera_current(transition_time)


func _on_animation_finished(anim_name: String) -> void:
	if not skipping:
		if anim_name == "end":
			finished.emit()
