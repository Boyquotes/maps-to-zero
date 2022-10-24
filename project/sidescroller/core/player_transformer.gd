class_name PlayerTransformer
extends Marker2D


@onready var player: Actor2D = GameManager.player
@export var center_offset: Vector2

@export_enum(Right, Left) var look_direction:
	set(value):
		if not player or not active:
			return
		match value:
			0:
				player.look_direction = Vector2.RIGHT
			1:
				player.look_direction = Vector2.LEFT
			_:
				player.look_direction = Vector2.RIGHT
@export var move_with_look_direction: bool = true

@export var active := false:
	set(value):
		active = value
		if not player:
			return
		if value == true:
#			player.look_direction = scale
			last_frame_position = position - center_offset
			player.cutscene_mode = true
			set_physics_process(true)
		else:
#			player.look_direction = scale
			player.velocity = Vector2.ZERO
			set_physics_process(false)
			player.cutscene_mode = false

@export var animation := "":
	set(value):
		if player and player.animation_player:
			player.animation_player.play(value)

@export var move_to: bool
const MOVE_TO_CLOSE_ENOUGH_DISTANCE : float = 8.0

var last_frame_position : Vector2


func _ready():
	set_physics_process(false)


func _physics_process(delta):
	if move_to:
		var direction = player.global_position.direction_to(global_position - center_offset)
		player.velocity = direction * player.speed
		if player.global_position.distance_to(global_position - center_offset) < MOVE_TO_CLOSE_ENOUGH_DISTANCE:
			move_to = false
	elif not last_frame_position.is_equal_approx(position - center_offset):
		var position_delta = (position - center_offset) - last_frame_position
		if move_with_look_direction:
			position_delta.x *= sign(player.look_direction.x)
		player.velocity = position_delta / delta
	else:
		player.velocity = Vector2.ZERO
	last_frame_position = position - center_offset
	
	player.rotation = rotation
#	player.inner.scale = scale


func player_queue_free() -> void:
	set_physics_process(false)
	player.queue_free()


func teleport() -> void:
	last_frame_position = position - center_offset
	player.velocity = Vector2.ZERO
	player.global_position = global_position - center_offset
