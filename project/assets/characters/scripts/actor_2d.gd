@tool
extends CharacterBody2D
class_name Actor2D

signal defeated

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
@export var team : GameUtilities.Teams:
	set(value):
		if team:
			remove_from_group("team_" + str(team))
		team = value
		add_to_group("team_" + str(team))
@export var attack_input_listening : bool:
	set(value):
		attack_input_listening = value
		if attack_request_buffer.has("action") and input_buffer.has_action(attack_request_buffer.action):
			go_to_next_attack = true
@export var attack_can_cancel : bool:
	set(value):
		attack_can_cancel = value
		_check_and_do_attack_cancel_inputs()
@export var attack_can_go_to_next : bool:
	set(value):
		attack_can_go_to_next = value
		if go_to_next_attack and not attack_request_buffer == {}:
			for req in state_machine.get_state(attack_request_buffer.state).transition_requirements:
				if not req.is_ready:
					return
			state_machine.transition_to(attack_request_buffer.state)
			go_to_next_attack = false
			attack_can_cancel = false

var attack_request_buffer: Dictionary
var target:
	get:
		return target_manager.get_target()
var input_direction : Vector2 :
	get:
		return $InputStateMachine.state.input_direction
var look_direction : Vector2 :
	set(value):
		look_direction = value
		if sign(value.x) == 1:
			$Inner.scale.x = abs($Inner.scale.x)
		elif sign(value.x) == -1:
			$Inner.scale.x = -abs($Inner.scale.x)
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
		resources = data.resources
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
		data.resources = resources
		return data
var go_to_next_attack : bool:
	set(value):
		go_to_next_attack = value
		if value and attack_can_go_to_next and not attack_request_buffer == {}:
			for req in state_machine.get_state(attack_request_buffer.state).transition_requirements:
				if not req.is_ready:
					return
			state_machine.transition_to(attack_request_buffer.state)
			go_to_next_attack = false
			attack_can_cancel = false


@onready var input_state_machine := $InputStateMachine as StateMachine
@onready var state_machine := $StateMachine as StateMachine
@onready var gravity := 2 * jump_max_height / pow(jump_max_height_time, 2)
@onready var background_jump_area := $BackgroundJumpArea as Area2D
@onready var resources := $Resources as ActorResources
@onready var inner := $Inner as Node2D
@onready var target_manager := $TargetManager as TargetManager
@onready var animation_player := $Inner/Visuals/AnimationPlayer as AnimationPlayer
@onready var animation_effects: AnimationPlayer = $Inner/Visuals/AnimationPlayer/AnimationEffects as AnimationPlayer if $Inner/Visuals/AnimationPlayer.has_node("AnimationEffects") else null
@onready var input_buffer := $InputBuffer as InputBuffer
@onready var soft_collision := $SoftCollision as SoftCollision


func _ready():
	if Engine.is_editor_hint():
		is_ready = true
		emit_signal("ready")
		return
	resources.set_max_resource(ActorResources.Type.HP, max_hp)
	resources.set_resource(ActorResources.Type.HP, max_hp)
	resources.set_max_resource(ActorResources.Type.MP, max_mp)
	resources.set_resource(ActorResources.Type.MP, max_mp)
	resources.set_max_resource(ActorResources.Type.SP, max_sp)
	resources.set_resource(ActorResources.Type.SP, max_sp)
	resources.resource_depleted.connect(_on_resource_depleted)
	await get_tree().create_timer(0.01).timeout
	is_ready = true
	emit_signal("ready")


func _physics_process(delta: float):
	if Engine.is_editor_hint():
		return
	move_and_slide()
	if soft_collision.is_colliding():
		move_and_collide(soft_collision.get_push_vector() * delta)


func unhandled_input(event: InputEvent) -> void:
	input_buffer.add_input(event)
	state_machine.unhandled_input(event)
	
	_check_and_do_attack_cancel_inputs()


func play_animation(animation_name : String = "", \
					_custom_blend : float = -1.0, \
					_custom_speed : float = 1.0, \
					_from_end : bool = false) -> void:
	if Engine.is_editor_hint():
		animation_player.stop() # Reset animation
	animation_player.play("RESET")
	await animation_player.animation_finished
	animation_player.play(animation_name)


func take_damage(base_damage: float, type: ActorResources.Type=ActorResources.Type.HP, hitbox: Hitbox=null) -> bool:
	if hitbox and GameUtilities.team_hostile_to(hitbox.team, team):
		ParticleSpawner.spawn_one_shot(hitbox.hit_particles, global_position, get_parent())
		
		var hit_sfx := AudioStreamPlayer2D.new() as AudioStreamPlayer2D
		hit_sfx.name = "AudioStreamPlayer2d"
		hit_sfx.stream = hitbox.hit_sfx
		hit_sfx.bus = "Sfx"
		hit_sfx.finished.connect(hit_sfx.queue_free)
		add_child(hit_sfx)
		hit_sfx.global_position = global_position
		hit_sfx.play()
		
		resources.change_resource(type, -base_damage)
		return true
	return false


func defeat() -> void:
	defeated.emit()
	state_machine.transition_to("Defeat")


func request_state_transition(target_state_name : String, msg: Dictionary = {}):
	for req in state_machine.get_state(target_state_name).transition_requirements:
		if not req.is_ready:
			return
	state_machine.transition_to(target_state_name)


func request_attack_transition(target_state : Dictionary, msg: Dictionary = {}):
	attack_request_buffer = target_state
	for req in state_machine.get_state(target_state.state).transition_requirements:
		if not req.is_ready:
			return
	
	if attack_input_listening:
		go_to_next_attack = true


func enable_input() -> void:
	input_state_machine.reset()


func disable_input() -> void:
	input_state_machine.transition_to("NoInput")


func _on_state_machine_transitioned(_to_state, _from_state):
	attack_request_buffer = { }


func _on_resource_depleted(type: ActorResources.Type) -> void:
	match type:
		ActorResources.Type.HP:
			defeat()


func _on_tree_entered():
	if Engine.is_editor_hint():
		return
	GameManager.actors[str(name)] = self


func _on_tree_exited():
	if Engine.is_editor_hint():
		return
	GameManager.actors.erase(str(name))


func _check_and_do_attack_cancel_inputs() -> void:
	if Engine.is_editor_hint():
		return
	if not attack_can_cancel or not input_buffer:
		return
	
	if input_buffer.has_action("jump"):
		if is_on_floor():
			state_machine.transition_to("Air", {do_jump = true})
			attack_can_cancel = false
		else:
			if state_machine.state.name == "Dash" or \
			state_machine.get_state("Air").can_background_jump() or state_machine.get_state("Air").can_mid_air_jump():
				state_machine.transition_to("Air", {do_jump = true})
				attack_can_cancel = false
	elif input_buffer.has_action("move_down"):
		state_machine.transition_to("Stomp")
		attack_can_cancel = false
