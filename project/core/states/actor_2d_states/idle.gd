# idle.gd
extends Actor2DState

@export var animation := "idle"
@export var coyote_time := 0.1

var coyote_timer : Timer

func _ready():
	coyote_timer = Timer.new()
	coyote_timer.one_shot = true
	coyote_timer.timeout.connect(_on_coyote_timeout)
	add_child(coyote_timer)

func enter(_msg := {}) -> void:
	if not actor.is_on_floor():
		state_machine.transition_to("Air")
		return
	elif not is_equal_approx(actor.input_direction.x, 0):
		state_machine.transition_to("Run", _msg)
		return
	actor.velocity = Vector2.ZERO
	if _msg.has("animation") and actor.animation_player.has_animation(_msg.animation):
		actor.play_animation(_msg.animation)
	else:
		actor.play_animation(animation)

func exit() -> void:
	super.exit()
	coyote_timer.stop()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})


func update(_delta: float) -> void:
	# If you have platforms that break when standing on them, you need that check for 
	# the character to fall.
	if not actor.is_on_floor() and coyote_timer.time_left <= 0:
		coyote_timer.start(coyote_time)
	if not is_equal_approx(actor.input_direction.x, 0):
		state_machine.transition_to("Run")

func _on_coyote_timeout():
	if not actor.is_on_floor():
		state_machine.transition_to("Air")
