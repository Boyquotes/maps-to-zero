class_name FootstepEmitter
extends Marker2D

enum FootstepTypes { DEFAULT }
const footstep_particles : Dictionary = {
	FootstepTypes.DEFAULT : [preload("res://assets/particles_one_shot/footsteps_default.tscn")]
}
var sfx_library : Dictionary = {
	FootstepTypes.DEFAULT : [preload("res://assets/sfx/footsteps_default_1.wav") as AudioStream, 
		preload("res://assets/sfx/footsteps_default_2.wav") as AudioStream, 
		preload("res://assets/sfx/footsteps_default_3.wav") as AudioStream, 
		preload("res://assets/sfx/footsteps_default_4.wav") as AudioStream, 
		preload("res://assets/sfx/footsteps_default_5.wav") as AudioStream, 
		preload("res://assets/sfx/footsteps_default_6.wav") as AudioStream, 
		preload("res://assets/sfx/footsteps_default_7.wav") as AudioStream, 
		preload("res://assets/sfx/footsteps_default_8.wav") as AudioStream, 
	] as Array[AudioStream]
}

@export var pitch_scale_min := 0.9
@export var pitch_scale_max := 1.1

@onready var sfx_player := $AudioStreamPlayer2DExtended as AudioStreamPlayer2DExtended

func emit_footstep() -> void:
	var footstep_type = FootstepTypes.DEFAULT
	
	var particles_scene = footstep_particles[footstep_type][0]
	ParticleSpawner.spawn_one_shot(particles_scene, global_position, self)
	
	sfx_player.streams = sfx_library[footstep_type]
	sfx_player.play_random()
