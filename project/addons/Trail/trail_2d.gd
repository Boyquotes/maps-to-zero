class_name Trail2D
extends Line2D


@export var emit: bool = true
@export var lifetime: float = 0.5
@export var distance: float = 20.0
@export var segments: int = 20
@export var grow_smaller_over_time: bool = true
var target

var trail_points := []
var offset := Vector2()


class Point:
	var position := Vector2()
	var age := 0.0
	var grow_smaller_over_time: bool = true
	
	func _init(position :Vector2, age :float, grow_smaller_over_time: bool):
		self.position = position
		self.age = age
		self.grow_smaller_over_time = grow_smaller_over_time
	
	
	func update(delta :float, points :Array) -> void:
		if grow_smaller_over_time:
			self.age -= delta
			if self.age <= 0:
				points.erase(self)


func _ready():
	offset = position
	show_behind_parent = true
	target = get_parent()
	clear_points()
	set_as_top_level(true)
	position = Vector2()


func _emit():
	var _position :Vector2 = target.global_transform.origin + offset
	var point = Point.new(_position, lifetime, grow_smaller_over_time)
	if trail_points.size() < 1:
		trail_points.push_back(point)
		return
	
	if trail_points[-1].position.distance_squared_to(_position) > distance*distance:
		trail_points.push_back(point)
	
	update_points()


func update_points() -> void:
	var delta = get_process_delta_time()
	
	if trail_points.size() > segments:
		trail_points.reverse()
		trail_points.resize(segments)
		trail_points.reverse()
	
	clear_points()
	for point in trail_points:
		point.update(delta, trail_points)
		
#		if point:
		add_point(point.position)


func _process(delta):
	if emit:
		_emit()
	else:
		update_points()
