extends Resource
class_name ItemData


signal used(item_data: ItemData)


@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var texture: Texture
@export var cooldown := 0.0


func use(_target) -> void:
	used.emit(self)
