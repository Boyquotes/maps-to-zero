extends CharacterBody2D
class_name Actor2D

signal defeated

var save_data: Dictionary:
	set(data):
		max_hp = data.max_hp
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
		data.speed = speed / GlobalVariables.TILE_SIZE.x
		data.jump_max_height = jump_max_height / GlobalVariables.TILE_SIZE.y
		data.jump_max_height_time = jump_max_height_time
		data.max_falling_speed = max_falling_speed / GlobalVariables.TILE_SIZE.y
		data.team = team
		data.gravity = gravity
		data.look_direction = look_direction
		data.resources = resources
		return data

@export var max_hp := 100.0
@export var speed = 18: # In terms of tiles/sec
	get:
		return speed * GlobalVariables.TILE_SIZE.x
@export var jump_max_height := 6.1 : # In terms of tiles size
	get:
		return jump_max_height * GlobalVariables.TILE_SIZE.y
@export var jump_max_height_time := 0.35 # Time between jump from ground and falling
@export var max_falling_speed := 200.0 : #In terms of tiles/sec
	get:
		return max_falling_speed * GlobalVariables.TILE_SIZE.y
@export var team : GameUtilities.Teams:
	set(value):
		if team:
			remove_from_group("team" + team)
		team = value
		add_to_group("team" + team)

@export var attack_input_listening : bool
@export var attack_can_cancel : bool
@export var attack_can_go_to_next : bool:
	set(value):
		attack_can_go_to_next = value
		if value and state_transition_request_buffer:
			request_state_transition(state_transition_request_buffer)
@export var cutscene_mode: bool:
	set(value):
		cutscene_mode = value
		if not is_ready:
			await ready
			await get_tree().create_timer(0.1).timeout
		GameManager.actors_original_cutscene_mode_value[self] = value
		
		input_enabled = not cutscene_mode
		
		state_machine.set_process(not cutscene_mode)
		state_machine.set_physics_process(not cutscene_mode)
		
		set_collision_layer_value(2, not cutscene_mode)
		velocity = Vector2.ZERO
@export var input_enabled: bool:
	set(value):
		input_enabled = value
		if value:
			input_state_machine.enter_initial_state()
		else:
			input_state_machine.transition_to("CutsceneMode")
		input_state_machine.set_physics_process(value)

@onready var input_state_machine: StateMachine = $InputStateMachine
@onready var state_machine: StateMachine = $StateMachine
@onready var gravity = 2 * jump_max_height / pow(jump_max_height_time, 2)
@onready var background_jump_area: Area2D = $BackgroundJumpArea
@onready var resources: ActorResources = $Resources
@onready var inner: Node2D = $Inner
@onready var target_manager: TargetManager = $TargetManager
@onready var animation_player: AnimationPlayer = $Inner/Visuals/AnimationPlayer

var state_transition_request_buffer
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


func _ready():
	resources.set_max_resource(ActorResources.Type.HP, max_hp)
	resources.set_resource(ActorResources.Type.HP, max_hp)
	resources.resource_depleted.connect(_on_resource_depleted)
	await get_tree().create_timer(0.1).timeout
	is_ready = true

func _physics_process(_delta):
	move_and_slide()

func unhandled_input(event: InputEvent) -> void:
	$StateMachine.unhandled_input(event)

func play_animation(animation_name : String = "", \
					_custom_blend : float = -1.0, \
					_custom_speed : float = 1.0, \
					_from_end : bool = false) -> void:
	animation_player.play("RESET")
	await animation_player.animation_finished
	animation_player.play(animation_name)


func take_damage(base_damage: float, type: ActorResources.Type=ActorResources.Type.HP, hitbox: Hitbox=null) -> void:
	if hitbox and GameUtilities.team_hostile_to(hitbox.team, team):
		ParticleSpawner.spawn_one_shot(hitbox.hit_particles, global_position, get_parent(), hitbox.hit_sfx)
		resources.change_resource(type, -base_damage)

func _on_resource_depleted(type: ActorResources.Type) -> void:
	match type:
		ActorResources.Type.HP:
			defeated.emit()
			state_machine.transition_to("Defeat")


func request_state_transition(target_state_name : String, msg: Dictionary = {}) -> bool:
	for req in state_machine.get_state(target_state_name).transition_requirements:
		if not req.is_ready:
			state_transition_request_buffer = target_state_name
			return false
	state_machine.transition_to(target_state_name, msg)
	return true


func _on_state_machine_transitioned(_to_state, _from_state):
	state_transition_request_buffer = null


func _on_tree_entered():
	GameManager.actors[str(name)] = self


func _on_tree_exited():
	GameManager.actors.erase(str(name))
