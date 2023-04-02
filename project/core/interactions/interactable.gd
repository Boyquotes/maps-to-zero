class_name Interactable
extends Node2D


@onready var _triggers_node := %Triggers
@onready var _requirements_node := %Requirements
@onready var _interaction_area := %InteractionArea2D as InteractionArea2D

var is_ready : bool:
	get:
		if $Requirements.get_child_count() == 0:
			return true
		else:
			for requirement in $Requirements.get_children():
				if not requirement.is_ready:
					return false
			return true


func _ready() -> void:
	_interaction_area.triggered.connect(trigger)


func trigger(_dummy=null):
	for trigger in _triggers_node.get_children():
		assert(trigger is Trigger)
		trigger.trigger()
