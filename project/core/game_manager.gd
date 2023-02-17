extends Node

signal screen_transition_finished

var actors := {}
var actors_original_cutscene_mode_value := {}
var sidescroller_main: SidescrollerMain
var popup_canvas: CanvasLayer
var current_stage_file_path: String

var cutscene_mode: bool:
	set(value):
		cutscene_mode = value
		if value:
			actors_original_cutscene_mode_value.clear()
			for actor in actors.values():
				actors_original_cutscene_mode_value[actor] = actor.cutscene_mode
				actor.set_cutscene_mode(true)
			show_cutscene_bars(1.0)
		else:
			for actor in actors.values():
				if actors_original_cutscene_mode_value.has(actor):
					actor.set_cutscene_mode(actors_original_cutscene_mode_value[actor])
				else:
					actor.set_cutscene_mode(false)
			hide_cutscene_bars(1.0)

var player: Actor2D
var gameplay_camera: GameplayCamera2D
var transition_camera: Camera2D


func show_cutscene_bars(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		$ScreenEffects/CutsceneBars/AnimationPlayer.play("showing")
	else:
		$ScreenEffects/CutsceneBars/AnimationPlayer.speed_scale = 1.0 / duration
		$ScreenEffects/CutsceneBars/AnimationPlayer.play("show_bars")


func hide_cutscene_bars(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		$ScreenEffects/CutsceneBars.visible = false
	else:
		$ScreenEffects/CutsceneBars/AnimationPlayer.speed_scale = 1.0 / duration
		$ScreenEffects/CutsceneBars/AnimationPlayer.play("hide_bars")


func show_speedlines() -> void:
	$ScreenEffects/SpeedLines.visible = true
	$ScreenEffects/SpeedLines/Image/AnimationPlayer.play("play")

func hide_speedlines() -> void:
	$ScreenEffects/SpeedLines.visible = false
	$ScreenEffects/SpeedLines/Image/AnimationPlayer.stop()

func show_skill_frame(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		$ScreenEffects/SkillFrames/AnimationPlayer.play("show")
	else:
		$ScreenEffects/SkillFrames/AnimationPlayer.speed_scale = 1.0 / duration
		$ScreenEffects/SkillFrames/AnimationPlayer.play("show")

func hide_skill_frame(duration:= 1.0) -> void:
	if is_equal_approx(duration, 0.0):
		$ScreenEffects/SkillFrames.visible = false
	else:
		$ScreenEffects/SkillFrames/AnimationPlayer.speed_scale = 1.0 / duration
		$ScreenEffects/SkillFrames/AnimationPlayer.play("hide")



func enable_gameplay_camera_current(transition_time := 1.0) -> void:
	set_gameplay_camera_current(true, transition_time)

func set_gameplay_camera_current(value: bool, _transition_time := 1.0) -> void:
	if value:
#		var current_camera = get_viewport().get_camera_2d()
#		transition_camera.global_position = current_camera.global_position
#		transition_camera.zoom = current_camera.zoom
#		transition_camera.limit_bottom = current_camera.limit_bottom
#		transition_camera.limit_left = current_camera.limit_left
#		transition_camera.limit_right = current_camera.limit_right
#		transition_camera.limit_top = current_camera.limit_top
#
#		transition_camera.current = true
#		var tweener = create_tween()
#		tweener.set_parallel(true)
#		tweener.tween_property(transition_camera, "global_position", gameplay_camera.global_position, transition_time)
#		tweener.tween_property(transition_camera, "zoom", gameplay_camera.zoom, transition_time)
#		tweener.tween_property(transition_camera, "limit_bottom", gameplay_camera.limit_bottom, transition_time)
#		tweener.tween_property(transition_camera, "limit_left", gameplay_camera.limit_left, transition_time)
#		tweener.tween_property(transition_camera, "limit_right", gameplay_camera.limit_right, transition_time)
#		tweener.tween_property(transition_camera, "limit_top", gameplay_camera.limit_top, transition_time)
#
#		await tweener.finished
		gameplay_camera.current = true
	else:
		gameplay_camera.current = false


func screen_transition(animation: Enums.ScreenTransition, duration:=1.0) -> void:
	var animation_player: AnimationPlayer = $ScreenTransition/AnimationPlayer
	animation_player.speed_scale = 1.0 / duration
	var dict := {
		Enums.ScreenTransition.DEFAULT: "fade_in",
		Enums.ScreenTransition.FADE_IN: "fade_in",
		Enums.ScreenTransition.FADE_OUT: "fade_out"
	}
	animation_player.play(dict[animation])
	await animation_player.animation_finished
	screen_transition_finished.emit()


func request_stage_change(stage_file_path: String, player_entry_point := 0) -> void:
	var stage = load(stage_file_path)
	current_stage_file_path = stage_file_path
	SaveData.stage_file_path = stage_file_path
	sidescroller_main.change_stage(stage, player_entry_point)


func reload() -> void:
	var stage = load(SaveData.stage_file_path)
	sidescroller_main.change_stage(stage, 0, true)


func screen_shake(trauma := 0.5):
	sidescroller_main.gameplay_camera.add_trauma(trauma)
