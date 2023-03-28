extends ItemData
class_name ItemDataThrowable


@export var thrown_item_scene: PackedScene = preload("res://assets/items/pick_up/thrown_item.tscn")
@export var force := 600.0
@export var throw_direction := Vector2.RIGHT


func use(target) -> void:
	var character := target as Character
	var pick_up_item := thrown_item_scene.instantiate() as PickUpItem
	if character and pick_up_item:
		var slot_data = SlotData.new()
		slot_data.item_data = self
		slot_data.quantity = 1
		pick_up_item.slot_data = slot_data
		character.throw_pick_up_item(pick_up_item, force, throw_direction)
	super.use(target)
