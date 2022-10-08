extends Interaction

@export var animation_player: NodePath
@export var animation := "start"


func trigger() -> void:
	if get_node(animation_player) and get_node(animation_player).has_animation(animation):
		get_node(animation_player).play(animation)
	super.trigger()
