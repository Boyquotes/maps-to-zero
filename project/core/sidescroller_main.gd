class_name SidescrollerMain
extends Node


signal respawn_cutscene_finished


const PICK_UP = preload("res://assets/items/pick_up/pick_up_item.tscn")


@export var player_actor: PackedScene
@export var initial_stage_file_path: String
@export var initial_stage_enter_point: int


var currently_loaded_stage: Stage
var player: Character
var respawn_cutscene_playing: bool = false


@onready var actors_parent := %ActorsParent as Node2D
@onready var camera_target_position := %CameraTargetPosition as Node2D
@onready var gameplay_camera := %GameplayCamera as GameplayCamera2D
@onready var transition_camera := %TransitionCamera as Camera2D
@onready var popup_canvas := %PopupCanvas as CanvasLayer
@onready var animation_player := %AnimationPlayer as AnimationPlayer
@onready var sidescroller_hud := %SidescrollerHUD as SidescrollerHUD


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	sidescroller_hud._inventory_interface.dropped_slot_data.connect(_on_inventory_interface_dropped_slot_data)
	sidescroller_hud._inventory_interface.force_close.connect(toggle_inventory_interface)
	
	GameManager.gameplay_camera = gameplay_camera
	GameManager.transition_camera = transition_camera
	GameManager.popup_canvas = popup_canvas
	GameManager.sidescroller_main = self
	
	player = initialize_player()
	attach_camera_to_player()
	
	GameManager.request_stage_change(initial_stage_file_path, initial_stage_enter_point)


func initialize_player() -> Character:
	var player = player_actor.instantiate() as Character
	
	player.stat_changed.connect(Events._on_player_resource_changed)
	player.toggle_menu_requested.connect(toggle_menu)
	
	player.max_background_jumps = SaveData.player_data.base_max_background_jumps
	player.max_mid_air_jumps = SaveData.player_data.base_max_mid_air_jumps
	
	player.inventory_data = load("res://core/save_data/player_inventory.tres")
	player.equipment_inventory_data = load("res://core/save_data/player_equipment_inventory.tres")
	sidescroller_hud.set_player_inventory_data(player.inventory_data)
	sidescroller_hud.set_equipment_inventory_data(player.equipment_inventory_data)
	sidescroller_hud.set_hot_bar_inventory_data(player.inventory_data)
	
	GameManager.player = player
	
	actors_parent.add_child(player)
	
	return player


func attach_camera_to_player() -> void:
	camera_target_position.get_parent().remove_child(camera_target_position)
	player.add_child(camera_target_position)
	gameplay_camera.position = Vector2.ZERO


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
	
	_initialize_item_chests()
	
	if currently_loaded_stage.normal_entry:
		var entry_point: StageEntryPoint = currently_loaded_stage.entry_points[player_entry_point]
		entry_point.enter(player)
	
		if player_respawning:
			player_respawn_cutscene()
			return


func player_defeated() -> void:
	MusicManager.play(Music.Songs.SILENCE, 2.0)
	player.disable_input()
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


func toggle_menu() -> void:
	sidescroller_hud.toggle_menu()


func toggle_inventory_interface(external_inventory_owner) -> void:
	print_debug("Toggle inventory")
	sidescroller_hud.toggle_inventory_interface(external_inventory_owner)


func _input(event):
	if event.is_action_pressed("debug"):
#		SaveData.player_data = player.save_data
#		SaveData.player_saved_position = player.global_position
#		SaveData.camera_zoom = gameplay_camera.zoom
#		SaveData.stage_id = GameManager.current_stage_id
#		player.defeat()
		
		get_tree().root.mode = Window.MODE_FULLSCREEN


func player_respawn_cutscene() -> void:
#	respawn_cutscene_playing = true
#
#	ScreenEffects.cover_screen(ScreenEffectsClass.CoverAnimations.FADE_TO_BLACK, 0)
#	if MusicManager.current_song != currently_loaded_stage.song:
#		MusicManager.play(Music.Songs.SILENCE, 1.0)
#	player.global_position = SaveData.player_saved_position
#	player.save_data = SaveData.player_data
#
#	gameplay_camera.current = true
#	gameplay_camera.zoom = Vector2(99, 99)
#
#	await get_tree().create_timer(0.1).timeout
#
#	player.set_cutscene_mode(true)
#	player.play_animation("ragged_breathing")
#	GameManager.show_cutscene_bars(0)
#
#	var tween = create_tween()
#	tween.tween_property(gameplay_camera, "zoom", SaveData.camera_zoom * 3, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#
#	ScreenEffects.uncover_screen(ScreenEffectsClass.UncoverAnimations.FADE_OUT_BLACK, 0.2)
#	await ScreenEffects.uncovered_finished
#	await get_tree().create_timer(1.0).timeout
#
#	player.play_animation("focus")
#
#	tween = create_tween()
#	tween.tween_property(gameplay_camera, "zoom", SaveData.camera_zoom, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
#
#	await get_tree().create_timer(1.0).timeout
#
#	player.set_cutscene_mode(false)
#	player.play_animation("idle")
#	GameManager.hide_cutscene_bars()
#	currently_loaded_stage.start_music()
#
#	respawn_cutscene_playing = false
#	respawn_cutscene_finished.emit()
	pass


func _initialize_item_chests() -> void:
	for node in get_tree().get_nodes_in_group("item_chest_triggers"):
		node.toggle_inventory.connect(toggle_inventory_interface)


func _on_inventory_interface_dropped_slot_data(slot_data: SlotData) -> void:
	var pick_up = PICK_UP.instantiate()
	pick_up.slot_data = slot_data
	pick_up.global_position = player.get_item_drop_position()
	player.get_parent().add_child(pick_up)
