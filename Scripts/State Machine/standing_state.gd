class_name StandingState
extends MovementState

@export var jumping_state: State = null
@export var light_attack_state: State = null
@export var heavy_attack_state: State = null
@export var dash_state: State = null
@export var special_state: State = null

func update(delta: float):
	super.update(delta)
	
	if input_buffer.is_pressed("jump") and not jumping_state == null:
		state_machine.change_state(jumping_state.name)
		return
	
	if input_buffer.is_pressed("light_attack") and not light_attack_state == null:
		state_machine.change_state(light_attack_state.name)
		return
	
	if input_buffer.is_pressed("heavy_attack") and not heavy_attack_state == null:
		if input_buffer.was_pressed("crouch") and not special_state == null:
			state_machine.change_state(special_state.name)
			return
			
		state_machine.change_state(heavy_attack_state.name)
		return
	
	if input_buffer.is_pressed("dash") and not dash_state == null:
		state_machine.change_state(dash_state.name)
		return
