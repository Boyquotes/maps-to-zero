extends InventoryData
class_name InventoryDataHotBar



func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	if not grabbed_slot_data.item_data is ItemDataConsumable \
			and not grabbed_slot_data.item_data is ItemDataThrowable \
			and not grabbed_slot_data.item_data is ItemDataSkill:
		return null
	
	var slot_data = slot_datas[index]
	
#	var return_slot_data: SlotData
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
	else:
		slot_datas[index] = grabbed_slot_data
#		return_slot_data = slot_data
	
	inventory_updated.emit(self)
	return null


func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	if not grabbed_slot_data.item_data is ItemDataConsumable \
			and not grabbed_slot_data.item_data is ItemDataThrowable \
			and not grabbed_slot_data.item_data is ItemDataSkill:
		return null
	
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
