extends CharacterInterface
class_name SuperArmorCreator


const _super_armor := preload("res://assets/characters/scripts/effects/super_armor.tscn")

@export var life_time: float


func add() -> void:
	var effect := _super_armor.instantiate() as CharacterEffects
	effect.life_time = life_time
	_character.add_effect(effect)
