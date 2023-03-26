class_name CharacterHUD
extends Control

@onready var _hp_bar := $HP/ProgressBar as ProgressBar
@onready var _state_label := %StateLabel as Label
@onready var _input_state_label := %InputStateLabel as Label
@onready var _revenge_bar := %RevengeProgressBar as ProgressBar


func init(character: Character):
	character.stat_changed.connect(_on_stat_changed)
	_on_stat_changed(CharacterStats.Types.HP, \
			character.get_stat(CharacterStats.Types.HP), \
			character.get_stat(CharacterStats.Types.HP), \
			character.get_max_stat(CharacterStats.Types.HP))
	character.state_machine.transitioned.connect(_on_state_machine_changed_state)
	character.input_state_machine.transitioned.connect(_on_input_state_machine_changed_state)


func _on_stat_changed(type: CharacterStats.Types, new_value, _old_value, max_value) -> void:
	match type:
		CharacterStats.Types.HP:
			_hp_bar.max_value = max_value
			_hp_bar.value = new_value
#		CharacterStats.Types.MP:
#			mp_bar.max_value = max_value
#			mp_bar.value = new_value
#		CharacterStats.Types.SP:
#			sp_bar.max_value = max_value
#			sp_bar.value = new_value
		CharacterStats.Types.REVENGE:
			_revenge_bar.max_value = max_value
			_revenge_bar.value = new_value


func _on_state_machine_changed_state(to: StringName, _from: StringName) -> void:
	_state_label.text = to


func _on_input_state_machine_changed_state(to: StringName, _from: StringName) -> void:
	_input_state_label.text = to
