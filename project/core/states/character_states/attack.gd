## attack.gd
class_name AttackState
extends CharacterState


signal first_hit_confirmed
signal hit_confirmed


@export var next_state := "Idle"

var _first_confirmed_hit : bool
var _attack_node
var _attack_node_animation_player: AnimationPlayer
var _character_animator: CharacterAnimator


func init(character: Character) -> void:
	super.init(character)
	_attack_node = character.get_attack(name) as Node2D
	if _attack_node:
		for child in _attack_node.get_children():
			if child is Hitbox:
				child.hit.connect(_on_attack_hit)
		
		_attack_node_animation_player = _attack_node.get_node("AnimationPlayer") as AnimationPlayer
		if _attack_node_animation_player:
			_attack_node_animation_player.animation_finished.connect(attack_animation_finished)
		
		for child in Utilities.get_all_children(_attack_node):
			if child is CharacterAnimator:
				_character_animator = child
				break


func enter(msg := {}) -> void:
	super.enter(msg)
	
	if _character_animator:
		_character_animator.enable(false)
	
	if _attack_node_animation_player:
		if _attack_node_animation_player.has_animation("attack_windup"):
			_attack_node_animation_player.play("attack_windup")
		else:
			_attack_node_animation_player.play("attack")
	else:
		state_machine.transition_to(next_state)
	
	_first_confirmed_hit = false


func exit() -> void:
	if _character_animator:
		_character_animator.disable(false)
	
	super.exit()
	if _attack_node_animation_player:
		_attack_node_animation_player.play("RESET")


func attack_animation_finished(anim_name: String) -> void:
	if anim_name == "attack_windup":
		_attack_node_animation_player.play("attack")
		return
	
	if not anim_name == "RESET":
		_attack_node_animation_player.play("RESET")
		state_machine.transition_to(next_state)


func _on_attack_hit(_hit_character: Character) -> void:
	if not _first_confirmed_hit:
		_first_confirmed_hit = true
		first_hit_confirmed.emit()
	hit_confirmed.emit()
