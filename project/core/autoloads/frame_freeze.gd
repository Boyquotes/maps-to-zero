extends Node


var enabled : bool = true
var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	add_child(_timer)
	_timer.timeout.connect(reset_time_scale)


func request(delay_milliseconds := 17, time_scale := 0.1) -> void:
	if not enabled:
		return
	_timer.stop()
	Engine.time_scale = time_scale
	_timer.start(delay_milliseconds / 1000.0 * time_scale)


func reset_time_scale() -> void:
	Engine.time_scale = 1.0
