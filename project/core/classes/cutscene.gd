class_name Cutscene
extends Node2D

signal finished

@export var enable_character_transformers_on_start : bool = true
@export var cutscene_name: String
@export var queue_free_if_watched: bool = false
@export var show_cutscene_hud := true
@export var show_cutscene_hud_duration: float = 1.0
@export var hide_cutscene_hud_on_finish := true
@export var hide_cutscene_hud_duration: float = 1.0
@export var skippable := true

var _skipping: bool = false
var _is_ready: bool = false

@onready var _animation_player : AnimationPlayer = $AnimationPlayer


static func watched_cutscene(_cutscene_name: String) -> bool:
	return SaveData.cutscenes.has(_cutscene_name) and SaveData.cutscenes[_cutscene_name]


func _ready():
	if queue_free_if_watched and watched_cutscene(cutscene_name):
		queue_free()
		return
	
	finished.connect(_on_finished)
	set_process_input(false)
	await get_tree().create_timer(1.1).timeout
	_is_ready = true
	
	_animation_player.animation_finished.connect(_on_animation_finished)
	
	for child in get_children():
		if child is DialogTrigger:
			child.finished_and_play_animation.connect(func(anim_name):
				_animation_player.play(anim_name)
			)


func start(_dummy_var=null) -> void:
	_is_ready = true
	assert (_animation_player.has_animation("start"))
	_animation_player.play("start")
	set_process_input(true)
	
	if enable_character_transformers_on_start:
		for child in get_children():
			if child is CharacterAnimator:
				child.teleport()
				child.enable_cutscene_mode()
	
	if show_cutscene_hud:
		ScreenEffects.show_cutscene_bars(show_cutscene_hud_duration)
		GameManager.sidescroller_main.sidescroller_hud.hide_hud(show_cutscene_hud_duration)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_cutscene") and skippable and not _skipping:
		skip()


func play_end() -> void:
	_animation_player.play("end")


func skip() -> void:
	_skipping = true
	
	ScreenEffects.cover_screen(ScreenEffectsClass.CoverAnimations.FADE_TO_BLACK, 0.5)
	await ScreenEffects.cover_finished
	
	_animation_player.play("finished")
	finished.emit()
	for child in get_children():
		if child is CharacterAnimator:
			child.disable()
	
	GameUtilities.get_main_camera().align()
	GameUtilities.get_main_camera().reset_smoothing()
	ScreenEffects.uncover_screen(ScreenEffectsClass.UncoverAnimations.FADE_OUT_BLACK, 0.5)
	
	_skipping = false


func _on_animation_finished(anim_name: String) -> void:
	if not _skipping:
		if anim_name == "end":
			finished.emit()
			if _animation_player.has_animation("finished"):
				_animation_player.play("finished")
			for child in get_children():
				if child is CharacterAnimator:
					child.disable()


func _on_finished() -> void:
	SaveData.cutscenes[cutscene_name] = true
	set_process_input(false)
	
	if hide_cutscene_hud_on_finish:
		ScreenEffects.hide_cutscene_bars(hide_cutscene_hud_duration)
		GameManager.sidescroller_main.sidescroller_hud.show_hud(hide_cutscene_hud_duration)
