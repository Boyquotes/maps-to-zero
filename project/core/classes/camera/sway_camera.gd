class_name SwayCamera
extends Node

# How quickly to move through the noise
@export var NOISE_SWAY_SPEED: float = 0.04

@onready var _rand = RandomNumberGenerator.new()
@onready var _noise = FastNoiseLite.new()

var trauma_multiplier := 10.0

# Used to keep track of where we are in the noise
# so that we can smoothly move through it
var _noise_i: float = 0.0
var _trauma: float = 1.0
var shake_offset : Vector2:
	get:
		return shake_offset * trauma_multiplier

func _ready() -> void:
	_noise.seed = 0
	# Period affects how quickly the noise changes values
	_noise.frequency = 2

func _process(delta: float) -> void:
	shake_offset = get_noise_offset(delta, NOISE_SWAY_SPEED, _trauma)
	
	if _trauma < 0.01:
		_trauma = 0.0
		set_process(false)

func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	_noise_i += delta * speed
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(_noise.get_noise_2d(1, _noise_i), _noise.get_noise_2d(100, _noise_i)) * strength

func get_random_offset() -> Vector2:
	return Vector2(
		_rand.randf_range(-_trauma, _trauma),
		_rand.randf_range(-_trauma, _trauma)
	)
