class_name LightComboState
extends AttackingState

func can_enter() -> bool:
	super.can_enter()
	
	return stamina_controller.stamina_available(stamina_data.light_attack_cost)

func enter():
	super.enter()
	
	stamina_controller.consume_stamina(stamina_data.light_attack_cost)
