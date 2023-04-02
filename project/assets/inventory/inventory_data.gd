extends Resource
class_name InventoryData


signal inventory_updated(inventory_data: InventoryData)
signal inventory_interact(inventory_data: InventoryData, index: int, button: int)


@export var slot_datas: Array[SlotData]


func grab_slot_data(index: int) -> SlotData:
	var slot_data = slot_datas[index]
	
	if slot_data:
		slot_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null


func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	if  grabbed_slot_data.item_data is ItemDataSkill:
		return grabbed_slot_data
	
	var slot_data = slot_datas[index]
	
	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data
	
	inventory_updated.emit(self)
	return return_slot_data


func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	if  grabbed_slot_data.item_data is ItemDataSkill:
		return grabbed_slot_data
	
	var slot_data = slot_datas[index]
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
	inventory_updated.emit(self)
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null


func use_slot_data(index: int) -> void:
	var slot_data = slot_datas[index]
	
	if not slot_data:
		return
	
	var player := GameUtilities.get_player()
	var item_data = slot_data.item_data
	if player.can_use_item(item_data):
		if item_data is ItemDataConsumable \
				or item_data is ItemDataThrowable:
			slot_data.quantity -= 1
			if slot_data.quantity < 1:
				slot_datas[index] = null
	
	player.use_item_slot_data(slot_data)
	
	inventory_updated.emit(self)


func pick_up_slot_data(slot_data: SlotData) -> bool:
	# First find first mergeable slot
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data):
			slot_datas[index].fully_merge_with(slot_data)
			inventory_updated.emit(self)
			return true
	
	# Find first free slot to put picked up item
	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			inventory_updated.emit(self)
			return true
	
	return false


func on_slot_clicked(index: int, button: int) -> void:
	inventory_interact.emit(self, index, button)


func get_slot_data(index: int) -> SlotData:
	return slot_datas[index]


func remove_slot_data(slot_data: SlotData) -> void:
	slot_datas.remove_at(slot_datas.find(slot_data))


func clear_slot_data(slot_data: SlotData) -> void:
	slot_datas[slot_datas.find(slot_data)] = null