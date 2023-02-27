extends Node
class_name TargetManager

signal target_acquired(new_target)
signal unlocked

var target
var actor

func _ready():
	await owner.ready
	actor = owner
	lock_on()

func lock_on(new_target=null) -> void:
	if new_target:
		change_target(new_target)
		return
	
	var closest_enemy = _find_closest_enemy()
	
	if closest_enemy:
		change_target(closest_enemy)
	else:
		unlock()

# Set max distance to negative number to lock checked regardless of distance
func _find_closest_enemy(max_distance:=-1.0):
	var closest_target = null
	if get_target():
		closest_target = target
	
	var enemy_teams = GameUtilities.get_hostile_teams(actor.team)
	for enemy_team in enemy_teams:
		for target_actor in get_tree().get_nodes_in_group("team" + str(enemy_team)):
			if closest_target == null:
				closest_target = target_actor
			
			var distance_to_new_target = actor.global_position.distance_to(target_actor.global_position)
			var distance_to_current_target = actor.global_position.distance_to(closest_target.global_position)
			if distance_to_new_target < distance_to_current_target:
				closest_target = target_actor
			
			distance_to_current_target = actor.global_position.distance_to(closest_target.global_position)
			if max_distance >= 0.0 and distance_to_current_target > max_distance:
				closest_target = null
	
	return closest_target


func change_target(new_target) -> void:
	if get_target() and target.is_connected("defeated", target_died):
		target.disconnect("defeated", target_died)
	
	if not new_target or not is_instance_valid(new_target):
		return
	
	target = new_target
	if not target.is_connected("defeated", target_died):
		target.connect("defeated", target_died)
	
	emit_signal("target_acquired", get_target())


func target_died():
	target = null


func unlock():
	target = null
	emit_signal("unlocked")

func has_target() -> bool:
	return target and is_instance_valid(target)

func get_target():
	if target and is_instance_valid(target):
		return target

func get_distance() -> float:
	var _target = get_target()
	return actor.global_position.distance_to(_target.global_position) if _target else 0.0

func get_rotation_to() -> float: # in radians
	var _target = get_target()
	return (_target.global_position - actor.global_position).angle()

func get_direction() -> Vector2:
	var _target = get_target()
	if not _target:
		return actor.look_direction
	else:
		return actor.global_position.direction_to(_target.global_position)
