extends CanvasLayer


@export var response_template: Node

@onready var balloon: ColorRect = $Balloon
@onready var margin: MarginContainer = $Balloon/Margin
@onready var character_label: RichTextLabel = $Balloon/Margin/VBox/CharacterLabel
@onready var dialogue_label := $Balloon/Margin/VBox/DialogueLabel
@onready var responses_menu: VBoxContainer = $Balloon/Margin/VBox/Responses

## The dialogue resource
var resource: Resource

## Temporary game states
var temporary_game_states: Array = []

var timer : Timer



## The current line
var dialogue_line: Dictionary:
	set(next_dialogue_line):
		if next_dialogue_line.size() == 0:
			queue_free()
			return
		
		# Remove any previous responses
		for child in responses_menu.get_children():
			child.free()
		
		dialogue_line = next_dialogue_line
		
		character_label.visible = not dialogue_line.character.is_empty()
		character_label.text = dialogue_line.character
		
		dialogue_label.modulate.a = 0
		dialogue_label.size.x = dialogue_label.get_parent().size.x - 1
		dialogue_label.dialogue_line = dialogue_line
		await dialogue_label.reset_height()

		# Show any responses we have
		responses_menu.modulate.a = 0
		if dialogue_line.responses.size() > 0:
			for response in dialogue_line.responses:
				# Duplicate the template so we can grab the fonts, sizing, etc
				var item: RichTextLabel = response_template.duplicate(0)
				item.name = "Response%d" % responses_menu.get_child_count()
				if not response.is_allowed:
					item.name = String(item.name) + "Disallowed"
					item.modulate.a = 0.4
				item.text = response.text
				item.show()
				responses_menu.add_child(item)

		# Reset the margin size
		margin.size = Vector2.ZERO
		
		# Show our balloon
		balloon.visible = true
		
		dialogue_label.modulate.a = 1
		dialogue_label.type_out()
		await dialogue_label.finished_typing
	get:
		return dialogue_line


func _ready() -> void:
	response_template.hide()
	balloon.hide()
	balloon.custom_minimum_size.x = roundi(balloon.get_viewport_rect().size.x)
	
	DialogueManager.mutation.connect(_on_mutation)
	
	timer = Timer.new()
	timer.one_shot = false
	timer.timeout.connect(_on_timeout)
	add_child(timer)


## Start some dialogue
func start(dialogue_resource: Resource, title: String, next_line_delay := 5.0, extra_game_states: Array = []) -> void:
	temporary_game_states = extra_game_states
	resource = dialogue_resource
	self.dialogue_line = await DialogueManager.get_next_dialogue_line(resource, title, temporary_game_states)
	
	timer.wait_time = next_line_delay
	timer.start()


## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await DialogueManager.get_next_dialogue_line(resource, next_id, temporary_game_states)

### Signals

func _on_timeout() -> void:
	next(dialogue_line.next_id)

func _on_mutation() -> void:
	balloon.hide()


func _on_margin_resized() -> void:
	if is_instance_valid(margin):
		balloon.custom_minimum_size.y = roundi(margin.size.y)
		# Force a resize on only the height
		balloon.size.y = 0
		var viewport_size = balloon.get_viewport_rect().size
		balloon.global_position = Vector2((viewport_size.x - balloon.size.x) * 0.5, viewport_size.y - balloon.size.y)
