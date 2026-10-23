class_name CameraController
extends Camera3D

var target_a: Node3D
var target_b: Node3D

@export var camera_smoothing: float = 5.0
@export var zoom_curve: Curve

var shake_intensity: float
var shake_falloff: float = 10.0

func _enter_tree() -> void:
	ServiceLocator.register("camera_controller", self)

func _exit_tree() -> void:
	ServiceLocator.unregister("camera_controller")

func _physics_process(delta: float) -> void:
	camera_follow(delta)
	
	if shake_intensity > 0.0:
		shake_intensity = lerpf(shake_intensity, 0.0, shake_falloff * delta)
		h_offset = randf_range(-shake_intensity, shake_intensity)
		v_offset = randf_range(-shake_intensity, shake_intensity)

func camera_follow(delta: float):
	if target_a == null or target_b == null:
		return
	
	var target_pos: Vector3 = target_a.global_position.lerp(target_b.global_position, 0.5)
	var distance_between_targets: float = target_a.global_position.distance_to(target_b.global_position)
	var zoom_target_pos: float = zoom_curve.sample(distance_between_targets)
	
	position.z = lerpf(position.z, target_pos.z, camera_smoothing * delta)
	position.x = lerpf(position.x, zoom_target_pos, camera_smoothing * delta)

func set_target_fighter(fighter: Fighter):
	if fighter == null:
		return
	
	if fighter.player_id == 0:
		target_a = fighter
	else:
		target_b = fighter

func shake(intensity: float = 0.1, falloff: float = 10.0):
	if NetworkManager.has_connection:
		_networked_shake.rpc(intensity, falloff)
		return
	shake_intensity = intensity
	shake_falloff = falloff

@rpc("authority", "call_local", "reliable")
func _networked_shake(intensity: float = 0.1, falloff: float = 10.0):
	shake_intensity = intensity
	shake_falloff = falloff
