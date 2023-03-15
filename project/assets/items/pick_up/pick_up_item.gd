extends RigidBody2D


@export var slot_data: SlotData


@onready var sprite_2d = $Sprite2D


func _ready() -> void:
	sprite_2d.texture = slot_data.item_data.texture


func _on_area_2d_area_entered(area: Area2D):
	if area.owner is Character:
		var character := area.owner as Character
		if character.inventory_data.pick_up_slot_data(slot_data):
			queue_free()
