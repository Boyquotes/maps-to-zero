class_name ParticleSpawner
extends Marker2D

enum OneShotParticles {
	NONE,
	DEFAULT_HIT_IMPACT,
	FOOTSTEPS_DEFAULT,
	JUMP_DEFAULT,
	STOMP_LAND_ALISA,
	DEFEAT_EXPLOSION_DEFAULT
}
const _one_shot_particles := {
	OneShotParticles.DEFAULT_HIT_IMPACT : "default_hit_impact",
	OneShotParticles.FOOTSTEPS_DEFAULT : "footsteps_default",
	OneShotParticles.JUMP_DEFAULT : "jump_default",
	OneShotParticles.STOMP_LAND_ALISA : "stomp_land_alisa",
	OneShotParticles.DEFEAT_EXPLOSION_DEFAULT : "defeat_explosion_default"
}

const FOLDER = "res://assets/particles_one_shot/"

const particles := {} # { particles_name, load(particles_name) }

static func spawn_one_shot(one_shot_particles: OneShotParticles, \
							target_global_position : Vector2, \
							parent : Node, \
							sfx: AudioStream = null):
	if one_shot_particles == OneShotParticles.NONE:
		return
	
	var file_name = _one_shot_particles[one_shot_particles]
	if not particles.has(file_name):
		particles[file_name] = load(FOLDER + file_name + ".tscn")
	var particles_2d_one_shot = particles[file_name].instantiate()
	
	parent.add_child(particles_2d_one_shot)
	particles_2d_one_shot.global_position = target_global_position
	particles_2d_one_shot.preprocess = 0.01
	particles_2d_one_shot.emitting = true
	
	var lifetime_timer = Timer.new()
	lifetime_timer.name = "LifetimeTimer"
	lifetime_timer.timeout.connect(func():
		if not particles_2d_one_shot.has_node("AudioStreamPlayer2d"):
			particles_2d_one_shot.queue_free()
		else:
			lifetime_timer.queue_free()
		)
	particles_2d_one_shot.add_child(lifetime_timer)
	lifetime_timer.start(particles_2d_one_shot.lifetime)
	
	if sfx:
		var audio_stream_player_2d = AudioStreamPlayer2D.new()
		audio_stream_player_2d.name = "AudioStreamPlayer2d"
		audio_stream_player_2d.stream = sfx
		audio_stream_player_2d.bus = "Sfx"
		audio_stream_player_2d.finished.connect(func():
			if not particles_2d_one_shot.has_node("LifetimeTimer"):
				particles_2d_one_shot.queue_free()
			else:
				audio_stream_player_2d.queue_free()
			)
		particles_2d_one_shot.add_child(audio_stream_player_2d)
		audio_stream_player_2d.play()
	
	return particles_2d_one_shot

