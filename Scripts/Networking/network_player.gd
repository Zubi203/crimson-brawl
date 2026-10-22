class_name NetworkPlayer
extends Node

@export var username: String
@export var peer_id: int

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	username = NetworkManager.local_username
	peer_id = NetworkManager.peer_id
