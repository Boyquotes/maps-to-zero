class_name ActorResources
extends Node

signal resource_changed(type, new_value, old_value, max_value)
signal resource_depleted(type)

enum Type { HP, MP, SP }
var _resources := {
	Type.HP : 0.0,
	Type.MP : 0.0,
	Type.SP : 0.0
}

var _max_resources := {
	Type.HP : 0.0,
	Type.MP : 0.0,
	Type.SP : 0.0
}


func get_resource(type: Type):
	return _resources[type]

func change_resource(type: Type, value: float, clamp_value := true) -> void:
	var new_value = _resources[type] + value
	if clamp_value:
		new_value = clampf(new_value, 0, _max_resources[type])
	set_resource(type, new_value)

func set_resource(type: Type, new_value: float) -> void:
	var old_value = _resources[type]
	_resources[type] = new_value
	resource_changed.emit(type, new_value, old_value, _max_resources[type])
	if new_value <= 0:
		resource_depleted.emit(type)

func set_max_resource(type: Type, new_value: float) -> void:
	_max_resources[type] = new_value

func get_max_resource(type: Type):
	return _max_resources[type]
