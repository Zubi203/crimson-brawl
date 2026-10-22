class_name PlayerMultiplayerSpawner
extends MultiplayerSpawner


func _enter_tree() -> void:
	ServiceLocator.register("player_multiplayer_spawner", self)

func _exit_tree() -> void:
	ServiceLocator.unregister("player_multiplayer_spawner")
