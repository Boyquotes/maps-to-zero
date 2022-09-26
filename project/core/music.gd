class_name Music
extends Node

enum Songs {
	NULL,
	SPLASH_START_ACT_1,
	SPLASH_START_ACT_2,
	SPLASH_START_ACT_3,
	SPLASH_START_BOSS
}

const SONG_PATHS := {
	Songs.NULL : "res://assets/music/splash_start_act_1.ogg",
	Songs.SPLASH_START_ACT_1 : "res://assets/music/splash_start_act_1.ogg",
	Songs.SPLASH_START_ACT_2 : "res://assets/music/splash_start_act_2.ogg",
	Songs.SPLASH_START_ACT_3 : "res://assets/music/splash_start_act_2.ogg",
	Songs.SPLASH_START_BOSS : "res://assets/music/splash_start_boss.ogg",
}


static func load_song(song : Songs) -> AudioStream:
	return load(SONG_PATHS[song])
