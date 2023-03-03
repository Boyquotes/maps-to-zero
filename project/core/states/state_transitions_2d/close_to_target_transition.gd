class_name CloseToTargetTransition
extends StateTransition2D

@export var next_state := ""
@export var distance_closer_than := 10.0: # In tiles
	get:
		return distance_closer_than * GameUtilities.TILE_SIZE.x
@export var tick_rate := 0.5

var _timer : Timer

func _ready():
	_timer = Timer.new()
	_timer.one_shot = false
	_timer.wait_time = tick_rate
	_timer.timeout.connect(_check)
	add_child(_timer)


func enter(msg:={}) -> void:
	super.enter(msg)
	_timer.start()


func exit() -> void:
	super.exit()
	_timer.stop()


func _check() -> void:
	if _character.get_distance_from_target() < self.distance_closer_than:
		_state.state_machine.transition_to(next_state)
