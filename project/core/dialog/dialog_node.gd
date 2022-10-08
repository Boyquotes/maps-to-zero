class_name DialogNode
extends Node

@export var dialog: Resource
@export var title := "start"
@export var animation_player_node_path: NodePath

var current_animation: String
var animation_player: AnimationPlayer

func _ready():
	if animation_player_node_path != null:
		animation_player = get_node(animation_player_node_path)
		animation_player.animation_finished.connect(_on_animation_finished)

func start() -> void:
	DialogUtilities.show_dialog_balloon(self, dialog, title)


func play_animation(animation_name: String) -> void:
	current_animation = animation_name
	if animation_player:
		animation_player.play(animation_name)


func resume() -> void:
	current_animation = ""
	DialogUtilities.resume()


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == current_animation:
		resume()
