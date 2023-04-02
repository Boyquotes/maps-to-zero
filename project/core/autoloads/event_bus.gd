extends Node


# Emitter: [actor_resources.gd], Receivers: [sidescroller_hud.gd]
# Updates UI when player stat resource is updated
signal player_resource_changed(type, new_value, old_value, max_value)
func _on_player_resource_changed(type, new_value, old_value, max_value) -> void:
	player_resource_changed.emit(type, new_value, old_value, max_value)


# Emitter: [item_chest.gd], Receivers: [inventory_interface.gd]
# Updates UI when player leaves item chest area
signal character_leaves_item_chest
func on_character_leaves_item_chest() -> void:
	character_leaves_item_chest.emit()
