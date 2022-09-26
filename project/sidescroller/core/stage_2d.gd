extends Node2D


@export var song : Music.Songs

@onready var stage_enter_triggers := $StageEnterTriggers

func _ready():
	# First handle any stage enter triggers
	for trigger in stage_enter_triggers.get_children():
		if trigger.is_ready:
			trigger.trigger()
			return # Return, prioritize the first triggers over later ones
	
	# If no special triggers needs to be triggered, play stage as normal
	start_gameplay()


func start_gameplay() -> void:
	MusicManager.play(song)
