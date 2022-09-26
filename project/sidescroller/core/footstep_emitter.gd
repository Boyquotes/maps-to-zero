class_name FootstepEmitter
extends Marker2D

enum FootstepTypes { DEFAULT }
const NAMES := {
	FootstepTypes.DEFAULT : ParticleSpawner.OneShotParticles.FOOTSTEPS_DEFAULT
}

const sfx_library : Dictionary = {
	NAMES[FootstepTypes.DEFAULT] : ["footsteps_default_1.wav", "footsteps_default_2.wav", "footsteps_default_3.wav", "footsteps_default_4.wav", "footsteps_default_5.wav", "footsteps_default_6.wav", "footsteps_default_7.wav", "footsteps_default_8.wav", ]
}

@export var pitch_scale_min := 0.9
@export var pitch_scale_max := 1.1

func emit_footstep() -> void:
	var footstep_type = NAMES[FootstepTypes.DEFAULT]
	
	var sfx_list = sfx_library[footstep_type]
	var sfx_file_name = sfx_list[randi_range(0, len(sfx_list) - 1)]
	if not GlobalVariables.loaded_sfx.has(sfx_file_name):
		GlobalVariables.loaded_sfx[sfx_file_name] = load(GlobalVariables.SFX_FOLDER + sfx_file_name)
	var stream = GlobalVariables.loaded_sfx[sfx_file_name] as AudioStream
	
	var particles = ParticleSpawner.spawn_one_shot(footstep_type, global_position, self, stream)
	
	if particles.has_node("AudioStreamPlayer2d"):
		var audio_stream_player = particles.get_node("AudioStreamPlayer2d")
		audio_stream_player.bus = "Footsteps"
		audio_stream_player.pitch_scale = randf_range(pitch_scale_min, pitch_scale_max)
