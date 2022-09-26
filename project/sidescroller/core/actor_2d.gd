extends CharacterBody2D
class_name Actor2D

signal defeated

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

@onready var state_machine: StateMachine = $StateMachine
@onready var gravity = 2 * jump_max_height / pow(jump_max_height_time, 2)
@onready var background_jump_area: Area2D = $BackgroundJumpArea
@onready var resources: ActorResources = $Resources
@onready var inner: Node2D = $Inner
@onready var target_manager: TargetManager = $TargetManager

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


func _ready():
	resources.set_max_resource(ActorResources.Type.HP, max_hp)
	resources.set_resource(ActorResources.Type.HP, max_hp)
	resources.resource_depleted.connect(_on_resource_depleted)

func _physics_process(_delta):
	move_and_slide()

func unhandled_input(event: InputEvent) -> void:
	$StateMachine.unhandled_input(event)

func play_animation(animation_name : String = "", \
					_custom_blend : float = -1.0, \
					_custom_speed : float = 1.0, \
					_from_end : bool = false) -> void:
	$Inner/Visuals/AnimationPlayer.play(animation_name)


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
