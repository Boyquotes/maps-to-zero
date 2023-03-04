class_name Music
extends Node

enum Songs {
	CONTINUE,
	SILENCE,
	HORIZON_HILLS_ACT_1_PROLOGUE,
	HORIZON_HILLS_ACT_1,
	HORIZON_HILLS_ACT_2,
	HORIZON_HILLS_ACT_3,
	HORIZON_HILLS_BOSS,
	HORIZON_HILLS_ACT_1_RETRO,
	SAVE_POINT,
	HORIZON_HILLS_REST_AREA,
}

const SONG_PATHS := {
	Songs.CONTINUE : null,
	Songs.SILENCE : null,
	Songs.HORIZON_HILLS_ACT_1_PROLOGUE : "res://assets/music/horizon_hills_act_1_prologue.ogg",
	Songs.HORIZON_HILLS_ACT_1 : "res://assets/music/horizon_hills_act_1.ogg",
	Songs.HORIZON_HILLS_ACT_2 : "res://assets/music/horizon_hills_act_2.ogg",
	Songs.HORIZON_HILLS_ACT_3 : "res://assets/music/horizon_hills_act_2.ogg",
	Songs.HORIZON_HILLS_BOSS : "res://assets/music/horizon_hills_boss.ogg",
	Songs.HORIZON_HILLS_ACT_1_RETRO : "res://assets/music/horizon_hills_act_1_retro.ogg",
	Songs.SAVE_POINT : "res://assets/music/save_point.ogg",
	Songs.HORIZON_HILLS_REST_AREA : "res://assets/music/horizon_hills_rest_area.ogg",
}


static func load_song(song : Songs) -> AudioStream:
	return load(SONG_PATHS[song])
