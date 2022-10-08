extends Node2D

@export var player_actor: PackedScene
@export var initial_stage: PackedScene
@export var initial_stage_enter_point: int

@onready var actors_parent := %ActorsParent
@onready var camera_transformer: RemoteTransform2D = %CameraTransformer
@onready var gameplay_camera: Camera2D = %GameplayCamera
@onready var transition_camera: Camera2D = %TransitionCamera

var currently_loaded_stage: Stage
var player: Actor2D

func _ready():
	GameManager.gameplay_camera = gameplay_camera
	GameManager.transition_camera = transition_camera
	
	player = player_actor.instantiate()
	GameManager.player = player
	actors_parent.add_child(player)
	camera_transformer.get_parent().remove_child(camera_transformer)
	player.add_child(camera_transformer)
	camera_transformer.position = Vector2.ZERO
	camera_transformer.remote_path = camera_transformer.get_path_to(gameplay_camera)
	
	change_level(initial_stage, initial_stage_enter_point)


func change_level(stage_scene: PackedScene, player_entry_point: int) -> void:
	if currently_loaded_stage and is_instance_valid(currently_loaded_stage):
		for actor in actors_parent.get_children():
			if actor == player:
				continue
			actor.queue_free()
		currently_loaded_stage.queue_free()
	
	currently_loaded_stage = stage_scene.instantiate()
	add_child(currently_loaded_stage)
	
	var entry_point: StageEntryPoint = currently_loaded_stage.entry_points[player_entry_point]
	player.global_position = entry_point.global_position
	
	if currently_loaded_stage.normal_entry:
		GameManager.screen_transition(entry_point.transition_animation, entry_point.transition_duration)
		
		if entry_point.animation_player and entry_point.animation_player.has_animation("enter"):
			GameManager.show_cutscene_bars(0)
			entry_point.animation_player.play("enter")
			await entry_point.animation_player.animation_finished
			GameManager.hide_cutscene_bars()
