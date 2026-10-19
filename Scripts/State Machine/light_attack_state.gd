class_name LightAttackState
extends AttackingState

@export var combo_state: State

func update(delta: float):
	
	if local_time >= duration and input_buffer.was_pressed("light_attack") and combo_state:
		state_machine.change_state(combo_state.name)
		
	
	super.update(delta)
