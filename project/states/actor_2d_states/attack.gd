# attack.gd
extends Actor2DState

enum AirState { RISE, FALL }
var state : AirState

@export var next_state := "Idle"


func _ready():
	super._ready()
	await owner.ready
	if actor.inner.has_node("Attacks/" + str(name) + "/AnimationPlayer"):
		actor.inner.get_node("Attacks/" + str(name) + "/AnimationPlayer").animation_finished.connect(attack_animation_finished)


func enter(msg := {}) -> void:
	super.enter(msg)
	
	if actor.inner.has_node("Attacks/" + str(name) + "/AnimationPlayer"):
		actor.inner.get_node("Attacks/" + str(name) + "/AnimationPlayer").play("attack")
	else:
		state_machine.transition_to(next_state)


func exit() -> void:
	super.exit()
	if actor.inner.has_node("Attacks/" + str(name) + "/AnimationPlayer"):
		actor.inner.get_node("Attacks/" + str(name) + "/AnimationPlayer").play("RESET")


func attack_animation_finished(anim_name: String) -> void:
	if anim_name != "RESET":
		actor.inner.get_node("Attacks/" + str(name) + "/AnimationPlayer").play("RESET")
		state_machine.transition_to(next_state)
