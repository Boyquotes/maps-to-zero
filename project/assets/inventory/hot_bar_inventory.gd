extends PanelContainer
class_name HotBarInventory


const Slot = preload("res://assets/inventory/hot_bar_slot.tscn")


@export var columns := 4
@export var use_input := true


var _character: Character
var _slots: Dictionary # Of type <SlotData, Slot>
var _slots_array: Array[Slot]
var _inventory_data: InventoryData


func _ready():
	set_process(false)
	set_process_input(use_input)


func _input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return
	if event.is_action_pressed("item_hotbar_1"):
		_use_slot_data(0)
	elif event.is_action_pressed("item_hotbar_2"):
		_use_slot_data(1)
	elif event.is_action_pressed("item_hotbar_3"):
		_use_slot_data(2)
	elif event.is_action_pressed("item_hotbar_4"):
		_use_slot_data(3)
	elif event.is_action_pressed("item_hotbar_5"):
		_use_slot_data(4)
	elif event.is_action_pressed("item_hotbar_6"):
		_use_slot_data(5)
	elif event.is_action_pressed("item_hotbar_7"):
		_use_slot_data(6)
	elif event.is_action_pressed("item_hotbar_8"):
		_use_slot_data(7)


func set_character(character: Character) -> void:
	_character = character
	_character.item_used.connect(_on_item_used)
	set_process(true)


func set_inventory_data(inventory_data: InventoryData) -> void:
	_inventory_data = inventory_data
	inventory_data.inventory_updated.connect(_populate_hot_bar)
	_populate_hot_bar(inventory_data)


func _populate_hot_bar(inventory_data: InventoryData) -> void:
	_slots = {}
	_slots_array = []
	var index = 0
	for slot_data in inventory_data.slot_datas:
		var slot := get_node("%HotBarSlot" + str(index + 1)) as Slot
		
		slot.set_slot_data(slot_data)
		if slot_data:
			if not slot_data.removed_from_inventory.is_connected(_on_slot_removed_from_inventory):
				slot_data.removed_from_inventory.connect(_on_slot_removed_from_inventory)
		_slots[slot_data] = slot
		_slots_array.push_back(slot)
		
		index += 1
	
	for i in range(8):
		var slot := _slots_array[i] as Slot
		if not slot.slot_clicked.is_connected(inventory_data.on_slot_clicked):
			slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		slot._index = i
		var input_key_label := slot.get_node("InputKeyContainer/Control/InputKeyLabel") as Label
		match i:
			0:
				input_key_label.text = "A"
			1:
				input_key_label.text = "S"
			2:
				input_key_label.text = "D"
			3:
				input_key_label.text = "C"
			4:
				input_key_label.text = "Q"
			5:
				input_key_label.text = "W"
			6:
				input_key_label.text = "E"
			7:
				input_key_label.text = "R"


func _on_item_used(item_data: ItemData) -> void:
	print_debug(item_data.name)


func _process(delta):
	for slot_data in _inventory_data.slot_datas:
		if not slot_data:
			continue
		var slot := _slots[slot_data] as Slot
		var item_data := slot_data.item_data as ItemData
		if _character._item_cooldowns.has(item_data):
			var cooldown = _character._item_cooldowns[item_data].time_left
			slot.set_cooldown_label(cooldown)
		slot.set_cover_visible(_character.can_use_item(item_data))


func _on_slot_removed_from_inventory(slot_data: SlotData) -> void:
	_inventory_data.clear_slot_data(slot_data)
	_populate_hot_bar(_inventory_data)


func _use_slot_data(index: int) -> void:
	_inventory_data.use_slot_data(index)
