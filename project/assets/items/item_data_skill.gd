extends ItemData
class_name ItemDataSkill


@export var skill_name: String


func use(target) -> void:
	var character := target as Character
	var success := false
	if character:
		success = character.request_skill_use(skill_name)
	if success:
		super.use(target)
