class_name LightAttackState
extends AttackingState

@export var combo_state: State

func enter():
	super.enter()
	
	audio_manager.play_random_pitch(sound_data.light_attack)
	signals.BeganLightAttack.emit()

func update(delta: float):
	
	if local_time >= duration and input_buffer.was_pressed("light_attack") and combo_state:
		state_machine.change_state(combo_state.name)
	
	super.update(delta)
