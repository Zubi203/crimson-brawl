extends Node

# Called on Server
signal OnPlayerConnected (id: int)
signal OnPlayerDisconnected (id: int)

# Called on Client
signal OnConnectedToServer ()
signal OnConnectionFailed ()
signal OnServerDisconnected ()

var player_multiplayer_spawner: PlayerMultiplayerSpawner:
	get:
		if ServiceLocator.service_exists("player_multiplayer_spawner"):
			return ServiceLocator.get_service("player_multiplayer_spawner")
		return null

@onready var player_scene: PackedScene = preload("uid://81vin80rr0de")

var local_username: String = "..."
var player_host: NetworkPlayer
var player_client: NetworkPlayer

var is_server: bool:
	get: return multiplayer.is_server()

var peer_id: int:
	get: return multiplayer.get_unique_id()

# Create a multiplayer game
func start_host(port: int):
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(port, 2)
	multiplayer.multiplayer_peer = peer
	
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
	OnPlayerDisconnected.emit(id)

# Join a multiplayer game
func start_client(ip: String, port: int):
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	
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

func register_player(player: NetworkPlayer):
	if player.get_multiplayer_authority() == 1:
		player_host = player
	else:
		player_client = player
