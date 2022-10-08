extends Node

signal resumed

const DIALOG_BALLOON := preload("res://core/dialog/dialog_balloon.tscn")
const OVERWORLD_DIALOG_BALLOON := preload("res://core/dialog/overworld_dialog_balloon.tscn")

var calling_node: DialogNode
var dialog_balloon
var overworld_balloon


func show_dialog_balloon(caller: DialogNode, resource: Resource, title: String = "0", extra_game_states: Array = []) -> void:
	calling_node = caller
	dialog_balloon = DIALOG_BALLOON.instantiate()
	get_tree().current_scene.add_child(dialog_balloon)
	dialog_balloon.start(resource, title, extra_game_states)


func animate(animation_name: String) -> void:
	calling_node.play_animation(animation_name)
	await resumed


func resume() -> void:
	resumed.emit()


func show_overworld_dialog_balloon(resource: Resource, title: String = "0", next_line_delay := 5.0, extra_game_states: Array = []) -> void:
	if is_instance_valid(overworld_balloon):
		return
	var balloon: Node = OVERWORLD_DIALOG_BALLOON.instantiate()
	overworld_balloon = balloon
	get_tree().current_scene.add_child(balloon)
	balloon.start(resource, title, next_line_delay, extra_game_states)


func end() -> void:
	if is_instance_valid(dialog_balloon):
		dialog_balloon.queue_free()
