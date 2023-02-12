extends Node


var enabled : bool = true

func request(delay_milliseconds := 17, time_scale := 0.1) -> void:
	if not enabled:
		return
	Engine.time_scale = time_scale
	await get_tree().create_timer(delay_milliseconds / 1000.0 * time_scale).timeout
	Engine.time_scale = 1.0
