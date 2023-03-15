extends PanelContainer
class_name Inventory


const Slot = preload("res://assets/inventory/slot.tscn")


@onready var item_grid := %ItemGrid as GridContainer


func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(_populate_item_grid)
	_populate_item_grid(inventory_data)


func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(_populate_item_grid)


func _populate_item_grid(inventory_data: InventoryData) -> void:
	for child in item_grid.get_children():
		child.queue_free()
	
	for slot_data in inventory_data.slot_datas:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
