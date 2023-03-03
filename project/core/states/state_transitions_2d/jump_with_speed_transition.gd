class_name JumpWithSpeedStateTransition
extends StateTransition2D

@export var base_speed := 15.0 # In tiles/sec
@export var active : bool:
	set(value):
		active = value
		if value and _flagged:
			jump()


var _flagged : bool


func exit() -> void:
	super.exit()
	_flagged = false

func handle_input(event: InputEvent) -> void:
	if event.is_action("jump"):
		if active:
			jump()
		else:
			_flagged = true
			return

func jump() -> void:
	_flagged = false
	_character.velocity.x = base_speed * sign(_character.velocity.x) * GameUtilities.TILE_SIZE.x
	_character.state_machine.transition_to("Air", { "do_jump": true })
