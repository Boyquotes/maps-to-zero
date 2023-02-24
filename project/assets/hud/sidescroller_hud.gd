extends Control


@onready var hp_bar: TextureProgressBar = $Display/Control/HPBar
@onready var mp_bar: TextureProgressBar = $Display/Control/MPBar
@onready var sp_bar: TextureProgressBar = $Display/Control/SPBar

func _ready():
	Events.player_resource_changed.connect(_on_player_resource_changed)


func show_hud(duration:= 1.0):
	if is_equal_approx(duration, 0.0):
		$AnimationPlayer.speed_scale = 1.0
		$AnimationPlayer.play("RESET")
		$Display/Control.visible = true
	else:
		$AnimationPlayer.speed_scale = 1.0 / duration
		$AnimationPlayer.play("show")
		$Display/Control.visible = true

func hide_hud(duration:= 1.0):
	if is_equal_approx(duration, 0.0):
		$Display/Control.visible = false
	else:
		$AnimationPlayer.speed_scale = 1.0 / duration
		$AnimationPlayer.play("hide")
		$Display/Control.visible = true

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
