extends Node

@onready var audio_stream_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var original_volume := audio_stream_player.volume_db

var tween: Tween
var current_song: AudioStream


func play(song: AudioStream, previous_song_fade_out_time:=0.0) -> void:
	if song == current_song:
		return
	
	if tween:
		tween.stop()
	
	if not song == null:
		audio_stream_player.stream = song
	
	# Fade out
	tween = create_tween()
	tween.tween_property(audio_stream_player, "volume_db", -80.0, previous_song_fade_out_time)
	tween.finished.connect(play_song.bind(song))
	



func play_song(song: AudioStream) -> void:
	current_song = song
	audio_stream_player.volume_db = original_volume
	
	if not song == null:
		audio_stream_player.play()
	else:
		audio_stream_player.stop()
