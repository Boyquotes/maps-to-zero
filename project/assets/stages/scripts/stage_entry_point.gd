class_name StageEntryPoint
extends Node2D

@export var transition_animation: ScreenEffectsClass.ScreenTransition
@export var transition_duration := 1.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null
