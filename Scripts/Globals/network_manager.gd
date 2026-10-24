extends Node

const RELAY_PORT: int = 9998

# Called on Server
signal OnPlayerConnected (id: int)
signal OnPlayerDisconnected (id: int)
signal OnOnlineIDCreated (id: String)

# Called on Client
signal OnConnectedToServer ()
signal OnConnectionFailed ()
signal OnServerDisconnected ()

var player_multiplayer_spawner: PlayerMultiplayerSpawner:
	get:
		if ServiceLocator.service_exists("player_multiplayer_spawner"):
			return ServiceLocator.get_service("player_multiplayer_spawner")
		return null

var prompt_manager: PromptManager:
	get:
		if ServiceLocator.service_exists("prompt_manager"):
			return ServiceLocator.get_service("prompt_manager")
		return null

@onready var player_scene: PackedScene = preload("uid://81vin80rr0de")

var local_username: String = "..."
var player_host: NetworkPlayer = null
var player_client: NetworkPlayer = null

var is_server: bool:
	get: 
		if multiplayer.multiplayer_peer == null:
			return false
		return multiplayer.is_server()

var peer_id: int:
	get: return multiplayer.get_unique_id()

var has_connection: bool:
	get: 
		if multiplayer.multiplayer_peer == null:
			return false
		return multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.CONNECTION_CONNECTED and multiplayer.multiplayer_peer != OfflineMultiplayerPeer

var peer: NodeTunnelPeer
var online_id: String

func setup_multiplayer():
	peer = NodeTunnelPeer.new()
	peer.connect_to_relay("us-east.nodetunnel.io:8080", "ojyrpcmr4oi6qi3")
	multiplayer.multiplayer_peer = peer
	
	await peer.authenticated


# Create a multiplayer game
func start_host():
	if multiplayer.multiplayer_peer == null:
		return
	
	peer.host_room(true, "Fighting Game Room")
	
	prompt_manager.on_loading_start()
	await peer.room_connected
	prompt_manager.close_menus()
	
	online_id = peer.room_id
	
	DisplayServer.clipboard_set(online_id)
	OnOnlineIDCreated.emit(online_id)
	
	if not multiplayer.peer_connected.is_connected(_peer_connected):
		multiplayer.peer_connected.connect(_peer_connected)
	if not multiplayer.peer_disconnected.is_connected(_peer_disconnected):
		multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	_peer_connected(peer.get_unique_id())

# Called on Server
# when a peer (player) connects to the server
func _peer_connected(id: int):
	OnPlayerConnected.emit(id)
	
	if player_scene == null or player_multiplayer_spawner == null:
		return
	
	var player: NetworkPlayer = player_scene.instantiate()
	player.name = str(id)
	player_multiplayer_spawner.add_child(player)

# when a peer (player) disconnects from the server
func _peer_disconnected(id: int):
	var player: NetworkPlayer = player_multiplayer_spawner.get_node(str(id))
	
	if player:
		player.queue_free()
	
	close_peer()
	_server_disconnected()
	
	OnPlayerDisconnected.emit(id)

func _delete_all_player_nodes():
	for child in player_multiplayer_spawner.get_children():
		child.queue_free()

# Join a multiplayer game
func start_client(room_id: String):
	if multiplayer.multiplayer_peer == null:
		return
	
	peer.join_room(room_id)
	
	if not multiplayer.connected_to_server.is_connected(_connected_to_server):
		multiplayer.connected_to_server.connect(_connected_to_server)
	if not multiplayer.connection_failed.is_connected(_connection_failed):
		multiplayer.connection_failed.connect(_connection_failed)
	if not multiplayer.server_disconnected.is_connected(_server_disconnected):
		multiplayer.server_disconnected.connect(_server_disconnected)

# Called on the Client
# when a client connects to the server
func _connected_to_server():
	print("Connected")
	OnConnectedToServer.emit()

# when a client fails to connect to the server
func _connection_failed():
	print("Failed")
	OnConnectionFailed.emit()

# when connection to the server ends or is lost
func _server_disconnected():
	print("Disconnected")
	OnServerDisconnected.emit()

func close_peer():
	if multiplayer.multiplayer_peer == null:
		return
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	peer = null
	_delete_all_player_nodes()

func register_player(player: NetworkPlayer):
	if player.get_multiplayer_authority() == 1:
		player_host = player
	else:
		player_client = player
