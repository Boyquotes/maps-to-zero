class_name ActorTransformer2D
extends Marker2D

@export_enum(Right, Left) var source_direction:
	set(value):
		match value:
			0:
				owner.look_direction = Vector2.RIGHT
			1:
				owner.look_direction = Vector2.LEFT

@export var active := false:
	set(value):
		if value == true:
			last_frame_position = position
			set_physics_process(true)
		else:
			owner.velocity = Vector2.ZERO
			set_physics_process(false)

@export var animation := "":
	set(value):
		if owner and owner.has_node("Inner/Visuals/AnimationPlayer"):
			owner.inner.get_node("Visuals/AnimationPlayer").play(value)

var last_frame_position : Vector2


func _ready():
	assert(owner is Actor2D)
	set_physics_process(false)


func _physics_process(delta):
	if not last_frame_position.is_equal_approx(position):
		var position_delta = position - last_frame_position
		position_delta.x *= sign(owner.look_direction.x)
		owner.velocity = position_delta / delta
	else:
		owner.velocity = Vector2.ZERO
	last_frame_position = position
	
	owner.rotation = rotation
#	owner.inner.scale = scale
#	owner.inner.scale.x *= sign(owner.look_direction.x)
