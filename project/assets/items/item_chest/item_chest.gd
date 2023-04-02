extends Interactable
class_name ItemChest


signal character_leaves_interaction_area


@export var inventory_data: InventoryData



func _ready():
	super._ready()
	
	character_leaves_interaction_area.connect(Events.on_character_leaves_item_chest)
	
	_interaction_area.area_exited.connect(_on_interaction_area_2d_area_exited)
	
	var item_chest_trigger := ItemChestTrigger.new()
	item_chest_trigger.inventory_data = inventory_data
	_triggers_node.add_child(item_chest_trigger)


func _on_interaction_area_2d_area_exited(area):
	character_leaves_interaction_area.emit()
