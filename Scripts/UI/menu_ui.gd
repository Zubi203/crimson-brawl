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
@export var ip_line_edit: LineEdit
@export var port_line_edit: LineEdit

@export var host_player_name: Label
@export var client_player_name: Label

var port: int:
	get:
		if port_line_edit == null:
			return 0
		return int(port_line_edit.text)

var ip: String:
	get:
		if ip_line_edit == null:
			return ""
		return ip_line_edit.text

func _ready() -> void:
	current_state = MenuStates.MAIN
	
	NetworkManager.OnConnectedToServer.connect(_on_connected_to_server)
	NetworkManager.OnConnectionFailed.connect(_on_connection_failed)
	NetworkManager.OnServerDisconnected.connect(_on_server_disconnected)
	NetworkManager.OnPlayerConnected.connect(_on_player_connected)
	NetworkManager.OnPlayerDisconnected.connect(_on_player_disconnected)

func _on_local_mp_button_pressed() -> void:
	GlobalData.game_mode = GlobalData.GameMode.LOCAL_PLAYER_VS_PLAYER
	SceneTransition.transition(GlobalData.Scenes.MAIN_GAME, GlobalData.Scenes.TITLE_SCREEN)

func _on_pv_e_button_pressed() -> void:
	GlobalData.game_mode = GlobalData.GameMode.PLAYER_VS_AI
	SceneTransition.transition(GlobalData.Scenes.MAIN_GAME, GlobalData.Scenes.TITLE_SCREEN)

func _on_online_mp_button_pressed() -> void:
	current_state = MenuStates.MULTIPLAYER_SETUP

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	NetworkManager.close_peer()
	current_state = MenuStates.MAIN


func _on_create_game_button_pressed() -> void:
	if username_line_edit:
		NetworkManager.local_username = username_line_edit.text
	NetworkManager.start_host(port)
	set_lobby_ui()

func _on_join_game_button_pressed() -> void:
	if username_line_edit:
		NetworkManager.local_username = username_line_edit.text
	NetworkManager.start_client(ip, port)
	set_lobby_ui()

func _on_start_online_game_button_pressed() -> void:
	GlobalData.game_mode = GlobalData.GameMode.ONLINE_MULTIPLAYER
	SceneTransition.transition(GlobalData.Scenes.MAIN_GAME, GlobalData.Scenes.TITLE_SCREEN)

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

func set_lobby_ui():
	if host_player_name == null or client_player_name == null:
		return
	
	if NetworkManager.player_client == null or NetworkManager.player_host == null:
		return
	
	host_player_name.text = NetworkManager.player_host.username
	client_player_name.text = NetworkManager.player_client.username
