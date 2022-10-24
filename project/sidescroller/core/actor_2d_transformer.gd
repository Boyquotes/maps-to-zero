class_name ActorTransformer2D
extends Marker2D


@export var actor_name: String = ""
@export var center_offset: Vector2

@export_enum(Right, Left) var look_direction:
	set(value):
		if not actor:
			return
		match value:
			0:
				actor.look_direction = Vector2.RIGHT
			1:
				actor.look_direction = Vector2.LEFT
			_:
				actor.look_direction = Vector2.RIGHT
@export var move_with_look_direction: bool = true

@export var active := false:
	set(value):
		active = value
		if not actor:
			await ready
		
		if value == true:
#			actor.look_direction = scale
			last_frame_position = position - center_offset
			actor.cutscene_mode = true
			if keep_actor_collision_on_active:
				actor.set_collision_layer_value(2, true)
			set_physics_process(true)
		else:
#			actor.look_direction = scale
			actor.velocity = Vector2.ZERO
			actor.cutscene_mode = false
			set_physics_process(false)

@export var animation := "":
	set(value):
		if actor and actor.animation_player:
			actor.animation_player.play(value)

@export var keep_actor_collision_on_active := true

var last_frame_position : Vector2
var actor: Actor2D


func _ready():
	if actor_name == "":
		actor = owner
	else:
		actor = GameManager.actors[actor_name]
	assert(actor is Actor2D)
	actor.tree_exited.connect(func():
		queue_free())
	set_physics_process(false)


func _physics_process(delta):
	if last_frame_position.is_equal_approx(position - center_offset):
		actor.velocity = Vector2.ZERO
	else:
		var position_delta = (position - center_offset) - last_frame_position
		if move_with_look_direction:
			position_delta.x *= sign(actor.look_direction.x)
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
