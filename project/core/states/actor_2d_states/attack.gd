# attack.gd
extends Actor2DState


signal first_hit_confirmed
signal hit_confirmed


@export var next_state := "Idle"

var _first_confirmed_hit : bool
var _attack_node
var _attack_node_animation_player: AnimationPlayer



func init(character: Actor2D) -> void:
	super.init(character)
	_attack_node = character.inner.get_node("Attacks/" + str(name))
	if character.inner.has_node("Attacks/" + str(name) + "/AnimationPlayer"):
		_attack_node_animation_player = _attack_node.get_node("AnimationPlayer")
		_attack_node_animation_player.animation_finished.connect(attack_animation_finished)
		for child in _attack_node.get_children():
			if child is Hitbox:
				child.hit.connect(_on_attack_hit)


func enter(msg := {}) -> void:
	super.enter(msg)
	
	for child in _attack_node.get_children():
		if child is CharacterAnimator:
			child.enable(false)
	
	if _attack_node_animation_player:
		_attack_node_animation_player.play("attack")
	else:
		state_machine.transition_to(next_state)
	
	_first_confirmed_hit = false


func exit() -> void:
	for child in _attack_node.get_children():
		if child is CharacterAnimator:
			child.disable(false)
	super.exit()
	if _attack_node_animation_player:
		_attack_node_animation_player.play("RESET")


func attack_animation_finished(anim_name: String) -> void:
	if not anim_name == "RESET":
		_attack_node_animation_player.play("RESET")
		state_machine.transition_to(next_state)


func _on_attack_hit(actor) -> void:
	if not _first_confirmed_hit:
		_first_confirmed_hit = true
		first_hit_confirmed.emit()
	hit_confirmed.emit()
