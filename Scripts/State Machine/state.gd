class_name State
extends Node

@export var stamina_cost_type: StaminaData.MoveTypes = StaminaData.MoveTypes.FREE

var state_machine: StateMachine

var local_time: float

var fighter: Fighter:
	get: return state_machine.fighter

var input_buffer: InputBuffer:
	get: return state_machine.input_buffer

var animation: FighterAnimation:
	get: return state_machine.animation

var stamina_controller: StaminaController:
	get: return state_machine.fighter.stamina_controller

var stamina_data: StaminaData:
	get: return stamina_controller.data

var audio_manager: AudioManager:
	get:
		if ServiceLocator.service_exists("audio_manager"):
			return ServiceLocator.get_service("audio_manager")
		return null

var sound_data: FighterSoundData:
	get: return fighter.sound_data

var signals: FighterSignals:
	get: return fighter.fighter_signals

func initialize (fsm: StateMachine):
	state_machine = fsm

func can_enter() -> bool:
	return stamina_controller.stamina_available(stamina_data.stamina_costs[stamina_cost_type])

func enter():
	stamina_controller.consume_stamina(stamina_data.stamina_costs[stamina_cost_type])
	local_time = 0.0

func exit():
	pass

func update(_delta: float):
	local_time += _delta
