extends StateTransition2D

@export var next_state := ""
@export var distance_closer_than := 10.0: # In tiles
	get:
		return distance_closer_than * GameUtilities.TILE_SIZE.x
@export var tick_rate := 0.5

var timer : Timer

func _ready():
	super._ready()
	timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = tick_rate
	timer.timeout.connect(check)
	add_child(timer)


func enter(msg:={}) -> void:
	super.enter(msg)
	timer.start()

func exit() -> void:
	super.exit()
	timer.stop()


func check() -> void:
	if actor.target_manager.get_distance() < self.distance_closer_than:
		state.state_machine.transition_to(next_state)
