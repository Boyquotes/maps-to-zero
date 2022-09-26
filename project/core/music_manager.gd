extends Node

@onready var audio_stream_player : AudioStreamPlayer = $AudioStreamPlayer

func play(song : Music.Songs) -> void:
	audio_stream_player.stream = Music.load_song(song)
	audio_stream_player.play()
