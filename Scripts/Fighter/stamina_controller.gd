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

var game_manager: GameManager:
	get:
		if ServiceLocator.service_exists("game_manager"):
			return ServiceLocator.get_service("game_manager")
		return null

func _ready() -> void:
	if data == null:
		data = StaminaData.new()
	
	game_manager.GameStateChanged.connect(_on_game_state_changed)
	if not NetworkManager.has_connection:
		set_stamina(data.max_stamina)
	
	if NetworkManager.has_connection and not NetworkManager.is_server:
		set_physics_process(false)

func _on_game_state_changed(state: GameManager.GameState):
	if state == GameManager.GameState.COUNTDOWN and NetworkManager.has_connection:
		set_stamina(data.max_stamina)

func consume_stamina(amount: float):
	var stamina: float = current_stamina - amount
	set_stamina(stamina)
	if data:
		stamina_regen_delay_timer = data.regen_delay

func set_stamina(value: float):
	current_stamina = value
	
	if NetworkManager.has_connection and NetworkManager.is_server:
		_set_client_stamina.rpc(value)

@rpc("authority", "call_remote", "reliable")
func _set_client_stamina(value: float):
	current_stamina = value

func _physics_process(delta: float) -> void:
	if data == null:
		return
	
	if stamina_regen_delay_timer > 0.0:
		stamina_regen_delay_timer -= delta
		return
	
	var stamina: float = move_toward(current_stamina, data.max_stamina, delta * data.regen_rate)
	set_stamina(stamina)

func stamina_available(cost: float) -> bool:
	if current_stamina >= cost:
		return true
	return false
