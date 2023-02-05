extends StateTransitionRequirement

@export var resource_type : ActorResources.Type
@export var amount : float = 0.0
@export var reduce_on_transition : bool = true

func get_is_ready() -> bool:
	return actor.resources.get_resource(resource_type) >= amount


func enter(msg:={}) -> void:
	if reduce_on_transition:
		actor.resources.change_resource(resource_type, -amount)
