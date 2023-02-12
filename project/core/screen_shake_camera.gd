class_name ScreenShakeCamera
extends Node

# How quickly to move through the noise
@export var NOISE_SHAKE_SPEED: float = 30.0
@export var NOISE_SWAY_SPEED: float = 1.0
# Noise returns values in the range (-1, 1)
# So this is how much to multiply the returned value by
@export var trauma_multiplier: float = 30.0
# Multiplier for lerping the shake strength to zero
@export var shake_decay_rate: float = 5.0

enum ShakeType {
	Random,
	Noise,
	Sway
}

@onready var _rand = RandomNumberGenerator.new()
@onready var _noise = FastNoiseLite.new()

# Used to keep track of where we are in the noise
# so that we can smoothly move through it
var _noise_i: float = 0.0
var _shake_type: int = ShakeType.Random
var _trauma: float = 0.0
var shake_offset : Vector2:
	get:
		return shake_offset * trauma_multiplier

func _ready() -> void:
	_noise.seed = 0
	# Period affects how quickly the noise changes values
	_noise.frequency = 2

func _process(delta: float) -> void:
	# Fade out the intensity over time
	_trauma = lerp(_trauma, 0.0, shake_decay_rate * delta)
	
	match _shake_type:
		ShakeType.Random:
			shake_offset = get_random_offset()
		ShakeType.Noise:
			shake_offset = get_noise_offset(delta, NOISE_SHAKE_SPEED, _trauma)
		ShakeType.Sway:
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


func add_trauma(additional_trauma := 0.1) -> void:
	_shake_type = ShakeType.Noise
	_trauma = clampf(_trauma + additional_trauma, 0.0, 5.0)
	
	if _trauma >= 0.01:
		set_process(true)
	else:
		_trauma = 0.0
