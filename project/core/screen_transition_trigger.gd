class_name ScreenTransitionTrigger
extends Trigger

@export var transition: Enums.ScreenTransition
@export var duration: float = 0.0


func trigger(_dummy_var=null) -> void:
	GameManager.screen_transition(transition, duration)
	super.trigger()
