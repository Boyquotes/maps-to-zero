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
@export var enabled : bool = false: 
	set(value):
		enabled = value
		set_collision_layer_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, enabled)
		for child in get_children():
			if child is CollisionShape2D:
				var collider = child as CollisionShape2D
				collider.disabled = not value
@export var flinch : PackedScene
@export var revenge_value := 0.0


var _character: Character


func _ready():
	_reset_hitbox_collision()
	set_collision_layer_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, enabled)


func set_character(new_character: Character) -> void:
	_character = new_character


func set_team(new_team: GameUtilities.Teams) -> void:
	team = new_team


func confirm_hit(hit_character: Character) -> void:
	if _character:
		_character.change_stat_by(on_hit_resource_gain_type, on_hit_resource_gain_amount)
	hit.emit(hit_character)


func _reset_hitbox_collision() -> void:
	monitoring = false
	monitorable = true
	
	# Set all collision layers and masks off
	collision_layer = 0
	collision_mask = 0
	# Then only enable the hitbox/hurtbox physics layer
	set_collision_layer_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, true)
	set_collision_mask_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, false)
