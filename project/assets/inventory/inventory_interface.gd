extends Control
class_name InventoryInterface


signal dropped_slot_data(slot_data: SlotData)
signal force_close


const MAX_CHEST_DISTANCE = 64.0


@onready var _inventory := %Inventory as Inventory
@onready var _equipment_inventory := %EquipmentInventory as Inventory
@onready var _external_inventory := %ExternalInventory as Inventory
@onready var _hot_bar_setter := %HotBarSetter as Inventory
@onready var _grabbed_slot := %GrabbedSlot as Slot

var _grabbed_slot_data: SlotData
var _grabbed_original_inventory_data: InventoryData
var _hot_bar_inventory_data: InventoryData
var _grabbed_slot_original_index: int
var _external_inventory_owner


func _ready() -> void:
	_external_inventory.hide()
	_grabbed_slot.hide()


func _physics_process(delta: float) -> void:
	if _grabbed_slot.visible:
		_move_grabbed_slot_to_mouse_position()
	
	var not_close_to_chest = _external_inventory_owner and \
			_external_inventory_owner.global_position.distance_to(
				GameUtilities.get_player().global_position
			) > MAX_CHEST_DISTANCE
	if not_close_to_chest:
		force_close.emit(_external_inventory_owner)
	
	if not _grabbed_slot.visible and not_close_to_chest:
		set_physics_process(false)


func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(_on_inventory_interact)
	_inventory.set_inventory_data(inventory_data)


func set_equipment_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(_on_inventory_interact)
	_equipment_inventory.set_inventory_data(inventory_data)


func set_hot_bar_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(_on_inventory_interact)
	_hot_bar_setter.set_inventory_data(inventory_data)
	_hot_bar_inventory_data = inventory_data


func set_external_inventory(external_inventory_owner) -> void:
	_external_inventory_owner = external_inventory_owner
	var inventory_data = _external_inventory_owner.inventory_data
	
	inventory_data.inventory_interact.connect(_on_inventory_interact)
	_external_inventory.set_inventory_data(inventory_data)
	
	_external_inventory.show()
	set_physics_process(true)


func clear_external_inventory() -> void:
	if _external_inventory_owner:
		var inventory_data = _external_inventory_owner.inventory_data
		
		inventory_data.inventory_interact.disconnect(_on_inventory_interact)
		_external_inventory.clear_inventory_data(inventory_data)
		
		_external_inventory.hide()
		_external_inventory_owner = null


func _on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:
	match [_grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			_grabbed_slot_data = inventory_data.grab_slot_data(index)
			_grabbed_original_inventory_data = inventory_data
			_grabbed_slot_original_index = index
		[_, MOUSE_BUTTON_LEFT]:
			if _grabbed_original_inventory_data == _hot_bar_inventory_data:
				_grabbed_slot_data = null
				return
			
			var temp := inventory_data.drop_slot_data(_grabbed_slot_data, index)
			if inventory_data == _hot_bar_inventory_data and _grabbed_original_inventory_data:
				_grabbed_original_inventory_data.drop_slot_data(_grabbed_slot_data, _grabbed_slot_original_index)
			_grabbed_slot_data = temp
			
			_grabbed_original_inventory_data = inventory_data
			_grabbed_slot_original_index = index
			if _hot_bar_inventory_data == inventory_data:
				_grabbed_original_inventory_data = null
		[null, MOUSE_BUTTON_RIGHT]:
			inventory_data.use_slot_data(index)
		[_, MOUSE_BUTTON_RIGHT]:
			_grabbed_slot_data = inventory_data.drop_single_slot_data(_grabbed_slot_data, index)
	_update_grabbed_slot()


func _update_grabbed_slot() -> void:
	if _grabbed_slot_data:
		_move_grabbed_slot_to_mouse_position()
		_grabbed_slot.show()
		_grabbed_slot.set_slot_data(_grabbed_slot_data)
		set_physics_process(true)
	else:
		_grabbed_slot.hide()
		set_physics_process(false)


func _move_grabbed_slot_to_mouse_position() -> void:
	_grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.is_pressed() \
			and _grabbed_slot_data:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_drop_all_items_in_grabbed_slot()
			MOUSE_BUTTON_RIGHT:
				_drop_single_slot()
		
		_update_grabbed_slot()


func _drop_all_items_in_grabbed_slot() -> void:
	if not _grabbed_original_inventory_data == _hot_bar_inventory_data:
		dropped_slot_data.emit(_grabbed_slot_data)
	_grabbed_original_inventory_data = null
	_grabbed_slot_data = null


func _drop_single_slot() -> void:
	dropped_slot_data.emit(_grabbed_slot_data.create_single_slot_data())
	if _grabbed_slot_data.quantity < 1:
		_grabbed_slot_data = null


func _on_visibility_changed() -> void:
	if not visible and _grabbed_slot_data:
		dropped_slot_data.emit(_grabbed_slot_data)
		_grabbed_slot_data = null
		_update_grabbed_slot()
