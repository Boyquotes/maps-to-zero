class_name GameUtilities
extends Node

signal screen_transition_finished

enum Teams { NEUTRAL, TEAM_1, TEAM_2 }


const TILE_SIZE := Vector2(32, 32)
const FRIENDLY_TEAMS := {
	Teams.NEUTRAL : [Teams.NEUTRAL, Teams.TEAM_1, Teams.TEAM_2],
	Teams.TEAM_1 : [Teams.NEUTRAL, Teams.TEAM_1],
	Teams.TEAM_2 : [Teams.NEUTRAL, Teams.TEAM_2]
}
const HOSTILE_TEAMS := {
	Teams.NEUTRAL : [],
	Teams.TEAM_1 : [Teams.TEAM_2],
	Teams.TEAM_2 : [Teams.TEAM_1]
}

static func team_friendly_with(source_team: Teams, other_team: Teams) -> bool:
	return FRIENDLY_TEAMS[source_team].has(other_team)

static func team_hostile_to(source_team: Teams, other_team: Teams) -> bool:
	return HOSTILE_TEAMS[source_team].has(other_team)

static func get_hostile_teams(team: Teams) -> Array:
	return HOSTILE_TEAMS[team]

static func get_main_camera() -> GameplayCamera2D:
	return GameManager.gameplay_camera

static func get_player() -> Actor2D:
	return GameManager.player

static func get_popup_canvas() -> CanvasLayer:
	return GameManager.sidescroller_main.popup_canvas

func show_cutscene_bars(duration:= 1.0) -> void:
	ScreenEffects.show_cutscene_bars(duration)

func hide_cutscene_bars(duration:= 1.0) -> void:
	ScreenEffects.hide_cutscene_bars(duration)

func show_speedlines() -> void:
	ScreenEffects.show_speedlines()

func hide_speedlines() -> void:
	ScreenEffects.hide_speedlines()

func show_skill_frame(duration:= 1.0) -> void:
	ScreenEffects.show_border_frame(duration)

func hide_skill_frame(duration:= 1.0) -> void:
	ScreenEffects.hide_border_frame(duration)

func show_game_hud(duration := 1.0):
	GameManager.sidescroller_main.sidescroller_hud.show_hud(duration)

func hide_game_hud(duration := 1.0):
	GameManager.sidescroller_main.sidescroller_hud.hide_hud(duration)

func cover_screen(cover_animation: ScreenEffectsClass.CoverAnimations, duration := 1.0):
	ScreenEffects.cover_screen(cover_animation, duration)
	
func uncover_screen(uncover_animation: ScreenEffectsClass.UncoverAnimations, duration := 1.0):
	ScreenEffects.uncover_screen(uncover_animation, duration)
