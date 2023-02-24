class_name Projectile
extends CharacterBody2D

@export var speed := 600.0
@export var lifetime := 3.0

var direction := Vector2.RIGHT
var actor: Actor2D

@onready var timer : Timer = $Timer
@onready var hitbox : Hitbox = $Hitbox
@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready():
	set_as_top_level(true)
	look_at(position + direction)
	
	timer.timeout.connect(queue_free)
	timer.start(lifetime)
	
	hitbox.hit.connect(_on_hit)


func _physics_process(delta):
	velocity = direction * speed
	rotation = velocity.angle()
	sprite.flip_v = sign(velocity.x) < 0
	sprite.flip_h = sign(velocity.x) < 0
	move_and_slide()
	if is_on_floor() or is_on_ceiling() or is_on_wall():
		_on_impact()


func _on_impact() -> void:
	set_physics_process(false)
	queue_free()


func _on_hit(hit_actor: Actor2D) -> void:
	_on_impact()
