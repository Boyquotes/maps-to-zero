extends Node2D
class_name Flinch


signal finished


@onready var _character_animator := %CharacterAnimator as CharacterAnimator
@onready var _animation_player := %AnimationPlayer as AnimationPlayer


func enter(character: Character, look_direction: Vector2) -> void:
	_animation_player.play("animation")
	_character_animator._character = character
	_character_animator.owner = character
	_character_animator.set_look_direction(look_direction)
	_character_animator.enable()
	await _animation_player.animation_finished
	_character_animator.disable()
	finished.emit()
	queue_free()
