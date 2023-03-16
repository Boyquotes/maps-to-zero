extends Control
class_name SidescrollerHUD

signal show_finished
signal hide_finished

@onready var _hp_bar := %HPBar as TextureProgressBar
@onready var _mp_bar := %MPBar as TextureProgressBar
@onready var _sp_bar := %SPBar as TextureProgressBar
@onready var _inventory_interface := %InventoryInterface as InventoryInterface
@onready var _hot_bar_inventory := %HotBarInventory as HotBarInventory
@onready var _animation_player := %AnimationPlayer as AnimationPlayer


var hud_displaying : bool = true


func _ready():
	Events.player_resource_changed.connect(_on_player_resource_changed)
	_inventory_interface.hide()


func show_hud(duration:= 1.0):
	if hud_displaying:
		show_finished.emit()
		return
	hud_displaying = true
	if is_equal_approx(duration, 0.0):
		_animation_player.speed_scale = 1.0
		_animation_player.play("RESET")
		$Display/PlayerHUD.visible = true
		show_finished.emit()
	else:
		_animation_player.speed_scale = 1.0 / duration
		_animation_player.play("show")
		await _animation_player.animation_finished
		show_finished.emit()


func hide_hud(duration:= 1.0):
	hud_displaying = false
	if is_equal_approx(duration, 0.0):
		$Display/PlayerHUD.visible = false
		hide_finished.emit()
	else:
		_animation_player.speed_scale = 1.0 / duration
		_animation_player.play("hide")
		await _animation_player.animation_finished
		hide_finished.emit()


func toggle_menu() -> void:
	# TODO: For now just toggle the inventory
	toggle_inventory_interface()


func toggle_inventory_interface(external_inventory_owner=null) -> void:
	_inventory_interface.visible = not _inventory_interface.visible
	
	if _inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_hot_bar_inventory.hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		_hot_bar_inventory.show()
	
	if external_inventory_owner and _inventory_interface.visible:
		_inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		_inventory_interface.clear_external_inventory()


func set_player_inventory_data(inventory_data: InventoryData) -> void:
	_inventory_interface.set_inventory_data(inventory_data)


func set_equipment_inventory_data(inventory_data: InventoryData) -> void:
	_inventory_interface.set_equipment_inventory_data(inventory_data)


func set_hot_bar_inventory_data(inventory_data: InventoryData) -> void:
	_hot_bar_inventory.set_inventory_data(inventory_data)
	_inventory_interface.set_hot_bar_data(inventory_data)


func _on_player_resource_changed(type, new_value, _old_value, max_value) -> void:
	match type:
		CharacterStats.Types.HP:
			_hp_bar.max_value = max_value
			_hp_bar.value = new_value
		CharacterStats.Types.MP:
			_mp_bar.max_value = max_value
			_mp_bar.value = new_value
		CharacterStats.Types.SP:
			_sp_bar.max_value = max_value
			_sp_bar.value = new_value
