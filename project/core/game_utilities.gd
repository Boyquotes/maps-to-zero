class_name GameUtilities
extends Node


enum Teams { NEUTRAL, TEAM_1, TEAM_2 }
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
