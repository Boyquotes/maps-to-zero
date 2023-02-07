class_name Hitbox
extends Area2D

signal hit(actor)

@export var base_value := 0.0
@export var hit_particles : PackedScene
@export var hit_sfx : AudioStream
@export var on_hit_resource_gain_type: ActorResources.Type
@export var on_hit_resource_gain_amount := 0.0

var team : GameUtilities.Teams
var actor: Actor2D


func _ready():
	collision_layer = 0
	collision_mask = 1 << 2
	area_entered.connect(_on_hurtbox_entered)
	
	await owner.ready
	if owner is Actor2D:
		actor = owner
		team = actor.team
	elif owner is Projectile:
		actor = owner.actor
		team = actor.team


func _on_hurtbox_entered(area : Area2D) -> void:
	var damage_taken = area.owner.take_damage(base_value, ActorResources.Type.HP, self)
	if damage_taken:
		actor.resources.change_resource(on_hit_resource_gain_type, on_hit_resource_gain_amount)
		hit.emit(area.owner)
