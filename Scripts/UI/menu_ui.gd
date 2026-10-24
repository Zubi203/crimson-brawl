extends CanvasLayer

enum MenuStates {
	MAIN,
	MULTIPLAYER_SETUP,
	MULTIPLAYER_LOBBY
}

@export var menu_scenes: Dictionary[MenuStates, Control] = {
	MenuStates.MAIN: null,
	MenuStates.MULTIPLAYER_SETUP: null,
	MenuStates.MULTIPLAYER_LOBBY: null
}

var current_state: MenuStates:
	set(value):
		current_state = value
		for key in menu_scenes.keys():
			if menu_scenes[key] == null:
				continue
			if key == current_state:
				menu_scenes[key].show()
			else:
				menu_scenes[key].hide()

@export_category("Multiplayer Setup")
@export var username_line_edit: LineEdit

@export_category("Lobby")
@export var host_player_name: Label
@export var client_player_name: Label
@export var online_multiplayer_start_button: BaseButton
@export var waiting_text: Label
@export var room_id_text: Label

var prompt_manager: PromptManager:
	get:
		if ServiceLocator.service_exists("prompt_manager"):
			return ServiceLocator.get_service("prompt_manager")
		return null

func _ready() -> void:
	current_state = MenuStates.MAIN
	
	if online_multiplayer_start_button:
		online_multiplayer_start_button.pressed.connect(_on_multiplayer_game_start_button_pressed)
	
	NetworkManager.OnConnectedToServer.connect(_on_connected_to_server)
	NetworkManager.OnConnectionFailed.connect(_on_connection_failed)
	NetworkManager.OnServerDisconnected.connect(_on_server_disconnected)
	NetworkManager.OnPlayerConnected.connect(_on_player_connected)
	NetworkManager.OnPlayerDisconnected.connect(_on_player_disconnected)

func _on_local_mp_button_pressed() -> void:
	NetworkManager.close_peer()
	GlobalData.game_mode = GlobalData.GameMode.LOCAL_PLAYER_VS_PLAYER
	SceneTransition.transition(GlobalData.Scenes.MAIN_GAME, GlobalData.Scenes.TITLE_SCREEN)

func _on_pv_e_button_pressed() -> void:
	NetworkManager.close_peer()
	GlobalData.game_mode = GlobalData.GameMode.PLAYER_VS_AI
	SceneTransition.transition(GlobalData.Scenes.MAIN_GAME, GlobalData.Scenes.TITLE_SCREEN)

func _on_online_mp_button_pressed() -> void:
	NetworkManager.setup_multiplayer()
	current_state = MenuStates.MULTIPLAYER_SETUP

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	NetworkManager.close_peer()
	current_state = MenuStates.MAIN


func _on_create_game_button_pressed() -> void:
	if username_line_edit:
		NetworkManager.local_username = username_line_edit.text
	NetworkManager.start_host()

func _on_join_game_button_pressed() -> void:
	if username_line_edit:
		NetworkManager.local_username = username_line_edit.text
	prompt_manager.current_state = PromptManager.MenuState.JOIN_ROOM

func _on_server_disconnected():
	current_state = MenuStates.MAIN

func _on_player_disconnected(_id: int):
	current_state = MenuStates.MAIN

func _on_connected_to_server():
	current_state = MenuStates.MULTIPLAYER_LOBBY

func _on_connection_failed():
	pass

func _on_player_connected(_id: int):
	current_state = MenuStates.MULTIPLAYER_LOBBY

func _on_multiplayer_game_start_button_pressed():
	GlobalData.game_mode = GlobalData.GameMode.ONLINE_MULTIPLAYER
	SceneTransition.transition.rpc(GlobalData.Scenes.MAIN_GAME, GlobalData.Scenes.TITLE_SCREEN)

func set_lobby_ui():
	if host_player_name == null or client_player_name == null:
		return
	if not NetworkManager.has_connection:
		online_multiplayer_start_button.disabled = true
		return
	
	online_multiplayer_start_button.disabled = false
	
	if NetworkManager.player_client:
		client_player_name.text = NetworkManager.player_client.username
	else:
		client_player_name.text = "..."
	
	if NetworkManager.player_host:
		host_player_name.text = NetworkManager.player_host.username
	else:
		host_player_name.text = "..."
	
	if online_multiplayer_start_button == null or waiting_text == null:
		return
	
	if NetworkManager.is_server:
		online_multiplayer_start_button.show()
		waiting_text.hide()
	else:
		online_multiplayer_start_button.hide()
		waiting_text.show()
	
	if not NetworkManager.online_id == "" and room_id_text:
		room_id_text.text = str("Room ID: ", NetworkManager.online_id)
	else:
		room_id_text.text = ""

func _process(_delta: float) -> void:
	set_lobby_ui()
