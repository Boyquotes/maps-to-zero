extends PanelContainer
class_name Slot


signal slot_clicked(index: int, button: int)


@onready var _icon := %Icon as TextureRect
@onready var _quantity_label := %QuantityLabel as Label


func set_slot_data(slot_data: SlotData) -> void:
	var item_data = slot_data.item_data
	_icon.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	_quantity_label.text = "x%s" % slot_data.quantity
	_quantity_label.visible = slot_data.quantity > 1


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
