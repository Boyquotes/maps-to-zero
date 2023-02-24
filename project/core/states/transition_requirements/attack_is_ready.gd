extends StateTransitionRequirement


func get_is_ready() -> bool:
	return actor.attack_can_go_to_next
