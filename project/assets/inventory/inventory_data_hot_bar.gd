extends InventoryData
class_name InventoryDataHotBar



func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	if not grabbed_slot_data.item_data is ItemDataConsumable \
			and not grabbed_slot_data.item_data is ItemDataThrowable \
			and not grabbed_slot_data.item_data is ItemDataSkill:
		return null
	
	var slot_data = slot_datas[index]
	if slot_data == grabbed_slot_data:
		return null
	
	for _slot_data in slot_datas:
		if _slot_data == grabbed_slot_data:
			clear_slot_data(_slot_data)
	slot_datas[index] = grabbed_slot_data
	
	inventory_updated.emit(self)
	return null


func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	return grabbed_slot_data
