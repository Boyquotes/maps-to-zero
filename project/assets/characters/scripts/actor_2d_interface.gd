extends Control

@onready var hp_bar : ProgressBar = $HP/ProgressBar


func _ready():
	await owner.ready
	var resources = owner.resources
	resources.resource_changed.connect(update_resource)
	update_resource(ActorResources.Type.HP, resources.get_resource(ActorResources.Type.HP), resources.get_resource(ActorResources.Type.HP), resources.get_max_resource(ActorResources.Type.HP))

func update_resource(type: ActorResources.Type, new_value, _old_value, max_value) -> void:
	match type:
		ActorResources.Type.HP:
			hp_bar.max_value = max_value
			hp_bar.value = new_value
