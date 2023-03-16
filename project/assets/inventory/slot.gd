extends PanelContainer
class_name Slot


signal slot_clicked(index: int, button: int)


@onready var _icon := %Icon as TextureRect
@onready var _quantity_label := %QuantityLabel as Label


var _current_slot_data: SlotData


func set_slot_data(slot_data: SlotData) -> void:
	if _current_slot_data:
		_current_slot_data.quantity_updated.disconnect(_on_slot_data_quantity_updated)
	_current_slot_data = slot_data
	_current_slot_data.quantity_updated.connect(_on_slot_data_quantity_updated)
	
	var item_data = slot_data.item_data
	_icon.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	_set_quantity_label(slot_data.quantity)


func _on_slot_data_quantity_updated(new_quantity: int, old_quantity: int) -> void:
	_set_quantity_label(new_quantity)


func _set_quantity_label(quantity: int) -> void:
	_quantity_label.text = "x%s" % quantity
	_quantity_label.visible = quantity > 1


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
