extends StateTransition2D

@export var next_state := ""
@export var wait_time := 1.0

var timer : Timer

func _ready() -> void:
	super._ready()
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	add_child(timer)

func enter(msg := {}) -> void:
	super.enter(msg)
	timer.start(wait_time)

func exit() -> void:
	super.exit()
	timer.stop()

func _on_timeout() -> void:
	state.state_machine.transition_to(next_state)
