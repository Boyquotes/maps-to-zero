class_name CharacterStats
extends Node

signal stat_changed(type, new_value, old_value, max_value)

enum Types { HP, MP, SP }


var _stats := {
	Types.HP : 0.0,
	Types.MP : 0.0,
	Types.SP : 0.0
}
var _max_stats := {
	Types.HP : 0.0,
	Types.MP : 0.0,
	Types.SP : 0.0
}


func get_stat(type: Types):
	return _stats[type]

func change_stat_by(type: Types, value: float, clamp_value := true) -> void:
	var new_value = _stats[type] + value
	if clamp_value:
		new_value = clampf(new_value, 0, _max_stats[type])
	set_stat(type, new_value)

func set_stat(type: Types, new_value: float) -> void:
	var old_value = _stats[type]
	_stats[type] = new_value
	stat_changed.emit(type, new_value, old_value, _max_stats[type])

func set_max_stat(type: Types, new_value: float) -> void:
	_max_stats[type] = new_value

func get_max_stat(type: Types):
	return _max_stats[type]

func max_out(type: Types) -> void:
	set_stat(type, max(_max_stats[type], _stats[type]))

func _on_mp_regen_timer_timeout():
	change_stat_by(Types.MP, 1, true)
