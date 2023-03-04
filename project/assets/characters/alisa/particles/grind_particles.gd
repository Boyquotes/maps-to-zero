extends GPUParticles2D

@onready var _grind_trail_template := %GrindTrailTemplate as Trail2D
@onready var _decal_trail_template := %DecalTrailTemplate as Trail2D
@onready var audio_stream_player := $AudioStreamPlayer2D as AudioStreamPlayer2D
@onready var light_animation_player := $PointLight2D/AnimationPlayer as AnimationPlayer

var _trail: Trail2D
var _trail_decal: Trail2D


func _ready():
	deactivate()


func activate() -> void:
	emitting = true
	audio_stream_player.play()
	if light_animation_player.current_animation == "deactivate":
		light_animation_player.play("active")
	elif light_animation_player.current_animation != "activate" or light_animation_player.current_animation != "active":
		light_animation_player.play("activate")
	
	if not _trail:
		_trail = _grind_trail_template.duplicate() as Trail2D
		add_child(_trail)
		_trail.emit = true
	
	if not _trail_decal:
		_trail_decal = _decal_trail_template.duplicate() as Trail2D
		add_child(_trail_decal)
		_trail_decal.emit = true


func deactivate() -> void:
	emitting = false
	audio_stream_player.stop()
	light_animation_player.play("deactivate")
	
	if _trail_decal:
		_trail_decal.emit = false
		_trail_decal.get_parent().remove_child(_trail_decal)
		GameUtilities.get_stage().get_wall_decals().add_child(_trail_decal)
		_trail_decal = null
	
	if _trail:
		_trail.emit = false
		_trail.top_level = true
		var queue_free_trail = _trail
		_trail = null
		await get_tree().create_timer(queue_free_trail.lifetime).timeout
		queue_free_trail.queue_free()
