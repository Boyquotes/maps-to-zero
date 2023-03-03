# run.gd
extends CharacterState


@export var animation := "run"
@export var coyote_time := 0.1

var _coyote_timer : Timer


func _ready():
	_coyote_timer = Timer.new()
	_coyote_timer.one_shot = true
	_coyote_timer.timeout.connect(_on_coyote_timeout)
	add_child(_coyote_timer)


func enter(_msg := {}) -> void:
	_character.play_animation(animation)


func exit() -> void:
	super.exit()
	_coyote_timer.stop()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})


func physics_update(delta: float) -> void:
	# Notice how we have some code duplication between states. That's inherent to the pattern,
	# although in production, your states will tend to be more complex and duplicate code
	# much more rare.
	if not _character.is_on_floor() and _coyote_timer.time_left <= 0:
		_coyote_timer.start(coyote_time)
	
	# We move the run-specific input code to the state.
	_character.velocity.x = _character.speed * _character.input_direction.x
	_character.velocity.y += _character.gravity * delta
	
	if sign(_character.velocity.x) != 0 and sign(_character.velocity.x) != sign(_character.look_direction.x):
		_character.look_direction = Vector2(sign(_character.velocity.x), 0)
	
	if is_equal_approx(_character.input_direction.x, 0.0):
		state_machine.transition_to("Idle")


func _on_coyote_timeout():
	if not _character.is_on_floor():
		state_machine.transition_to("Air")
