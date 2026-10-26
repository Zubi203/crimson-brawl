class_name GameManager
extends Node

signal GameStateChanged (state: GameState)

enum GameState{
	LOADING,
	COUNTDOWN,
	PLAYING,
	ENDED
}
var current_state: GameState

@export var animation_player: AnimationPlayer
@export var start_animation_name: String = "Start"
@export var end_animation_name: String = "End"
@export var end_text_label: Label

@export var fighter_0_spawn: Node3D
@export var fighter_1_spawn: Node3D

@export var ranger_fighter_scene: PackedScene
@export var tavernkeep_fighter_scene: PackedScene
@export var networked_ranger_fighter_scene: PackedScene
@export var networked_tavernkeep_fighter_scene: PackedScene
@export var ai_fighter_scene: PackedScene

@export var multiplayer_fighter_spawner: MultiplayerSpawner

var is_quitting: bool = false

func _enter_tree() -> void:
	ServiceLocator.register("game_manager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister("game_manager")

func _ready() -> void:
	GlobalEvents.FighterDefeated.connect(_on_fighter_defeated)
	animation_player.animation_finished.connect(_on_animation_finished)
	NetworkManager.OnServerDisconnected.connect(_on_server_disconnected)
	NetworkManager.OnPlayerDisconnected.connect(_on_server_disconnected)
	
	if animation_player == null:
		return
	
	if NetworkManager.has_connection:
		if not NetworkManager.is_server:
			client_in_game.rpc()
			return
	
	if not GlobalData.game_mode == GlobalData.GameMode.ONLINE_MULTIPLAYER:
		_change_state(GameState.LOADING)

@rpc("any_peer", "call_remote", "reliable")
func client_in_game():
	_change_state(GameState.LOADING)

func _setup_fighters():
	if ai_fighter_scene == null or ranger_fighter_scene == null or tavernkeep_fighter_scene == null:
		return
	if fighter_0_spawn == null or fighter_1_spawn == null:
		return
	
	var left_fighter: Fighter
	var right_fighter: Fighter
	
	match GlobalData.game_mode:
		GlobalData.GameMode.LOCAL_PLAYER_VS_PLAYER:
			left_fighter = spawn_fighter(ranger_fighter_scene)
			right_fighter = spawn_fighter(tavernkeep_fighter_scene)
		GlobalData.GameMode.ONLINE_MULTIPLAYER:
			return
		GlobalData.GameMode.PLAYER_VS_AI:
			left_fighter = spawn_fighter(ranger_fighter_scene)
			right_fighter = spawn_fighter(ai_fighter_scene)
	
	left_fighter.setup(right_fighter, 0)
	right_fighter.setup(left_fighter, 1)
	
	left_fighter.global_position = fighter_0_spawn.global_position
	right_fighter.global_position = fighter_1_spawn.global_position
	
	_change_state(GameState.COUNTDOWN)

func _setup_networked_fighters():
	if networked_ranger_fighter_scene == null or networked_tavernkeep_fighter_scene == null:
		return
	if fighter_0_spawn == null or fighter_1_spawn == null:
		return
	if multiplayer_fighter_spawner == null:
		return
	
	var host_fighter: Fighter = networked_ranger_fighter_scene.instantiate()
	var client_fighter: Fighter = networked_tavernkeep_fighter_scene.instantiate()
	
	host_fighter.name = NetworkManager.player_host.name
	client_fighter.name = NetworkManager.player_client.name
	
	multiplayer_fighter_spawner.add_child(host_fighter, true)
	multiplayer_fighter_spawner.add_child(client_fighter, true)
	
	host_fighter.global_position = fighter_0_spawn.global_position
	client_fighter.global_position = fighter_1_spawn.global_position
	
	host_fighter.setup(client_fighter, 0)
	client_fighter.setup(host_fighter, 1)
	
	_change_state(GameState.COUNTDOWN)
	
func spawn_fighter(fighter_scene: PackedScene) -> Fighter:
	var fighter: Fighter = fighter_scene.instantiate()
	add_child(fighter)
	return fighter

func _change_state(new_state: GameState):
	current_state = new_state
	
	match current_state:
		GameState.LOADING:
			if GlobalData.game_mode == GlobalData.GameMode.ONLINE_MULTIPLAYER:
				_setup_networked_fighters.call_deferred()
			else:
				_setup_fighters.call_deferred()
		GameState.COUNTDOWN:
			if NetworkManager.has_connection:
				start_countdown.rpc()
			else:
				animation_player.play(start_animation_name)
		GameState.PLAYING:
			pass
		GameState.ENDED:
			if NetworkManager.has_connection:
				end_game.rpc()
			else:
				animation_player.play(end_animation_name)
	GameStateChanged.emit(current_state)


@rpc("authority", "call_local", "reliable")
func start_countdown():
	animation_player.play(start_animation_name)

@rpc("authority", "call_local", "reliable")
func end_game():
	animation_player.play(end_animation_name)

func _on_fighter_defeated(fighter: Fighter):
	
	await get_tree().create_timer(1.0).timeout
	
	_change_state(GameState.ENDED)
	
	if end_text_label == null:
		return
	
	if NetworkManager.has_connection:
		_networked_end_game.rpc(fighter.is_server_fighter())
		return
	
	match GlobalData.game_mode:
		GlobalData.GameMode.PLAYER_VS_AI:
			if fighter.player_id == 0:
				end_text_label.text = "DEFEAT!"
			else:
				end_text_label.text = "VICTORY!"
		_:
			if fighter.player_id == 0:
				end_text_label.text = "PLAYER 2 WINS!"
			else:
				end_text_label.text = "PLAYER 1 WINS!"

@rpc("authority", "call_local", "reliable")
func _networked_end_game(server_lost: bool):
	if server_lost:
		if NetworkManager.is_server:
			end_text_label.text = NetworkManager.player_client.username + " Wins!"
		else:
			end_text_label.text = NetworkManager.local_username + " Wins!"
	else:
		if NetworkManager.is_server:
			end_text_label.text = NetworkManager.local_username + " Wins!"
		else:
			end_text_label.text = NetworkManager.player_host.username + " Wins!"

func _on_animation_finished(anim_name: String):
	if anim_name == start_animation_name:
		_change_state(GameState.PLAYING)
		return
	
	if anim_name == end_animation_name:
		SceneTransition.transition(GlobalData.Scenes.TITLE_SCREEN, GlobalData.Scenes.MAIN_GAME)
		NetworkManager.close_peer()
		return

func _on_server_disconnected():
	SceneTransition.transition(GlobalData.Scenes.TITLE_SCREEN, GlobalData.Scenes.MAIN_GAME)

func _force_exit():
	if is_quitting:
		return
	is_quitting = true
	SceneTransition.transition(GlobalData.Scenes.TITLE_SCREEN, GlobalData.Scenes.MAIN_GAME)
	NetworkManager.close_peer()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		_force_exit()
