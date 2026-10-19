class_name FighterAnimation
extends Node

@export var anim_tree: AnimationTree

func set_blend_point(path: String, value: float):
	anim_tree[path] = lerp(anim_tree[path], value, 0.3)

func set_animation(animation_name: String):
	anim_tree["parameters/playback"].travel(animation_name)
