class_name CharacterStats
extends Node

signal stat_changed(type, new_value, old_value, max_value)

enum Types { HP, MP, SP }
var _resources := {
	Types.HP : 0.0,
	Types.MP : 0.0,
	Types.SP : 0.0
}

var _max_resources := {
	Types.HP : 0.0,
	Types.MP : 0.0,
	Types.SP : 0.0
}


func get_resource(type: Types):
	return _resources[type]

func change_resource(type: Types, value: float, clamp_value := true) -> void:
	var new_value = _resources[type] + value
	if clamp_value:
		new_value = clampf(new_value, 0, _max_resources[type])
	set_resource(type, new_value)

func set_resource(type: Types, new_value: float) -> void:
	var old_value = _resources[type]
	_resources[type] = new_value
	stat_changed.emit(type, new_value, old_value, _max_resources[type])

func set_max_resource(type: Types, new_value: float) -> void:
	_max_resources[type] = new_value

func get_max_resource(type: Types):
	return _max_resources[type]

func max_out(type: Types) -> void:
	set_resource(type, max(_max_resources[type], _resources[type]))

func _on_mp_regen_timer_timeout():
	change_resource(Types.MP, 1, true)
