@tool
extends CharacterBody2D
class_name Character

signal stat_changed(type, new_value, old_value, max_value)
signal defeated
signal toggle_menu_requested


@export var inventory_data: InventoryData
@export var equipment_inventory_data: InventoryDataEquipment
@export var max_hp := 100.0
@export var max_mp := 300.0
@export var max_sp := 0.0
@export var speed := 10.0: # In terms of tiles/sec
	get:
		if Engine.is_editor_hint():
			return speed
		return speed * GameUtilities.TILE_SIZE.x
@export var jump_max_height := 3.2 : # In terms of tiles size
	get:
		if Engine.is_editor_hint():
			return jump_max_height
		return jump_max_height * GameUtilities.TILE_SIZE.y
@export var jump_max_height_time := 0.35 # Time between jump from ground and falling
@export var max_falling_speed := 200.0 : #In terms of tiles/sec
	get:
		if Engine.is_editor_hint():
			return max_falling_speed
		return max_falling_speed * GameUtilities.TILE_SIZE.y
@export var max_mid_air_jumps := 0
@export var max_background_jumps := 0
@export var team : GameUtilities.Teams:
	set(value):
		team = value
		if Engine.is_editor_hint():
			return
		if team:
			remove_from_group("team_" + str(team))
		add_to_group("team_" + str(team))
@export var attack_input_listening : bool:
	set(value):
		attack_input_listening = value
		if attack_request_buffer.has("action") and _input_buffer.has_action(attack_request_buffer.action):
			go_to_next_attack = true
@export var attack_can_cancel : bool:
	set(value):
		attack_can_cancel = value
		_check_and_do_attack_cancel_inputs()
@export var attack_can_go_to_next : bool:
	set(value):
		attack_can_go_to_next = value
		if go_to_next_attack and not attack_request_buffer == {}:
			var next_attack_state: State = state_machine.get_state(attack_request_buffer.state)
			for req in next_attack_state.transition_requirements:
				if not req.get_is_ready():
					return
			state_machine.transition_to(attack_request_buffer.state)
			go_to_next_attack = false
			attack_can_cancel = false

var attack_request_buffer: Dictionary
var target:
	get:
		return _target_manager.get_target()
var input_direction : Vector2 :
	get:
		return input_state_machine.state.input_direction
var look_direction : Vector2 :
	set(value):
		look_direction = value
		if sign(value.x) == 1:
			_inner.scale.x = abs(_inner.scale.x)
		elif sign(value.x) == -1:
			_inner.scale.x = -abs(_inner.scale.x)
	get:
		return look_direction if not is_equal_approx(look_direction.x, 0) else Vector2.RIGHT
var is_ready: bool = false
var save_data: Dictionary:
	set(data):
		max_hp = data.max_hp
		max_mp = data.max_mp
		max_sp = data.max_sp
		speed = data.speed
		jump_max_height = data.jump_max_height
		jump_max_height_time = data.jump_max_height_time
		max_falling_speed = data.max_falling_speed
		team = data.team
		gravity = data.gravity
		self.look_direction = data.look_direction
		_stats = data._stats
	get:
		var data = {}
		data.max_hp = max_hp
		data.max_mp = max_mp
		data.max_sp = max_sp
		data.speed = speed / GameUtilities.TILE_SIZE.x
		data.jump_max_height = jump_max_height / GameUtilities.TILE_SIZE.y
		data.jump_max_height_time = jump_max_height_time
		data.max_falling_speed = max_falling_speed / GameUtilities.TILE_SIZE.y
		data.team = team
		data.gravity = gravity
		data.look_direction = look_direction
		data._stats = _stats
		return data
var go_to_next_attack : bool:
	set(value):
		go_to_next_attack = value
		if value and attack_can_go_to_next and not attack_request_buffer == {}:
			var next_attack_state: State = state_machine.get_state(attack_request_buffer.state)
			for req in next_attack_state.transition_requirements:
				if not req.get_is_ready():
					return
			state_machine.transition_to(attack_request_buffer.state)
			go_to_next_attack = false
			attack_can_cancel = false
var current_mid_air_jumps: int
var current_background_jumps: int


@onready var input_state_machine := %InputStateMachine as StateMachine
@onready var state_machine := %StateMachine as StateMachine
@onready var gravity := 2 * jump_max_height / pow(jump_max_height_time, 2) # Gravity at start of jump
@onready var _stats := %CharacterStats as CharacterStats
@onready var _inner := %Inner as Node2D
@onready var _animation_player := _inner.get_node("Visuals/AnimationPlayer") as AnimationPlayer if _inner else null
@onready var _animation_effects := _animation_player.get_node("AnimationEffects") as AnimationPlayer if _animation_player else null
@onready var _background_jump_area := %BackgroundJumpArea as Area2D
@onready var _target_manager := %TargetManager as TargetManager
@onready var _input_buffer := %InputBuffer as InputBuffer
@onready var _soft_collision := %SoftCollision as SoftCollision
@onready var _hurtbox := %Hurtbox as Area2D
@onready var _hud := %CharacterHUD as CharacterHUD


func _ready():
	if Engine.is_editor_hint():
		is_ready = true
		emit_signal("ready")
		return
	
	if input_state_machine:
		input_state_machine.init(self)
	if state_machine:
		state_machine.init(self)
	if _hud:
		_hud.init(self)
	
	if _stats:
		_stats.stat_changed.connect(_on_stat_changed)
		_stats.set_max_stat(CharacterStats.Types.HP, max_hp)
		_stats.set_stat(CharacterStats.Types.HP, max_hp)
		_stats.set_max_stat(CharacterStats.Types.MP, max_mp)
		_stats.set_stat(CharacterStats.Types.MP, max_mp)
		_stats.set_max_stat(CharacterStats.Types.SP, max_sp)
		_stats.set_stat(CharacterStats.Types.SP, max_sp)
	
	if _hurtbox:
		_hurtbox.area_entered.connect(_on_hurtbox_entered)
		_reset_hurtbox_collision()
	
	for child in GameUtilities.get_all_subchildren(self):
		if child is Hitbox:
			child.set_character(self)
			child.set_team(team)
	
	is_ready = true
	emit_signal("ready")


func _physics_process(delta: float):
	if Engine.is_editor_hint():
		return
	move_and_slide()
	if _soft_collision.is_colliding():
		move_and_collide(_soft_collision.get_push_vector() * delta)


func _on_tree_entered():
	if Engine.is_editor_hint():
		return
	GameManager.actors[str(name)] = self


func _on_tree_exited():
	if Engine.is_editor_hint():
		return
	GameManager.actors.erase(str(name))


## This function will immediately consume input without buffering inputs.
## This is only for inputs that the character should ALWAYS be able to handle,
## regardless of state, such as handling character UI elements
func _unhandled_input(event) -> void:
	if event.is_action_pressed("menu"):
		toggle_menu_requested.emit()


## This function handles input from the input buffer.
## Use this to handle primary gameplay actions such as moving and attacking.
func unhandled_input(event: InputEvent) -> void:
	_input_buffer.add_input(event)
	state_machine.unhandled_input(event)
	
	_check_and_do_attack_cancel_inputs()


func play_animation(animation_name:="", reset:=true) -> void:
	if Engine.is_editor_hint():
		_animation_player.stop() # Reset animation
	if reset:
		_animation_player.play("RESET")
		await _animation_player.animation_finished
	_animation_player.play(animation_name)


func play_animation_effect(effect_name:="") -> void:
	if _animation_effects and _animation_effects.has_animation(effect_name):
		_animation_effects.play(effect_name)


func take_damage(value: float, type: CharacterStats.Types=CharacterStats.Types.HP):
	_stats.change_stat_by(type, -value)


func defeat() -> void:
	defeated.emit()
	state_machine.transition_to("Defeat")


func heal(by: float) -> void:
	_stats.change_stat_by(CharacterStats.Types.HP, by)


func request_state_transition(target_state_name : String, msg: Dictionary = {}):
	var target_state := state_machine.get_state(target_state_name)
	for req in target_state.transition_requirements:
		if not req.get_is_ready():
			return
	state_machine.transition_to(target_state_name, msg)


func request_attack_transition(target_state_dictionary : Dictionary, _msg: Dictionary = {}):
	attack_request_buffer = target_state_dictionary
	var target_state := state_machine.get_state(target_state_dictionary.state)
	for req in target_state.transition_requirements:
		if not req.get_is_ready():
			return
	if attack_input_listening:
		go_to_next_attack = true


func enable_input() -> void:
	input_state_machine.reset()


func disable_input() -> void:
	input_state_machine.transition_to("NoInput")


func get_target() -> Character:
	return _target_manager.get_target()


func get_direction_to_target() -> Vector2:
	return _target_manager.get_direction_to()


func get_distance_from_target() -> float:
	return _target_manager.get_distance()


func is_on_background_jump_terrain() -> bool:
	return _background_jump_area.has_overlapping_bodies() \
			or _background_jump_area.has_overlapping_areas()


func get_attack(attack_name:String) -> Node2D:
	return _inner.get_node("Attacks/" + str(attack_name))


func get_stat(type: CharacterStats.Types):
	return _stats.get_stat(type)


func get_max_stat(type: CharacterStats.Types):
	return _stats.get_max_stat(type)


func change_stat_by(type: CharacterStats.Types, value, clamp_value := true) -> void:
	_stats.change_stat_by(type, value, clamp_value)


func get_state(state_name: StringName) -> State:
	return state_machine.get_state(state_name)


func get_item_drop_position() -> Vector2:
	return global_position + look_direction * 32


func use_item_slot_data(item_slot_data: SlotData) -> void:
	item_slot_data.item_data.use(self)


func _on_state_machine_transitioned(_to_state, _from_state):
	attack_request_buffer = { }


func _on_stat_changed(type: CharacterStats.Types, new_value, old_value, max_value):
	stat_changed.emit(type, new_value, old_value, max_value)
	
	match type:
		CharacterStats.Types.HP:
			if new_value <= 0:
				defeat()



func _check_and_do_attack_cancel_inputs() -> void:
	if Engine.is_editor_hint():
		return
	if not attack_can_cancel or not _input_buffer:
		return
	
	if _input_buffer.has_action("jump"):
		if is_on_floor():
			state_machine.transition_to("Air", {do_jump = true})
			attack_can_cancel = false
		else:
			if state_machine.state.name == "Dash" \
					or state_machine.get_state("Air").can_background_jump() \
					or state_machine.get_state("Air").can_mid_air_jump():
				state_machine.transition_to("Air", {do_jump = true})
				attack_can_cancel = false
	elif _input_buffer.has_action("move_down"):
		state_machine.transition_to("Stomp")
		attack_can_cancel = false


func _on_hurtbox_entered(area: Area2D) -> void:
	var hitbox := area as Hitbox
	if not hitbox or not GameUtilities.team_hostile_to(hitbox.team, team):
		return
	
	take_damage(hitbox.base_value, CharacterStats.Types.HP)
	
	ParticleSpawner.spawn_one_shot(hitbox.hit_particles, global_position, get_parent())
	
	var hit_sfx := AudioStreamPlayer2D.new() as AudioStreamPlayer2D
	hit_sfx.name = "AudioStreamPlayer2d"
	hit_sfx.stream = hitbox.hit_sfx
	hit_sfx.bus = "Sfx"
	hit_sfx.finished.connect(hit_sfx.queue_free)
	add_child(hit_sfx)
	hit_sfx.global_position = global_position
	hit_sfx.play()
	
	if hitbox.frame_freeze_duration_milliseconds > 0:
		FrameFreeze.request(hitbox.frame_freeze_duration_milliseconds)
	if hitbox.screen_shake_trauma > 0:
		GameManager.screen_shake(hitbox.screen_shake_trauma)
	
	hitbox.confirm_hit(self)


func _reset_hurtbox_collision() -> void:
	_hurtbox.monitoring = true
	_hurtbox.monitorable = false
	
	# Set all collision layers and masks off
	_hurtbox.collision_layer = 0
	_hurtbox.collision_mask = 0
	# Then only enable the hitbox/hurtbox physics mask
	_hurtbox.set_collision_layer_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, false)
	_hurtbox.set_collision_mask_value(GameUtilities.PhysicsLayers.HITBOXES_HURTBOXES, true)
