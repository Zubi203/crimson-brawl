class_name State
extends Node

var state_machine: StateMachine

var enter_time: float
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

func initialize (state_machine: StateMachine):
	self.state_machine = state_machine

func can_enter() -> bool:
	return true

func enter():
	enter_time = Time.get_unix_time_from_system()

func exit():
	pass

func update(delta: float):
	var time: float = Time.get_unix_time_from_system()
	local_time = time - enter_time
