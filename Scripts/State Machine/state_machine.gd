class_name StateMachine
extends Node

@export var fighter: Fighter

@export var input_buffer: InputBuffer
@export var animation: FighterAnimation

@export var starting_state: State

var states: Dictionary[String, State] = {}
var current_state: State = null;

func _ready() -> void:
	for child in get_children():
		if not child is State:
			continue
		
		states[child.name.to_lower()] = child
		states[child.name.to_lower()].initialize(self)
	
	if starting_state:
		change_state(starting_state.name)

func change_state(state_name: String):
	if not states.has(state_name.to_lower()):
		printerr("Could not change state to ", state_name, " as it does not exist")
		return
	
	if not states[state_name.to_lower()].can_enter():
		return
	
	if current_state == states[state_name.to_lower()]:
		printerr("Could not change state to ", state_name, " as it is already active")
		return
	
	if current_state:
		current_state.exit()
	
	current_state = states[state_name.to_lower()]
	current_state.enter()
	
	#print("State ", state_name)

func update(delta: float) -> void:
	if current_state == null:
		return
	
	current_state.update(delta)

func is_current_state(state_name: String) -> bool:
	if current_state == null:
		return false
	
	return current_state.name.to_lower() == state_name.to_lower()
