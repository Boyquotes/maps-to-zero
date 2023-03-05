class_name RegenerateStatTicker
extends Ticker


@export var type: CharacterStats.Types
@export var amount: float = 0.0
@export var tick_rate: float = 0.1


var _timer: Timer
var _characters := {}


func _ready():
	super._ready()
	
	_timer = Timer.new()
	_timer.autostart = false
	_timer.wait_time = tick_rate
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(area):
	if area.owner is Character:
		var character = area.owner as Character
		if not _characters.has(character):
			_characters[character] = true
		if _timer.is_stopped() and _characters.size() > 0:
			_timer.start()


func _on_area_exited(area):
	if area.owner is Character:
		var character = area.owner as Character
		if _characters.has(character):
			_characters.erase(character)
		if not _timer.is_stopped() and _characters.size() <= 0:
			_timer.stop()


func _on_timer_timeout() -> void:
	for character in _characters.keys():
		var c = character as Character
		c.change_stat_by(type, amount)
