class_name ParticleSpawner
extends Marker2D

@export var particles_scene : PackedScene
@export var particles_top_level : bool = true

static func spawn_one_shot(one_shot_particles: PackedScene, \
							target_global_position : Vector2, \
							parent : Node):
	if one_shot_particles == null:
		return
	
	var particles_2d_one_shot = one_shot_particles.instantiate()
	
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
	
	return particles_2d_one_shot


func spawn() -> void:
	var parent = GameManager.sidescroller_main if particles_top_level else self
	spawn_one_shot(particles_scene, global_position, parent)
