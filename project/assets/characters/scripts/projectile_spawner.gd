extends Node2D

@export var projectile_scene : PackedScene

@onready var shoot_position : Marker2D = $ShootPosition

var team : GameUtilities.Teams
var actor: Character

func _ready() -> void:
	if owner is Character:
		actor = owner


func shoot(projectile: PackedScene) -> void:
	if projectile == null:
		projectile = projectile_scene
	var projectile_instance := projectile.instantiate()
	projectile_instance.position = shoot_position.global_position
	projectile_instance.direction = _get_target_direction()
	projectile_instance.actor = actor
	add_child(projectile_instance)


func _get_target_direction() -> Vector2:
	if actor:
		if signf(actor.look_direction.x) >= 0:
			return actor.look_direction.rotated(rotation)
		else:
			return actor.look_direction.rotated(-rotation)
	return Vector2.RIGHT.rotated(rotation)
