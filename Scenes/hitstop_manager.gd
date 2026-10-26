class_name HitstopManager
extends Node

func _enter_tree() -> void:
	ServiceLocator.register("hitstop_manager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister("hitstop_manager")

func _ready() -> void:
	GlobalEvents.FighterDefeated.connect(_on_fighter_defeated)

func _on_fighter_defeated(_fighter: Fighter):
	await get_tree().create_timer(0.2, true, false, true).timeout
	trigger_hit_stop(1.5, 0.2)

func trigger_hit_stop(duration: float = 0.08, time_scale: float = 0.0):
	Engine.time_scale = time_scale
	
	var timer = get_tree().create_timer(duration, true, false, true)
	await timer.timeout
	
	Engine.time_scale = 1.0
	
	if NetworkManager.has_connection and NetworkManager.is_server:
		trigger_client_hit_stop.rpc(duration, time_scale)

@rpc("authority", "call_remote", "reliable")
func trigger_client_hit_stop(duration: float = 0.08, time_scale: float = 0.0):
	Engine.time_scale = time_scale
	
	var timer = get_tree().create_timer(duration, true, false, true)
	await timer.timeout
	
	Engine.time_scale = 1.0
