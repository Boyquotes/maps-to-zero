extends Interaction

@export var song : Music.Songs
@export var previous_song_fade_out_time := 0.0


func trigger() -> void:
	MusicManager.play(song, previous_song_fade_out_time)
	super.trigger()
