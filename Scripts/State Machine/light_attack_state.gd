class_name LightAttackState
extends AttackingState

@export var combo_state: State

func can_enter() -> bool:
	super.can_enter()
	
	return stamina_controller.stamina_available(stamina_data.light_attack_cost)

func enter():
	super.enter()
	
	stamina_controller.consume_stamina(stamina_data.light_attack_cost)

func update(delta: float):
	
	if local_time >= duration and input_buffer.was_pressed("light_attack") and combo_state:
		state_machine.change_state(combo_state.name)
		
	
	super.update(delta)
