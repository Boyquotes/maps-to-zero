@tool
class_name ActorCutsceneTransformer
extends Marker2D

@export var actor_name: String = ""
@export var center_offset: Vector2 = Vector2(0, 16)

@export_enum("Right", "Left") var look_direction:
	set(value):
		if not actor:
			await ready
		if not actor:
			return
		match value:
			0:
				actor.look_direction = Vector2.RIGHT
			1:
				actor.look_direction = Vector2.LEFT
			_:
				actor.look_direction = Vector2.RIGHT

@export var animation := "":
	set(value):
		if Engine.is_editor_hint():
			if not actor:
				await ready
			if not actor:
				return
			actor.play_animation(value)
		elif actor and actor.animation_player:
			if not actor.is_ready:
				await actor.ready
			actor.play_animation(value)

@export var active: bool = false:
	set(value):
		active = value
		set_physics_process(active)

var last_frame_position : Vector2
var actor: Actor2D


func _ready():
	if Engine.is_editor_hint():
		if get_child_count() == 1 and get_child(0) is Actor2D:
			actor = get_child(0)
			actor_name = actor.name
		elif owner is Actor2D:
			actor = owner
			actor_name = actor.name
		return
	
	if actor_name == "":
		actor = owner
	elif actor_name == "PLAYER":
		actor = GameManager.player
	else:
		actor = GameManager.actors[actor_name]
	assert(actor is Actor2D)
	actor.tree_exited.connect(func():
		queue_free())
	set_physics_process(false)


func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	if last_frame_position.is_equal_approx(position - center_offset):
		actor.velocity = Vector2.ZERO
	else:
		var position_delta = (position - center_offset) - last_frame_position
		actor.velocity = position_delta / delta
	last_frame_position = position - center_offset
	
	actor.rotation = rotation
#	actor.inner.scale = scale


func actor_queue_free() -> void:
	set_physics_process(false)
	actor.queue_free()


func teleport() -> void:
	last_frame_position = position - center_offset
	actor.velocity = Vector2.ZERO
	actor.global_position = global_position - center_offset


func enable() -> void:
	actor.set_cutscene_mode(true)
	active = true
	last_frame_position = position - center_offset

func disable() -> void:
	actor.set_cutscene_mode(false)
	active = false
	actor.rotation = 0
	actor.velocity = Vector2.ZERO

func show_character() -> void:
	actor.visible = true

func hide_character() -> void:
	actor.visible = false
