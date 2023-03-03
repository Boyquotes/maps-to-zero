class_name Projectile
extends CharacterBody2D

@export var speed := 600.0
@export var lifetime := 3.0

var _direction := Vector2.RIGHT
#var _character: Character

@onready var _timer : Timer = $Timer
@onready var _hitbox : Hitbox = $Hitbox
@onready var _sprite : Sprite2D = $Sprite2D
#@onready var _animation_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	set_as_top_level(true)
	look_at(position + _direction)
	
	_timer.timeout.connect(queue_free)
	_timer.start(lifetime)
	
	_hitbox.hit.connect(_on_hit)


func _physics_process(_delta) -> void:
	velocity = _direction * speed
	rotation = velocity.angle()
	_sprite.flip_v = sign(velocity.x) < 0
	_sprite.flip_h = sign(velocity.x) < 0
	move_and_slide()
	if is_on_floor() or is_on_ceiling() or is_on_wall():
		_on_impact()


func _on_impact() -> void:
	set_physics_process(false)
	queue_free()


func _on_hit(_hit_character: Character) -> void:
	_on_impact()
