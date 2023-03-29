extends PanelContainer
class_name Slot


signal slot_clicked(index: int, button: int)


@onready var _icon := %Icon as TextureRect
@onready var _quantity_label := %QuantityLabel as Label
@onready var _cool_down_label := %CoolDownLabel as Label
@onready var _cover := %Cover as ColorRect if has_node("%Cover") else null


var current_slot_data: SlotData
var _index := -1:
	get:
		if _index < 0:
			return get_index()
		else:
			return _index


func set_slot_data(slot_data: SlotData) -> void:
	if current_slot_data:
		current_slot_data.quantity_updated.disconnect(_on_slot_data_quantity_updated)
		current_slot_data.removed_from_inventory.disconnect(_on_removed_from_inventory)
	
	if slot_data == null:
		current_slot_data = slot_data
		_icon.texture = null
		tooltip_text = ""
		_set_quantity_label(0)
		set_cooldown_label(0)
		set_cover_visible(false)
		return
	
	current_slot_data = slot_data
	current_slot_data.quantity_updated.connect(_on_slot_data_quantity_updated)
	current_slot_data.removed_from_inventory.connect(_on_removed_from_inventory)
	
	var item_data = slot_data.item_data
	_icon.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	_set_quantity_label(slot_data.quantity)


func set_cooldown_label(time_left: float) -> void:
	if time_left > 0:
		_cool_down_label.visible = true
		_cool_down_label.text = str(ceili(time_left))
	else:
		_cool_down_label.visible = false


func set_cover_visible(visible: bool) -> void:
	_cover.visible = not visible


func _on_slot_data_quantity_updated(new_quantity: int, _old_quantity: int) -> void:
	_set_quantity_label(new_quantity)


func _set_quantity_label(quantity: int) -> void:
	_quantity_label.text = "x%s" % quantity
	_quantity_label.visible = quantity > 1


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		slot_clicked.emit(_index, event.button_index)


func _on_removed_from_inventory(slot_data: SlotData) -> void:
	set_cover_visible(false)
	_set_quantity_label(0)
