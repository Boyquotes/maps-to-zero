extends Node2D

@export var player_actor: PackedScene
@export var initial_stage: PackedScene
@export var initial_stage_enter_point: int

@onready var actors_parent := %ActorsParent
@onready var camera_transformer: RemoteTransform2D = %CameraTransformer
@onready var gameplay_camera: Camera2D = %GameplayCamera
@onready var transition_camera: Camera2D = %TransitionCamera
@onready var popup_canvas: CanvasLayer = %PopupCanvas
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var currently_loaded_stage: Stage
var player: Actor2D

func _ready():
	GameManager.gameplay_camera = gameplay_camera
	GameManager.transition_camera = transition_camera
	GameManager.popup_canvas = popup_canvas
	GameManager._sidescroller_main = self
	
	player = player_actor.instantiate()
	GameManager.player = player
	actors_parent.add_child(player)
	camera_transformer.get_parent().remove_child(camera_transformer)
	player.add_child(camera_transformer)
	camera_transformer.position = Vector2.ZERO
	camera_transformer.remote_path = camera_transformer.get_path_to(gameplay_camera)
	
	change_stage(initial_stage, initial_stage_enter_point)


func change_stage(stage_scene: PackedScene, player_entry_point: int, player_respawning: bool=false) -> void:
	if currently_loaded_stage and is_instance_valid(currently_loaded_stage):
		for actor in actors_parent.get_children():
			if actor == player:
				continue
			actor.queue_free()
		currently_loaded_stage.queue_free()
	
	currently_loaded_stage = stage_scene.instantiate()
	currently_loaded_stage.player_respawning = player_respawning
	add_child(currently_loaded_stage)
	
	var entry_point: StageEntryPoint = currently_loaded_stage.entry_points[player_entry_point]
	player.global_position = entry_point.global_position
	
	if player_respawning:
		GameManager.screen_transition(Enums.ScreenTransition.FADE_OUT, 0)
		if MusicManager.current_song != currently_loaded_stage.song:
			MusicManager.play(Music.Songs.SILENCE, 1.0)
		player.global_position = SaveData.player_saved_position
		player.save_data = SaveData.player_data
		await get_tree().create_timer(0.1).timeout
		player.cutscene_mode = true
		player.play_animation("ragged_breathing")
		GameManager.show_cutscene_bars(0)
		GameManager.screen_transition(Enums.ScreenTransition.FADE_OUT, 0.2)
		await GameManager.screen_transition_finished
		await get_tree().create_timer(1.0).timeout
		player.play_animation("focus")
		await get_tree().create_timer(1.0).timeout
		player.play_animation("idle")
		player.cutscene_mode = false
		GameManager.hide_cutscene_bars()
		currently_loaded_stage.start_music()
	elif currently_loaded_stage.normal_entry:
		GameManager.screen_transition(entry_point.transition_animation, entry_point.transition_duration)
		
		if entry_point.animation_player and entry_point.animation_player.has_animation("enter"):
			GameManager.show_cutscene_bars(0)
			entry_point.animation_player.play("enter")
			await entry_point.animation_player.animation_finished
			GameManager.hide_cutscene_bars()


func player_defeated() -> void:
	animation_player.play("player_defeated")
	var player_defeated_yes_no_menu: YesNoMenu = $CanvasLayer/PlayerDefeatedScreen/YesNoMenu
	var yes_action = func():
		GameManager.reload()
	var no_action = func():
		pass
	player_defeated_yes_no_menu.initialize(player_defeated_yes_no_menu.message_label.text, yes_action, no_action)


func _input(event):
	if event.is_action_pressed("debug"):
		SaveData.player_data = player.save_data
		SaveData.player_saved_position = player.global_position
		GameManager.reload()
