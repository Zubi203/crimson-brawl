extends CanvasLayer

signal OnSceneChanged

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var is_loading: bool = false
var current_scene: Node = null

func transition(target_level: GlobalData.Scenes, current_level: GlobalData.Scenes):
	animation_player.play("transition_enter")
	await get_tree().create_timer(1.0).timeout
	_change_scene(target_level, current_level)
	animation_player.play("transition_exit")
	
func _change_scene(target_level: GlobalData.Scenes, _current_level: GlobalData.Scenes):
	load_scene(load(GlobalData.SCENE_PATHS[target_level]))
	GlobalData.current_scene = target_level

func load_scene(scene: PackedScene):
	if is_loading:
		return
	
	is_loading = true
	
	if is_instance_valid(current_scene):
		current_scene.queue_free()
		await current_scene.tree_exited
	
	if scene == null:
		return
	
	current_scene = scene.instantiate()
	get_tree().root.add_child(current_scene)
	
	if not current_scene.is_inside_tree():
		await current_scene.tree_entered
	
	is_loading = false
	OnSceneChanged.emit()
