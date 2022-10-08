extends Node

@onready var audio_stream_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var original_volume := audio_stream_player.volume_db

var tween: Tween


func play(song : Music.Songs, previous_song_fade_out_time:=0.0) -> void:
	if tween:
		tween.stop()
	
	if song != Music.Songs.SILENCE:
		audio_stream_player.stream = Music.load_song(song)
	
	# Fade out
	tween = create_tween()
	tween.tween_property(audio_stream_player, "volume_db", -80.0, previous_song_fade_out_time)
	tween.finished.connect(play_song.bind(song))
	



func play_song(song: Music.Songs) -> void:
	audio_stream_player.volume_db = original_volume
	
	if song != Music.Songs.SILENCE:
		audio_stream_player.play()
	else:
		audio_stream_player.stop()
