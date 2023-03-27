extends Node2D
class_name EffectsAnimator


@onready var _super_armor_visuals := %SuperArmorVisuals as GPUParticles2D


func show_super_armor() -> void:
	_super_armor_visuals.emitting = true


func hide_super_armor() -> void:
	_super_armor_visuals.emitting = false
