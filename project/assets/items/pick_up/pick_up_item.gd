extends RigidBody2D
class_name PickUpItem


@export var slot_data: SlotData


@onready var hitbox := %Hitbox as Hitbox
@onready var _sprite := $Sprite2D as Sprite2D
@onready var _area_collision_shape := $Area2D/CollisionShape2D as CollisionShape2D
@onready var _particle_spawner := %ParticleSpawner as ParticleSpawner
@onready var _audio_player := %PickUpSfx as AudioStreamPlayer2D
@onready var _animation_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	_sprite.texture = slot_data.item_data.texture


func _on_area_2d_area_entered(area: Area2D):
	if area.owner is Character:
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
