extends Control

@onready var hp_bar : ProgressBar = $HP/ProgressBar


func init(character: Actor2D):
	var resources = character._resources
	resources.resource_changed.connect(_on_resource_changed)
	_on_resource_changed(ActorResources.Type.HP, \
			resources.get_resource(ActorResources.Type.HP), \
			resources.get_resource(ActorResources.Type.HP), \
			resources.get_max_resource(ActorResources.Type.HP))


func _on_resource_changed(type: ActorResources.Type, new_value, old_value, max_value) -> void:
	match type:
		ActorResources.Type.HP:
			hp_bar.max_value = max_value
			hp_bar.value = new_value
#		ActorResources.Type.MP:
#			mp_bar.max_value = max_value
#			mp_bar.value = new_value
#		ActorResources.Type.SP:
#			sp_bar.max_value = max_value
#			sp_bar.value = new_value
