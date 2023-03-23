extends CharacterState
class_name FlinchState

@export var next_state := "Idle"


var flinch: Flinch


func enter(msg := {}) -> void:
	if flinch and is_instance_valid(flinch):
		flinch.queue_free()
		flinch = null
	
	var hitbox := msg.hitbox as Hitbox
	var flinch_scene := hitbox.flinch as PackedScene
	flinch = flinch_scene.instantiate() as Flinch
	var direction := _character.global_position.direction_to(hitbox.global_position)
	_character.add_child(flinch)
	flinch.owner = _character
	flinch.enter(_character, direction)


func exit() -> void:
	if flinch and is_instance_valid(flinch):
		flinch.queue_free()
		flinch = null
