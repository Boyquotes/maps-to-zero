extends RigidBody2D
class_name PickUpItem


@export var slot_data: SlotData


@onready var hitbox := %Hitbox as Hitbox

@onready var _sprite := $Sprite2D as Sprite2D
@onready var _area_collision_shape := $Area2D/CollisionShape2D as CollisionShape2D
@onready var _particle_spawner := %ParticleSpawner as ParticleSpawner
@onready var _audio_player := %PickUpSfx as AudioStreamPlayer2D
@onready var _hit_bounce_particle_spawner := %HitBounceParticleSpawner as ParticleSpawner
@onready var _hit_bounce_sfx := %HitBounceSfx as AudioStreamPlayer2D
@onready var _animation_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	_sprite.texture = slot_data.item_data.texture
	
	if hitbox:
		_initialize_hitbox()


func _on_area_2d_area_entered(area: Area2D):
	if slot_data.item_data is ItemDataSkill:
		# Save to skill inventory
		SaveData.skills.pick_up_slot_data(slot_data)
		pick_up()
	elif area.owner is Character:
		var character := area.owner as Character
		if character.inventory_data.pick_up_slot_data(slot_data):
			pick_up()


func pick_up() -> void:
	# Because disabling the collider in code doesn't work because
	# it can't change the state while it's flushing queries
	# So use an animation player instead
	_animation_player.play("pick_up")
	
	_sprite.hide()
	_particle_spawner.spawn()
	_audio_player.play()
	await _audio_player.finished
	queue_free()


func _initialize_hitbox() -> void:
	hitbox.monitoring = true
	hitbox.set_collision_layer_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, true)
	hitbox.set_collision_mask_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, true)
	hitbox.area_entered.connect(_on_hit)
	hitbox.hit.connect(_on_hitbox_hit)


func _reset_velocity() -> void:
	apply_impulse(-linear_velocity)


func _on_hit(area: Area2D) -> void:
	if area.name == "Hurtbox":
		return
	apply_central_impulse(area.global_position.direction_to(global_position) * 1300)
	_hit_bounce_particle_spawner.spawn()
	_hit_bounce_sfx.play()


func _on_hitbox_hit(character: Character) -> void:
	_reset_velocity()
	var direction = Vector2(sign(character.global_position.direction_to(hitbox._character.global_position).x), -0.5).normalized()
	apply_central_impulse(direction * 600)
