extends CanvasLayer
class_name SidescrollerHUD

signal show_finished
signal hide_finished

@onready var _hp_bar := %HPBar as TextureProgressBar
@onready var _mp_bar := %MPBar as TextureProgressBar
@onready var _sp_bar := %SPBar as TextureProgressBar
@onready var _inventory_interface := %InventoryInterface as InventoryInterface
@onready var _hot_bar_inventory := %HotBarInventory as HotBarInventory
@onready var _animation_player := %AnimationPlayer as AnimationPlayer
@onready var _pause_menu := $PauseMenu
@onready var _player_hud := %PlayerHUD as Control


var hud_displaying : bool = true
var _paused : bool = false


func _ready():
	Events.player_resource_changed.connect(_on_player_resource_changed)
	_inventory_interface.hide()
	
	_pause_menu.resume.connect(_unpause)


func show_hud(duration:= 1.0):
	if hud_displaying:
		show_finished.emit()
		return
	hud_displaying = true
	if is_equal_approx(duration, 0.0):
		_animation_player.speed_scale = 1.0
		_animation_player.play("RESET")
		_player_hud.visible = true
		show_finished.emit()
	else:
		_animation_player.speed_scale = 1.0 / duration
		_animation_player.play("show")
		await _animation_player.animation_finished
		show_finished.emit()


func hide_hud(duration:= 1.0):
	hud_displaying = false
	if is_equal_approx(duration, 0.0):
		_player_hud.visible = false
		hide_finished.emit()
	else:
		_animation_player.speed_scale = 1.0 / duration
		_animation_player.play("hide")
		await _animation_player.animation_finished
		hide_finished.emit()


func toggle_menu() -> void:
#	toggle_inventory_interface()
	_toggle_pause_menu()



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


func set_character(character: Character) -> void:
	_inventory_interface.set_inventory_data(character.inventory_data)
	_inventory_interface.set_equipment_inventory_data(character.equipment_inventory_data)
	_hot_bar_inventory.set_character(character)
	_hot_bar_inventory.set_inventory_data(character.hot_bar_inventory_data)
	_inventory_interface.set_hot_bar_data(character.hot_bar_inventory_data)


func set_skills_data(inventory_data: InventoryData) -> void:
	_inventory_interface.set_skills_data(inventory_data)


func _on_player_resource_changed(type, new_value, _old_value, max_value) -> void:
	match type:
		CharacterStats.Types.HP:
			_hp_bar.max_value = max_value
			_hp_bar.value = new_value
		CharacterStats.Types.MP:
			_mp_bar.max_value = max_value
			_mp_bar.value = new_value
		CharacterStats.Types.SP:
			for i in range(3):
				if i + 1 <= new_value:
					get_node("%SP" + str(i + 1) + "/Glow").modulate = Color(1, 0.09019608050585, 0.64705884456635)
					get_node("%SP" + str(i + 1) + "/Sprite").modulate = Color.WHITE
				else:
					get_node("%SP" + str(i + 1) + "/Glow").modulate = Color.BLACK
					get_node("%SP" + str(i + 1) + "/Sprite").modulate = Color(0.27058824896812, 0.27058824896812, 0.27058824896812)


func _toggle_pause_menu() -> void:
	_paused = not _paused
	if _paused:
		_pause_menu.open_pause_menu()
	else:
		_pause_menu.close_pause_menu()


func _unpause() -> void:
	_paused = false
