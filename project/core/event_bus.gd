extends Node


# Emitter: [actor_resources.gd], Receivers: [sidescroller_hud.gd]
# Updates UI when player stat resource is updated
signal player_resource_changed(type, new_value, old_value, max_value)
func _on_player_resource_changed(type, new_value, old_value, max_value) -> void:
	player_resource_changed.emit(type, new_value, old_value, max_value)
