class_name CharacterHUD
extends Control

@onready var hp_bar : ProgressBar = $HP/ProgressBar


func init(character: Character):
	character.stat_changed.connect(_on_stat_changed)
	_on_stat_changed(CharacterStats.Types.HP, \
			character.get_stat(CharacterStats.Types.HP), \
			character.get_stat(CharacterStats.Types.HP), \
			character.get_max_stat(CharacterStats.Types.HP))


func _on_stat_changed(type: CharacterStats.Types, new_value, old_value, max_value) -> void:
	match type:
		CharacterStats.Types.HP:
			hp_bar.max_value = max_value
			hp_bar.value = new_value
#		CharacterStats.Types.MP:
#			mp_bar.max_value = max_value
#			mp_bar.value = new_value
#		CharacterStats.Types.SP:
#			sp_bar.max_value = max_value
#			sp_bar.value = new_value
