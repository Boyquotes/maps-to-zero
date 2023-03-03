class_name WaitTransition
extends StateTransition2D

@export var next_state := ""
@export var wait_time := 1.0

var _timer : Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)


func enter(msg := {}) -> void:
	super.enter(msg)
	_timer.start(wait_time)


func exit() -> void:
	super.exit()
	_timer.stop()


func _on_timeout() -> void:
	_state.state_machine.transition_to(next_state)
