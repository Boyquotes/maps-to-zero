class_name ScreenTransitionTrigger
extends Trigger

@export var transition: ScreenEffectsClass.ScreenTransition
@export var duration: float = 0.0


func trigger(_dummy_var=null) -> void:
	ScreenEffects.screen_transition(transition, duration)
	super.trigger()
