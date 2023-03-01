class_name JumpWithSpeedStateTransition
extends StateTransition2D

@export var base_speed := 15.0 # In tiles/sec
@export var active : bool:
	set(value):
		active = value
		if value and flagged:
			jump()
var flagged : bool


func exit() -> void:
	super.exit()
	flagged = false

func handle_input(event: InputEvent) -> void:
	if event.is_action("jump"):
		if active:
			jump()
		else:
			flagged = true
			return

func jump() -> void:
	flagged = false
	actor.velocity.x = base_speed * sign(actor.velocity.x) * GameUtilities.TILE_SIZE.x
	actor.state_machine.transition_to("Air", { "do_jump": true })
