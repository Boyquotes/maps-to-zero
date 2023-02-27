extends GPUParticles2D

@onready var trail: Trail2D = $Trail2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var light_animation_player: AnimationPlayer = $PointLight2D/AnimationPlayer


func _ready():
	deactivate()

func activate() -> void:
	emitting = true
	trail.emit = true
	audio_stream_player.play()
	if light_animation_player.current_animation == "deactivate":
		light_animation_player.play("active")
	elif light_animation_player.current_animation != "activate" or light_animation_player.current_animation != "active":
		light_animation_player.play("activate")


func deactivate() -> void:
	emitting = false
	trail.emit = false
	audio_stream_player.stop()
	light_animation_player.play("deactivate")
