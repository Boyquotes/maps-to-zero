class_name Cutscene
extends Node2D

signal finished

@export var cutscene_mode: bool = false:
	set(value):
		cutscene_mode = value
		if _is_ready:
			GameManager.cutscene_mode = value
@export var enable_character_transformers_on_start : bool = true

@onready var animation_player : AnimationPlayer = $AnimationPlayer

var skipping: bool = false
var _is_ready: bool = false

func _ready():
	finished.connect(_on_finished)
	set_process_input(false)
	await get_tree().create_timer(1.1).timeout
	_is_ready = true
	
	animation_player.animation_finished.connect(_on_animation_finished)
	
	for child in get_children():
		if child is DialogTrigger:
			child.finished_and_play_animation.connect(func(anim_name):
				animation_player.play(anim_name)
			)

func start(_dummy_var=null) -> void:
	_is_ready = true
	assert (animation_player.has_animation("start"))
	animation_player.play("start")
	set_process_input(true)
	
	if enable_character_transformers_on_start:
		for child in get_children():
			if child is ActorCutsceneTransformer:
				child.teleport()
				child.enable()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_cutscene") and not skipping:
		skip()

func play_end() -> void:
	animation_player.play("end")

func skip() -> void:
	skipping = true
	
	ScreenEffects.screen_transition(ScreenEffectsClass.ScreenTransitions.FADE_IN, 0.3)
	await ScreenEffects.screen_transition_finished
	await get_tree().create_timer(0.5).timeout
	
	animation_player.play("finished")
	finished.emit()
	for child in get_children():
		if child is ActorCutsceneTransformer:
			child.disable()
			
	GameUtilities.get_main_camera().align()
	GameUtilities.get_main_camera().reset_smoothing()
	ScreenEffects.screen_transition(ScreenEffectsClass.ScreenTransitions.FADE_OUT, 0.3)
	
	skipping = false

func _on_animation_finished(anim_name: String) -> void:
	if not skipping:
		if anim_name == "end":
			finished.emit()
			if animation_player.has_animation("finished"):
				animation_player.play("finished")
			for child in get_children():
				if child is ActorCutsceneTransformer:
					child.disable()


func _on_finished() -> void:
	set_process_input(false)
