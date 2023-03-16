extends ItemData
class_name ItemDataSkill


@export var skill_name: String


func use(target) -> void:
	# Heal the player
	var character := target as Character
	if character:
		character.request_skill_use(skill_name)
