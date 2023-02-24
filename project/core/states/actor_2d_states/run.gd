# run.gd
extends Actor2DState


@export var animation := "run"
@export var coyote_time := 0.1

var coyote_timer : Timer

func _ready():
	super._ready()
	coyote_timer = Timer.new()
	coyote_timer.one_shot = true
	coyote_timer.timeout.connect(_on_coyote_timeout)
	add_child(coyote_timer)

func enter(_msg := {}) -> void:
	if _msg.has("animation") and _msg.animation == "land" and actor.animation_player.has_animation("run_land"):
		actor.play_animation("run_land")
	else:
		actor.play_animation(animation)

func exit() -> void:
	super.exit()
	coyote_timer.stop()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})


func physics_update(delta: float) -> void:
	# Notice how we have some code duplication between states. That's inherent to the pattern,
	# although in production, your states will tend to be more complex and duplicate code
	# much more rare.
	if not actor.is_on_floor() and coyote_timer.time_left <= 0:
		coyote_timer.start(coyote_time)
	
	# We move the run-specific input code to the state.
	var old_velocity = actor.velocity
	actor.velocity.x = actor.speed * actor.input_direction.x
	actor.velocity.y += actor.gravity * delta
	
	if sign(actor.velocity.x) != 0 \
			and sign(old_velocity.x) != sign(actor.velocity.x):
		actor.look_direction = Vector2(sign(actor.velocity.x), 0)
	
	if is_equal_approx(actor.input_direction.x, 0.0):
		state_machine.transition_to("Idle")

func _on_coyote_timeout():
	if not actor.is_on_floor():
		state_machine.transition_to("Air")
