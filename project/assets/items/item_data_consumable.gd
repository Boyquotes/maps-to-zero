extends ItemData
class_name ItemDataConsumable


@export var value: float
@export var type: CharacterStats.Types


func use(target) -> void:
	# Heal the player
	var character := target as Character
	var can_use := false
	if character:
		can_use = character.can_use_item(self)
	if can_use:
		character.change_stat_by(type, value)
		super.use(target)
