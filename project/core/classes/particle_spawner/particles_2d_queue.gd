class_name Particles2DQueue
extends Marker2D

@export var particles : PackedScene
@export var queue_count := 8

var index = 0

func _ready():
	for i in range(queue_count):
		add_child(particles.instantiate())

func _get_next_particle():
	return get_child(index)

func trigger():
	_get_next_particle().restart()
	index = (index + 1) % queue_count
