extends PanelContainer
class_name HotBarInventory


signal hot_bar_used(index: int)


const Slot = preload("res://assets/inventory/slot.tscn")


@export var columns := 4


@onready var _grid_container = %GridContainer as GridContainer


func _ready():
	_grid_container.columns = columns


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return
	
	if event.is_action_pressed("item_hotbar_1"):
		hot_bar_used.emit(0)
	elif event.is_action_pressed("item_hotbar_2"):
		hot_bar_used.emit(1)
	elif event.is_action_pressed("item_hotbar_3"):
		hot_bar_used.emit(2)
	elif event.is_action_pressed("item_hotbar_4"):
		hot_bar_used.emit(3)
	elif event.is_action_pressed("item_hotbar_5"):
		hot_bar_used.emit(4)
	elif event.is_action_pressed("item_hotbar_6"):
		hot_bar_used.emit(5)
	elif event.is_action_pressed("item_hotbar_7"):
		hot_bar_used.emit(6)
	elif event.is_action_pressed("item_hotbar_8"):
		hot_bar_used.emit(7)


func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(_populate_hot_bar)
	_populate_hot_bar(inventory_data)
	hot_bar_used.connect(inventory_data.use_slot_data)


func _populate_hot_bar(inventory_data: InventoryData) -> void:
	for child in _grid_container.get_children():
		child.queue_free()
	
	for slot_data in inventory_data.slot_datas:
		var slot = Slot.instantiate()
		_grid_container.add_child(slot)
		
		if slot_data:
			slot.set_slot_data(slot_data)
