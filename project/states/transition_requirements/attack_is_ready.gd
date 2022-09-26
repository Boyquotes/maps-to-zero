extends StateTransitionRequirement


func get_is_ready() -> bool:
	return actor_2d.attack_can_go_to_next
