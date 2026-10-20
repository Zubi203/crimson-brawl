class_name StaminaController
extends Node

signal StaminaUpdated (stamina: float)

@export var data: StaminaData
var current_stamina: float:
	set(value):
		current_stamina = value
		
		if data == null:
			return
		
		current_stamina = clampf(current_stamina, 0.0, data.max_stamina)
		StaminaUpdated.emit(current_stamina)

var stamina_regen_delay_timer: float

func _ready() -> void:
	if data == null:
		return
	current_stamina = data.max_stamina

func consume_stamina(amount: float):
	current_stamina -= amount
	if data:
		stamina_regen_delay_timer = data.regen_delay

func _physics_process(delta: float) -> void:
	if data == null:
		return
	
	if stamina_regen_delay_timer > 0.0:
		stamina_regen_delay_timer -= delta
		return
	
	current_stamina = move_toward(current_stamina, data.max_stamina, delta * data.regen_rate)

func stamina_available(cost: float) -> bool:
	if current_stamina >= cost:
		return true
	
	return false
