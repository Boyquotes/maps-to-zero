extends StateTransitionRequirement
class_name SkillTransition


func get_is_ready() -> bool:
	var current_state_is_other_skill := false
	for req in _character.state_machine.state.transition_requirements:
		if req is SkillTransition and not _character.attack_can_go_to_next:
			current_state_is_other_skill = true
			break
	return not current_state_is_other_skill
