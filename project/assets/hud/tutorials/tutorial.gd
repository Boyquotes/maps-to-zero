class_name Tutorial
extends Control

signal closed

enum Screens { MOVEMENT_101, ATTACKS_101, SKILLS_101, FAST_PASS, PARKOUR_101, REST_AREAS, SAVE_POINTS } 
const SCREENS_FOLDER = "res://assets/hud/tutorials/screens/"
const TUTORIAL_FILE_NAMES = {
	Screens.MOVEMENT_101: "movement_101.tscn",
	Screens.ATTACKS_101: "attacks_101.tscn",
	Screens.SKILLS_101: "skills_101.tscn",
	Screens.FAST_PASS: "fast_pass_101.tscn",
	Screens.PARKOUR_101: "parkour_101.tscn",
	Screens.REST_AREAS: "rest_areas.tscn",
	Screens.SAVE_POINTS: "save_points.tscn",
} 

var _CLOSE_BUFFER: float = 1.0
var _page: int = 0

@onready var _close_button := %CloseButton as Button
@onready var _animation_player := %AnimationPlayer as AnimationPlayer
@onready var _pages := %Pages as Control
@onready var _num_pages :int = _pages.get_child_count()
@onready var _page_number_label := %PageNumberLabel as Label
@onready var _page_change_sfx := %PageChangeSfx as AudioStreamPlayer


static func get_tutorial_screen(screen: Screens) -> Resource:
	return load(SCREENS_FOLDER + TUTORIAL_FILE_NAMES[screen])


func _ready() -> void:
	_close_button.pressed.connect(close)
	
	for child in _pages.get_children():
		child.visible = false
	_animation_player.play("show")
	
	_disable_closing()
	await get_tree().create_timer(_CLOSE_BUFFER).timeout
	_page = -1 # Set to -1 here so that when _page is set to 0, sfx will play
	set_page(0)
	_enable_closing()


func _input(event) -> void:
	if event.is_action_pressed("hud_enter") or event.is_action_pressed("hud_select"):
		if _page < _num_pages - 1:
			next_page()
		else:
			close()
	elif event.is_action_pressed("hud_next"):
		next_page()
	elif event.is_action_pressed("hud_previous"):
		previous_page()
	elif event.is_action_pressed("hud_cancel"):
		close()


func set_page(new_page) -> void:
	var old_page = _page
	if not old_page == new_page:
		_page_change_sfx.play()
	
	_page = new_page
	for child in _pages.get_children():
		child.visible = false
	_pages.get_child(_page).visible = true
	
	if _num_pages <= 1:
		_page_number_label.visible = false
	else:
		_page_number_label.text = str(_page + 1) + " / " + str(_num_pages)
		_page_number_label.visible = true


func next_page() -> void:
	set_page(clampi(_page + 1, 0, _num_pages - 1))


func previous_page() -> void:
	set_page(clampi(_page - 1, 0, _num_pages - 1))


func close() -> void:
	set_process_input(false)
	_close_button.disabled = true
	_close_button.release_focus()
	closed.emit()
	if _animation_player.has_animation("close"):
		_animation_player.play("close")
		await _animation_player.animation_finished
	queue_free()


func _disable_closing() -> void:
	set_process_input(false)
	_close_button.disabled = true


func _enable_closing() -> void:
	set_process_input(true)
	_close_button.disabled = false
	_close_button.grab_focus()
