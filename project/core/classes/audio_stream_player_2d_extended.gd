class_name AudioStreamPlayer2DExtended
extends AudioStreamPlayer2D


@export var streams: Array[AudioStream]
@export var pitch_scale_min : float = 1:
	set(value):
		pitch_scale_min = min(value, pitch_scale_max)
@export var pitch_scale_max : float = 1:
	set(value):
		pitch_scale_max = max(value, pitch_scale_min)


func play_random(from:=0.0) -> void:
	if streams.size() > 0:
		stream = streams[randi() % streams.size()]
	super.play(from)
