class_name FighterVisual
extends Node

var models: Array[MeshInstance3D] = []

@export var model_root: Node
@export var hit_flash_material: StandardMaterial3D

var flash_tween: Tween

func _ready() -> void:
	if model_root == null:
		return
	
	for child in model_root.find_children("*", "MeshInstance3D", true):
		models.append(child)
	
	if owner is Fighter:
		owner.HealthChanged.connect(hit_flash)
	
	if models.is_empty():
		return
	if hit_flash_material == null:
		return
	
	for model in models:
		model.material_overlay = hit_flash_material

func hit_flash(_fighter: Fighter):
	if models.is_empty():
		return
	if hit_flash_material == null:
		return
	
	if flash_tween and flash_tween.is_running():
		flash_tween.kill()
	
	flash_tween = create_tween()
	flash_tween.tween_property(hit_flash_material, "albedo_color:a", 1.0, 0.05)
	flash_tween.tween_interval(0.05)
	flash_tween.tween_property(hit_flash_material, "albedo_color:a", 0.0, 0.1)
