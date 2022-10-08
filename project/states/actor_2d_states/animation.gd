extends Actor2DState
class_name AnimationState


@export var finished_to_state := "Idle"

@onready var actor_transformer: Marker2D = $Actor2dTransformer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var enter_position: Vector2


func _ready():
	super._ready()
	animation_player.animation_finished.connect(_on_animation_finished)

func play_animation(animation_name: String):
	actor.play_animation(animation_name)

func enter(msg := {}) -> void:
	super.enter(msg)
	actor.velocity = Vector2.ZERO
	animation_player.play("enter")
	
	enter_position = actor.position


func exit() -> void:
	super.exit()
	animation_player.play("RESET")


func _on_animation_finished(animation_name) -> void:
	if animation_name == "RESET":
		return
	state_machine.transition_to(finished_to_state)
