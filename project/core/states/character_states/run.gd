# run.gd
extends CharacterState


@export var animation := "run"
@export var walk_animation := "walk"
@export var coyote_time := 0.1

var _coyote_timer : Timer

func _ready():
	_coyote_timer = Timer.new()
	_coyote_timer.one_shot = true
	_coyote_timer.timeout.connect(_on_coyote_timeout)
	add_child(_coyote_timer)


func enter(_msg := {}) -> void:
	if _character.walk_modifer_pressed:
		_character.play_animation(walk_animation)
	else:
		_character.play_animation(animation)


func exit() -> void:
	super.exit()
	_coyote_timer.stop()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})


func physics_update(delta: float) -> void:
	if not _character.is_on_floor() and _coyote_timer.time_left <= 0:
		_coyote_timer.start(coyote_time)
	
	if _character.walk_modifer_pressed:
		var speed = _character.speed / 4
		_character.play_animation(walk_animation, false)
		_character.velocity.x = speed * _character.input_direction.x
	else:
		var speed = _character.speed
		_character.play_animation(animation, false)
		_character.velocity.x = speed * _character.input_direction.x
	_character.velocity.y += _character.gravity * delta
	
	if sign(_character.velocity.x) != 0 and \
			sign(_character.velocity.x) != sign(_character.look_direction.x):
		_character.look_direction = Vector2(sign(_character.velocity.x), 0)
	
	if is_zero_approx(_character.input_direction.x):
		state_machine.transition_to("Idle")


func _on_coyote_timeout():
	if not _character.is_on_floor():
		state_machine.transition_to("Air")
