extends Node2D
class_name DialogInteraction

signal finished

@export var timeline : Resource
@export var switch_camera := true
@export var camera_transition_time := 1.0

@onready var _player_animator := %PlayerAnimator as CharacterAnimator
@onready var _camera := %Camera as GameplayCamera2D
@onready var _interaction_area := %InteractionArea2D as InteractionArea2D

var _dialog_trigger : DialogTrigger

func _ready():
	_dialog_trigger = DialogTrigger.new()
	_dialog_trigger.timeline = timeline
	_dialog_trigger.finished.connect(_on_dialog_finished)
	add_child(_dialog_trigger)
	
	_interaction_area.triggered.connect(_on_interaction_area_triggered)


func trigger() -> void:
	_dialog_trigger.trigger()


func _on_interaction_area_triggered():
	if switch_camera:
		_switch_to_camera()
	_disable_player_input()
	trigger()


func _on_dialog_finished() -> void:
	if switch_camera:
		_camera.set_current(false, camera_transition_time)
	_player_animator.enable_input()
	finished.emit()


func _switch_to_camera() -> void:
	_camera.set_current(true, camera_transition_time)


func _disable_player_input() -> void:
	_player_animator.reset_speed()
	_player_animator.look_towards_position()
	_player_animator.play_animation()
	_player_animator.disable_input()
