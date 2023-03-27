extends Node
class_name CharacterEffects


signal timeout


enum Groups { BUFF, DEBUFF }
enum Types {
	SUPER_ARMOR
}

@export var type: Types
@export var permanent := false
@export var life_time := 10.0

var timer: Timer


func enter() -> void:
	if permanent:
		return
	
	timer = Timer.new()
	timer.wait_time = life_time
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	add_child(timer)
	timer.start()


func _on_timeout() -> void:
	timeout.emit()
	queue_free()
