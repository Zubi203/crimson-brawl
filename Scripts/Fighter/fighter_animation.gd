class_name FighterAnimation
extends Node

@export var anim_tree: AnimationTree

func set_blend_point(path: String, value: float):
	anim_tree[path] = lerp(anim_tree[path], value, 0.3)
	
	if NetworkManager.is_server:
		set_client_blend_point.rpc(path, value)

func set_animation(animation_name: String):
	anim_tree["parameters/playback"].travel(animation_name)
	
	if NetworkManager.is_server:
		set_client_animation.rpc(animation_name)

@rpc("authority", "call_remote", "reliable")
func set_client_animation(animation_name: String):
	anim_tree["parameters/playback"].travel(animation_name)

@rpc("authority", "call_remote", "reliable")
func set_client_blend_point(path: String, value: float):
	anim_tree[path] = lerp(anim_tree[path], value, 0.3)
