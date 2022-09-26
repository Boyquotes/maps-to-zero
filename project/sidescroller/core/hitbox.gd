class_name Hitbox
extends Area2D

signal hit(actor)

@export var base_value := 0.0
@export var hit_particles : ParticleSpawner.OneShotParticles
@export var hit_sfx : AudioStream

var team : GameUtilities.Teams


func _ready():
	collision_layer = 0
	collision_mask = 1 << 2
	area_entered.connect(_on_hurtbox_entered)
	
	await owner.ready
	if owner.get("team"):
		team = owner.team


func _on_hurtbox_entered(area : Area2D) -> void:
	area.owner.take_damage(base_value, ActorResources.Type.HP, self)
