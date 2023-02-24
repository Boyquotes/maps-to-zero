class_name Music
extends Node

enum Songs {
	NULL, # Bad value
	SILENCE,
	HORIZON_HILLS_ACT_1_PROLOGUE,
	HORIZON_HILLS_ACT_1,
	HORIZON_HILLS_ACT_2,
	HORIZON_HILLS_ACT_3,
	HORIZON_HILLS_BOSS,
	HORIZON_HILLS_ACT_1_RETRO
}

const SONG_PATHS := {
	Songs.SILENCE : null,
	Songs.HORIZON_HILLS_ACT_1_PROLOGUE : "res://assets/music/horizon_hills_act_1_prologue.ogg",
	Songs.HORIZON_HILLS_ACT_1 : "res://assets/music/horizon_hills_act_1.ogg",
	Songs.HORIZON_HILLS_ACT_2 : "res://assets/music/horizon_hills_act_2.ogg",
	Songs.HORIZON_HILLS_ACT_3 : "res://assets/music/horizon_hills_act_2.ogg",
	Songs.HORIZON_HILLS_BOSS : "res://assets/music/horizon_hills_boss.ogg",
	Songs.HORIZON_HILLS_ACT_1_RETRO : "res://assets/music/horizon_hills_act_1_retro.ogg",
}


static func load_song(song : Songs) -> AudioStream:
	return load(SONG_PATHS[song])
