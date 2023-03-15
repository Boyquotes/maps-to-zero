extends Resource
class_name PlayerData

@export var inventory: InventoryData
@export var base_max_background_jumps: int = 1
@export var base_max_mid_air_jumps: int = 0
var stats: Dictionary = {} # Gets set by character scene for now
var max_stats: Dictionary = {} # Gets set by character scene for now
