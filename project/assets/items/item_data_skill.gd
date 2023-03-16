extends ItemData
class_name ItemDataSkill


@export var skill_name: String


func use(target) -> void:
	var character := target as Character
	if character:
		character.request_skill_use(skill_name)
