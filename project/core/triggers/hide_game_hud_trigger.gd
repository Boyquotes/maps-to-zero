class_name HideGameHudTrigger
extends Trigger

signal finished

@export var duration: float = 0.0


func trigger(_dummy_var=null) -> void:
	super.trigger()
	hide_game_hud(duration)

func hide_game_hud(_duration:=0.0)->void:
	GameManager.sidescroller_main.sidescroller_hud.hide_hud(_duration)
	if is_zero_approx(_duration):
		finished.emit()
	else:
		await GameManager.sidescroller_main.sidescroller_hud.hide_finished
		finished.emit()
