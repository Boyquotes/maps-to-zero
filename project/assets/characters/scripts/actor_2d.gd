extends CharacterBody2D
class_name Actor2D

signal defeated

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

@export var max_hp := 100.0
@export var max_mp := 300.0
@export var max_sp := 0.0
@export var speed = 10: # In terms of tiles/sec
	get:
		return speed * GameUtilities.TILE_SIZE.x
@export var jump_max_height := 3.2 : # In terms of tiles size
	get:
		return jump_max_height * GameUtilities.TILE_SIZE.y
@export var jump_max_height_time := 0.35 # Time between jump from ground and falling
@export var max_falling_speed := 200.0 : #In terms of tiles/sec
	get:
		return max_falling_speed * GameUtilities.TILE_SIZE.y
@export var team : GameUtilities.Teams:
	set(value):
		if team:
			remove_from_group("team" + str(team))
		team = value
		add_to_group("team" + str(team))

@export var attack_input_listening : bool:
	set(value):
		attack_input_listening = value
		if attack_request_buffer.has("input") and input_buffer.has_action(attack_request_buffer.input):
			go_to_next_attack = true
@export var attack_can_cancel : bool:
	set(value):
		attack_can_cancel = value
		if value and input_buffer and input_buffer.has_action("jump"):
			state_machine.transition_to("Air", {do_jump = true})
			attack_can_cancel = false
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

@export var cutscene_mode: bool
func set_cutscene_mode(value: bool) -> void:
	cutscene_mode = value
	if not is_ready:
		await ready
	if cutscene_mode:
		state_machine.transition_to("Cutscene")
	else:
		state_machine.transition_to("Idle")
	GameManager.actors_original_cutscene_mode_value[self] = value
	
	input_enabled = not cutscene_mode
	
	state_machine.set_process(not cutscene_mode)
	state_machine.set_physics_process(not cutscene_mode)
	set_collision_layer_value(2, not cutscene_mode)
	velocity = Vector2.ZERO
	
	if state_machine.state.name == "Defeat":
		state_machine.enter_initial_state()

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
@onready var animation_effects: AnimationPlayer = $Inner/Visuals/AnimationPlayer/AnimationEffects if $Inner/Visuals/AnimationPlayer.has_node("AnimationEffects") else null
@onready var input_buffer: InputBuffer = $InputBuffer
@onready var soft_collision: SoftCollision = $SoftCollision

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


func _ready():
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

func _physics_process(_delta):
	move_and_slide()
	if soft_collision.is_colliding():
		move_and_collide(soft_collision.get_push_vector() * _delta)

func unhandled_input(event: InputEvent) -> void:
	input_buffer.add_input(event)
	$StateMachine.unhandled_input(event)
	
	if attack_can_cancel and input_buffer and input_buffer.has_action("jump"):
		state_machine.transition_to("Air", {do_jump = true})
		attack_can_cancel = false

func play_animation(animation_name : String = "", \
					_custom_blend : float = -1.0, \
					_custom_speed : float = 1.0, \
					_from_end : bool = false) -> void:
	animation_player.play("RESET")
	await animation_player.animation_finished
	animation_player.play(animation_name)


func take_damage(base_damage: float, type: ActorResources.Type=ActorResources.Type.HP, hitbox: Hitbox=null) -> bool:
	if hitbox and GameUtilities.team_hostile_to(hitbox.team, team):
		ParticleSpawner.spawn_one_shot(hitbox.hit_particles, global_position, get_parent())
		
		var hit_sfx = AudioStreamPlayer2D.new()
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


func _on_resource_depleted(type: ActorResources.Type) -> void:
	match type:
		ActorResources.Type.HP:
			defeat()

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


func _on_state_machine_transitioned(_to_state, _from_state):
	attack_request_buffer = { }


func _on_tree_entered():
	GameManager.actors[str(name)] = self


func _on_tree_exited():
	GameManager.actors.erase(str(name))
