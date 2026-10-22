class_name Bootstrap
extends Node

func _ready() -> void:
	await get_tree().process_frame
	SceneTransition.load_scene(load(GlobalData.SCENE_PATHS[GlobalData.Scenes.TITLE_SCREEN]))
