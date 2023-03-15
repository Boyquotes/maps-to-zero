extends ItemData
class_name ItemDataConsumable


@export var value: float
@export var type: CharacterStats.Types


func use(target) -> void:
	# Heal the player
	var character := target as Character
	if character and not value == 0:
		character.change_stat_by(type, value)
