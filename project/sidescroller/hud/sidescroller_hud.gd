extends Control


@onready var hp_bar: TextureProgressBar = $Display/HPBar
@onready var mp_bar: TextureProgressBar = $Display/MPBar
@onready var sp_bar: TextureProgressBar = $Display/SPBar

func _ready():
	Events.player_resource_changed.connect(_on_player_resource_changed)


func _on_player_resource_changed(type, new_value, old_value, max_value) -> void:
	match type:
		ActorResources.Type.HP:
			hp_bar.max_value = max_value
			hp_bar.value = new_value
		ActorResources.Type.MP:
			mp_bar.max_value = max_value
			mp_bar.value = new_value
		ActorResources.Type.SP:
			sp_bar.max_value = max_value
			sp_bar.value = new_value
