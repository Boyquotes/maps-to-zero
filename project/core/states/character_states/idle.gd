# idle.gd
extends CharacterState


@export var animation := "idle"
@export var coyote_time := 0.1


var _coyote_timer : Timer


func _ready():
	_coyote_timer = Timer.new()
	_coyote_timer.one_shot = true
	_coyote_timer.timeout.connect(_on_coyote_timeout)
	add_child(_coyote_timer)


func enter(_msg := {}) -> void:
	if not _character.is_on_floor():
		state_machine.transition_to("Air")
		return
	elif not is_equal_approx(_character.input_direction.x, 0):
		state_machine.transition_to("Run", _msg)
		return
	_character.velocity = Vector2.ZERO
	_character.play_animation(animation)


func exit() -> void:
	super.exit()
	_coyote_timer.stop()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})


func update(_delta: float) -> void:
	# If you have platforms that break when standing on them, you need that check for 
	# the character to fall.
	if not _character.is_on_floor() and _coyote_timer.time_left <= 0:
		_coyote_timer.start(coyote_time)
	if not is_zero_approx(_character.input_direction.x):
		state_machine.transition_to("Run")


func physics_update(_delta: float) -> void:
	_character.velocity.x = 0


func _on_coyote_timeout():
	if not _character.is_on_floor():
		state_machine.transition_to("Air")
