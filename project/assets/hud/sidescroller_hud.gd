extends Control

signal show_finished
signal hide_finished

@onready var hp_bar: TextureProgressBar = $Display/Control/HPBar
@onready var mp_bar: TextureProgressBar = $Display/Control/MPBar
@onready var sp_bar: TextureProgressBar = $Display/Control/SPBar

var hud_displaying : bool = true

func _ready():
	Events.player_resource_changed.connect(_on_player_resource_changed)


func show_hud(duration:= 1.0):
	if hud_displaying:
		show_finished.emit()
		return
	hud_displaying = true
	if is_equal_approx(duration, 0.0):
		$AnimationPlayer.speed_scale = 1.0
		$AnimationPlayer.play("RESET")
		$Display/Control.visible = true
		show_finished.emit()
	else:
		$AnimationPlayer.speed_scale = 1.0 / duration
		$AnimationPlayer.play("show")
		$Display/Control.visible = true
		await $AnimationPlayer.animation_finished
		show_finished.emit()

func hide_hud(duration:= 1.0):
	hud_displaying = false
	if is_equal_approx(duration, 0.0):
		$Display/Control.visible = false
		hide_finished.emit()
	else:
		$AnimationPlayer.speed_scale = 1.0 / duration
		$AnimationPlayer.play("hide")
		$Display/Control.visible = true
		await $AnimationPlayer.animation_finished
		hide_finished.emit()

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
