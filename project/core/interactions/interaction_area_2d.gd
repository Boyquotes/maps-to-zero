class_name InteractionArea2D
extends Area2D

signal triggered

@export var reenable_after_interaction := true
@export var scanning: bool = true:
	set(value):
		scanning = value
		monitoring = value
		if value == false:
			listening_to_input = false

var listening_to_input: bool = false:
	set(value):
		listening_to_input = value
		set_process_input(value)
		$InteractionEnabledVisuals.visible = value

var interacted : bool = false


func _input(event : InputEvent):
	if event.is_action_pressed("interact"):
		triggered.emit()
		listening_to_input = false
		interacted = true
		if not reenable_after_interaction:
			scanning = false


func _ready():
	monitoring = scanning
	monitorable = false
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(4, true)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	$InteractionEnabledVisuals.hide()


func _on_area_entered(_area: Area2D) -> void:
	listening_to_input = true

func _on_area_exited(_area: Area2D) -> void:
	listening_to_input = false
