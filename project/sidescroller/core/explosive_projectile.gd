class_name ExplosiveProjectile
extends Projectile

func _physics_process(delta):
	velocity = direction * speed
	rotation = velocity.angle()
	sprite.flip_v = sign(velocity.x) < 0
	sprite.flip_h = sign(velocity.x) < 0
	move_and_slide()
	if is_on_floor() or is_on_ceiling() or is_on_wall():
		_on_impact()


func _on_impact() -> void:
	explode()


func explode() -> void:
	set_physics_process(false)
	animation_player.play("explode")
	animation_player.animation_finished.connect(func(anim_name: String):
		if anim_name == "explode":
			queue_free()
		)
