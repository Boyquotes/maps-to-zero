extends Trigger
class_name ItemChestTrigger

signal toggle_inventory(external_inventory_owner)


@export var inventory_data: InventoryData


func _ready():
	add_to_group("item_chest_triggers")


func trigger(_dummy_var=null) -> void:
	super.trigger()
	toggle_inventory.emit(self)
