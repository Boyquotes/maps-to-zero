class_name GhostSprites
extends Node2D


@export var active : bool = false:
	set(value):
		if not is_ready:
			await ready
		active = value
		if value:
			_make_ghost()
			timer.start()
		else:
			timer.stop()
@export var wait_time : float = 0.2
@export var sprite_lifetime : float = 0.2
@export var fade_out : bool = true

var timer : Timer
var container : Node2D
var source_sprite : Sprite2D
var is_ready : bool


func _ready() -> void:
	container = Node2D.new()
	add_child(container)
	
	timer = Timer.new()
	timer.wait_time = wait_time
	add_child(timer)
	timer.timeout.connect(_make_ghost)
	
	source_sprite = get_parent()
	
	is_ready = true


func _make_ghost() -> void:
	var new_sprite = Sprite2D.new()
	new_sprite.texture = source_sprite.texture
	new_sprite.offset = source_sprite.offset
	new_sprite.hframes = source_sprite.hframes
	new_sprite.vframes = source_sprite.vframes
	new_sprite.frame = source_sprite.frame
	new_sprite.global_transform = source_sprite.global_transform
	new_sprite.material = source_sprite.material
	new_sprite.modulate = source_sprite.modulate
	container.add_child(new_sprite)
	new_sprite.top_level = true
	
	if fade_out:
		new_sprite.material = null
		var tween = new_sprite.create_tween()
		tween.tween_property(new_sprite, "modulate", Color.TRANSPARENT, sprite_lifetime)
	
	var sprite_lifetime_timer = Timer.new()
	new_sprite.add_child(sprite_lifetime_timer)
	sprite_lifetime_timer.timeout.connect(new_sprite.queue_free)
	sprite_lifetime_timer.start(sprite_lifetime)
