extends CanvasLayer

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func transition(target_level: GlobalData.Scenes, current_level: GlobalData.Scenes):
	animation_player.play("transition_enter")
	await get_tree().create_timer(1.0).timeout
	_change_scene(target_level, current_level)
	animation_player.play("transition_exit")
	
func _change_scene(target_level: GlobalData.Scenes, _current_level: GlobalData.Scenes):
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
	var scene = load(GlobalData.SCENE_PATHS[target_level]).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	GlobalData.current_scene = target_level
