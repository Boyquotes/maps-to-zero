class_name Interactable
extends Node2D


var interactions: Array
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
	for child in $Interactions.get_children():
		assert(child is Interaction)
		interactions.append(child)


func trigger(_dummy=null):
	for interaction in interactions:
		interaction.trigger()
