class_name SidescrollerMain
extends Node2D

@export var player_actor: PackedScene
@export var initial_stage_file_path: String
@export var initial_stage_enter_point: int

@onready var actors_parent := %ActorsParent
@onready var camera_transformer: RemoteTransform2D = %CameraTransformer
@onready var gameplay_camera: GameplayCamera2D = %GameplayCamera
@onready var transition_camera: Camera2D = %TransitionCamera
@onready var popup_canvas: CanvasLayer = %PopupCanvas
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sidescroller_hud : Control = $SidescrollerHUD

var currently_loaded_stage: Stage
var player: Actor2D
var respawn_cutscene_playing: bool = false
signal respawn_cutscene_finished

func _ready():
	GameManager.gameplay_camera = gameplay_camera
	GameManager.transition_camera = transition_camera
	GameManager.popup_canvas = popup_canvas
	GameManager.sidescroller_main = self
	
	player = player_actor.instantiate()
	player.get_node("Resources").resource_changed.connect(Events._on_player_resource_changed)
	GameManager.player = player
	actors_parent.add_child(player)
	camera_transformer.get_parent().remove_child(camera_transformer)
	player.add_child(camera_transformer)
	camera_transformer.position = Vector2.ZERO
	camera_transformer.remote_path = camera_transformer.get_path_to(gameplay_camera)
	
	GameManager.request_stage_change(initial_stage_file_path, initial_stage_enter_point)


func change_stage(stage_scene: PackedScene, player_entry_point: int, player_respawning: bool=false) -> void:
	if currently_loaded_stage and is_instance_valid(currently_loaded_stage):
		for actor in actors_parent.get_children():
			if actor == player:
				continue
			actor.queue_free()
		currently_loaded_stage.queue_free()
	
	currently_loaded_stage = stage_scene.instantiate()
	currently_loaded_stage.player_respawning = player_respawning
	if not player.defeated.is_connected(player_defeated):
		player.defeated.connect(player_defeated) # Connection before adding stage, in case stage does something with player defeated
	add_child(currently_loaded_stage)
	
	if currently_loaded_stage.normal_entry:
		var entry_point: StageEntryPoint = currently_loaded_stage.entry_points[player_entry_point]
		player.global_position = entry_point.global_position
		gameplay_camera.make_current()
		gameplay_camera.force_update_scroll()
	
		if player_respawning:
			player_respawn_cutscene()
			return
		GameManager.screen_transition(entry_point.transition_animation, entry_point.transition_duration)
		
		if entry_point.animation_player and entry_point.animation_player.has_animation("enter"):
			GameManager.show_cutscene_bars(0)
			entry_point.animation_player.play("enter")
			await entry_point.animation_player.animation_finished
			GameManager.hide_cutscene_bars()


func player_defeated() -> void:
	print_debug("player defeated")
	MusicManager.play_song(Music.Songs.SILENCE)
	player.input_enabled = false
	player.play_animation("defeat")
	animation_player.play("player_defeated")
	await get_tree().create_timer(1.0).timeout
	$CanvasLayer/PlayerDefeatedScreen.visible = true
	var player_defeated_yes_no_menu: YesNoMenu = $CanvasLayer/PlayerDefeatedScreen/YesNoMenu
	var yes_action = func():
		$CanvasLayer/PlayerDefeatedScreen.visible = false
		GameManager.reload()
	var no_action = func():
		$CanvasLayer/PlayerDefeatedScreen.visible = false
	player_defeated_yes_no_menu.initialize(player_defeated_yes_no_menu.message_label.text, yes_action, no_action)
	player_defeated_yes_no_menu.yes_button.grab_focus()


func _input(event):
	if event.is_action_pressed("debug"):
#		SaveData.player_data = player.save_data
#		SaveData.player_saved_position = player.global_position
#		SaveData.camera_zoom = gameplay_camera.zoom
#		SaveData.stage_id = GameManager.current_stage_id
#		player.defeat()
		
		get_tree().root.mode = Window.MODE_FULLSCREEN


func player_respawn_cutscene() -> void:
	respawn_cutscene_playing = true
	
	GameManager.screen_transition(Enums.ScreenTransition.FADE_IN, 0)
	if MusicManager.current_song != currently_loaded_stage.song:
		MusicManager.play(Music.Songs.SILENCE, 1.0)
	player.global_position = SaveData.player_saved_position
	player.save_data = SaveData.player_data
	
	gameplay_camera.current = true
	gameplay_camera.zoom = Vector2(99, 99)
	
	await get_tree().create_timer(0.1).timeout
	
	player.set_cutscene_mode(true)
	player.play_animation("ragged_breathing")
	GameManager.show_cutscene_bars(0)
	
	var tween = create_tween()
	tween.tween_property(gameplay_camera, "zoom", SaveData.camera_zoom * 3, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	GameManager.screen_transition(Enums.ScreenTransition.FADE_OUT, 0.2)
	await GameManager.screen_transition_finished
	await get_tree().create_timer(1.0).timeout
	
	player.play_animation("focus")
	
	tween = create_tween()
	tween.tween_property(gameplay_camera, "zoom", SaveData.camera_zoom, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	await get_tree().create_timer(1.0).timeout
	
	player.set_cutscene_mode(false)
	player.play_animation("idle")
	GameManager.hide_cutscene_bars()
	currently_loaded_stage.start_music()
	
	respawn_cutscene_playing = false
	respawn_cutscene_finished.emit()
