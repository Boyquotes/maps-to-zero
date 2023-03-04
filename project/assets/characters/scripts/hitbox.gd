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


var _character: Character


func _ready():
	set_collision_layer_value(GameUtilities.PhysicsLayers.FLOORS_WALLS, false)
	set_collision_mask_value(GameUtilities.PhysicsLayers.FLOORS_WALLS, false)
	set_collision_layer_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, true)
	set_collision_mask_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, false)
	monitoring = false
	monitorable = true


func set_character(new_character: Character) -> void:
	_character = new_character


func set_team(new_team: GameUtilities.Teams) -> void:
	team = new_team


func confirm_hit(hit_character: Character) -> void:
	if _character:
		_character.change_stat_by(on_hit_resource_gain_type, on_hit_resource_gain_amount)
	hit.emit(hit_character)
