# Generic state machine. Initializes states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the active state.
class_name StateMachine
extends Node

# Emitted when transitioning to a new state.
signal transitioned(to, from)


# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var reset_state_name: String


# The current active state. At the start of the game, we get the `initial_state`.
@onready var state := get_node(reset_state_name) as State


func _ready() -> void:
	# The state machine assigns itself to the State objects' state_machine property.
	for child in get_children():
		child.state_machine = self
	set_process(false)
	set_physics_process(false)


func init(character: Character) -> void:
	for child in get_children():
		if child is CharacterState:
			child.init(character)
	reset()
	set_process(true)
	set_physics_process(true)


func reset(state_name:="") -> void:
	if state_name == "":
		transition_to(reset_state_name)
	else:
		transition_to(state_name)


# The state machine subscribes to node callbacks and delegates them to the state objects.
func unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)
	for transition in state.state_transitions:
		transition.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)
	for transition in state.state_transitions:
		transition.physics_update(delta)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter() function.
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	# Safety check, you could use an assert() here to report an error if the state name is incorrect.
	# We don't use an assert here to help with code reuse. If you reuse a state in different state machines
	# but you don't want them all, they won't be able to transition to states that aren't in the scene tree.
	if not has_node(target_state_name):
		print_debug(owner.name + " does not have a " + target_state_name + " state in " + name)
		return
	
	var old_state = state
	state.exit()
	for transition in state.state_transitions:
		transition.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	for transition in state.state_transitions:
		transition.enter(msg)
	for req in state.transition_requirements:
		req.enter(msg)
	emit_signal("transitioned", state.name, old_state.name)


func get_state(target_state_name: String) -> State:
	return get_node(target_state_name)
