class_name Fighter
extends CharacterBody3D

@warning_ignore_start("unused_signal")
signal HealthChanged (fighter: Fighter)
signal StaminaUpdated (stamina: float)

@export var player_id: int = 0
@export var opponent: Fighter

@export var input_handler: InputHandler
@export var input_buffer: InputBuffer
@export var state_machine: StateMachine
@export var stamina_controller: StaminaController
@export var sound_data: FighterSoundData
@export var fighter_signals: FighterSignals

var forward_direction: int
var move_velocity: Vector3
var horizontal_force: float
@export var drag: float = 0.8

@export var max_health: int = 100

var game_manager: GameManager:
	get:
		if ServiceLocator.service_exists("game_manager"):
			return ServiceLocator.get_service("game_manager")
		return null

var current_health: int:
	set(value):
		current_health = value
		current_health = clamp(current_health, 0, max_health)
		HealthChanged.emit(self)
		if current_health <= 0:
			defeat()
var is_defeated: bool = false

var camera_controller: CameraController:
	get:
		if not ServiceLocator.service_exists("camera_controller"):
			return null
		
		return ServiceLocator.get_service("camera_controller")

func _enter_tree() -> void:
	if not NetworkManager.has_connection:
		return
	
	for child in get_children():
		if child is InputSync:
			child.set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if NetworkManager.has_connection and not NetworkManager.is_server:
		set_physics_process(false)
		return
	
	if not GlobalData.game_mode == GlobalData.GameMode.ONLINE_MULTIPLAYER:
		_set_starting_health(max_health)

func setup(_opponent: Fighter = null, id: int = 0):
	player_id = id
	self.opponent = _opponent
	camera_controller.set_target_fighter(self)
	_update_facing_direction.call_deferred()
	
	if NetworkManager.is_server:
		_set_starting_health(max_health)
	
	for child in find_children("*", "HitReciever", true, false):
		child.initialize(self)
	
	for child in find_children("*", "HitSender", true, false):
		child.initialize(self)

@rpc("authority", "call_local", "reliable")
func _set_starting_health(health: int):
	current_health = health

func _physics_process(delta: float) -> void:
	if game_manager == null:
		return
	if !game_manager.current_state == GameManager.GameState.PLAYING:
		return
	
	# get input packet
	var input_packet: InputPacket = input_handler.get_input_packet()
	
	# send the input packet into the buffer
	input_buffer.recieve_input(input_packet)
	
	# process the state machine using the inputs
	state_machine.update(delta)
	
	# update facing direction
	_update_facing_direction()
	
	# process movement
	_movement(delta)

func _update_facing_direction():
	if opponent == null:
		return
	if is_defeated:
		return
	
	if global_position.z < opponent.global_position.z:
		forward_direction = 1
		rotation_degrees.y = 0
	else:
		forward_direction = -1
		rotation_degrees.y = -180

func add_force(force: float):
	horizontal_force = force

func _movement(_delta: float):
	horizontal_force *= drag
	
	velocity.z = move_velocity.z + horizontal_force
	velocity.y = move_velocity.y
	velocity.x = 0.0
	move_and_slide()

func take_damage(source: HitReciever, damage: int, knockback: float = 8.0):
	current_health -= damage
	camera_controller.shake()
	
	if is_defeated:
		return
	
	state_machine.change_state(source.hit_state_name)
	add_force(knockback * -forward_direction)
	
	if NetworkManager.has_connection and NetworkManager.is_server:
		client_take_damage.rpc(current_health)

@rpc("authority", "call_remote", "reliable")
func client_take_damage(new_health: int):
	current_health = new_health


func defeat():
	if is_defeated:
		return
	
	GlobalEvents.FighterDefeated.emit(self)
	is_defeated = true
	state_machine.change_state("DefeatState")

func is_server_fighter() -> bool:
	if not NetworkManager.is_connected:
		return false
	return name.to_int() == 1
