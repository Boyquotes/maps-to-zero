class_name CharacterInterface
extends Node

@export var actor_name: String = ""
var _character: Character:
	get:
		if _character:
			return _character as Character
		if actor_name == "" and owner is Character:
			_character = owner
		elif actor_name == "PLAYER":
			_character = GameUtilities.get_player()
		elif get_child_count() == 1 and get_child(0) is Character:
			_character = get_child(0)
		else:
			if GameManager.actors.has(actor_name):
				_character = GameManager.actors[actor_name]
		return _character as Character
