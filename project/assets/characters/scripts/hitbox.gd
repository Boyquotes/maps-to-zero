class_name Hitbox
extends Area2D


signal hit(hit_character)


@export var base_value := 0.0
@export var hit_particles : PackedScene
@export var hit_sfx : AudioStream
@export var on_hit_resource_gain_type: CharacterStats.Types
@export var on_hit_resource_gain_amount: float = 0.0
@export var frame_freeze_duration_milliseconds: int = 0
@export var screen_shake_trauma: float = 0.0
@export var team : GameUtilities.Teams


var _character: Actor2D


func _ready():
	set_collision_layer_value(GameUtilities.PhysicsLayers.FLOORS_WALLS, false)
	set_collision_mask_value(GameUtilities.PhysicsLayers.FLOORS_WALLS, false)
	set_collision_layer_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, true)
	set_collision_mask_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, false)
	monitoring = false
	monitorable = true
	
	await owner.ready
	if owner is Actor2D:
		_character = owner
		team = _character.team
	elif owner is Projectile:
		_character = owner.actor
		team = _character.team


func set_actor(actor: Actor2D):
	self._character = actor
	team = _character.team


func confirm_hit(hit_character: Actor2D) -> void:
	if _character:
		_character.change_stat_by(on_hit_resource_gain_type, on_hit_resource_gain_amount)
	hit.emit(hit_character)
