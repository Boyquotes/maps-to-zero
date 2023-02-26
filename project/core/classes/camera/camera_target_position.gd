extends Node2D


# Adjust camera offset to go in front of player if travelling really fast
func _process(_delta):
	if get_parent() is Actor2D:
		var character = get_parent() as Actor2D
		var factor_over_normal_speed = character.velocity.x / character.speed
		factor_over_normal_speed = max(abs(factor_over_normal_speed) - 1, 0) * character.look_direction.x
		var target_position = Vector2(factor_over_normal_speed * pow(GameUtilities.TILE_SIZE.x, 1.3), 0)
		position.x = lerp(position.x, target_position.x, 0.1)
