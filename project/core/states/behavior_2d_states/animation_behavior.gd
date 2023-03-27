extends Behavior2DScript

@export var finished_to_state := "Idle"

var _enter_position: Vector2
@onready var _animation_player: AnimationPlayer = $AnimationPlayer



func _ready():
	_animation_player.animation_finished.connect(_on_animation_finished)


func play_animation(animation_name: String):
	_character.play_animation(animation_name)


func enter(msg := {}) -> void:
	super.enter(msg)
	_character.velocity = Vector2.ZERO
	_animation_player.play("enter")
	
	_enter_position = _character.position


func exit() -> void:
	super.exit()
	_animation_player.play("RESET")


func get_input_direction() -> Vector2:
	return Vector2.ZERO


func face_target() -> void:
	_character.face_target()


func _on_animation_finished(animation_name) -> void:
	if animation_name == "RESET":
		return
	state_machine.transition_to(finished_to_state)
