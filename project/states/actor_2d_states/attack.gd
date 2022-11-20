# attack.gd
extends Actor2DState

signal first_hit_confirmed
signal hit_confirmed


enum AirState { RISE, FALL }
var state : AirState

@export var next_state := "Idle"

var _first_confirmed_hit : bool


func _ready():
	super._ready()
	await owner.ready
	if actor.inner.has_node("Attacks/" + str(name) + "/AnimationPlayer"):
		var attack_node = actor.inner.get_node("Attacks/" + str(name))
		attack_node.get_node("AnimationPlayer").animation_finished.connect(attack_animation_finished)
		for child in attack_node.get_children():
			if child is Hitbox:
				child.hit.connect(_on_attack_hit)
		

func enter(msg := {}) -> void:
	super.enter(msg)
	
	if actor.inner.has_node("Attacks/" + str(name) + "/AnimationPlayer"):
		actor.inner.get_node("Attacks/" + str(name) + "/AnimationPlayer").play("attack")
	else:
		state_machine.transition_to(next_state)
	
	_first_confirmed_hit = false


func exit() -> void:
	super.exit()
	if actor.inner.has_node("Attacks/" + str(name) + "/AnimationPlayer"):
		actor.inner.get_node("Attacks/" + str(name) + "/AnimationPlayer").play("RESET")


func attack_animation_finished(anim_name: String) -> void:
	if anim_name != "RESET":
		actor.inner.get_node("Attacks/" + str(name) + "/AnimationPlayer").play("RESET")
		state_machine.transition_to(next_state)


func _on_attack_hit(actor) -> void:
	if not _first_confirmed_hit:
		_first_confirmed_hit = true
		first_hit_confirmed.emit()
	hit_confirmed.emit()
