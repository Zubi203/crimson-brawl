class_name Sword
extends Node3D

@export var hit_sender: HitSender
@export var sword_mesh: MeshInstance3D
@export var trail: GPUTrail3D
@export var start_particles: GPUParticles3D
@export var end_particles: GPUParticles3D
@export var sword_particles: GPUParticles3D

func appear():
	await get_tree().create_timer(0.1).timeout
	sword_mesh.show()
	trail.length_seconds = 0.2
	if start_particles:
		start_particles.restart()
	if sword_particles:
		sword_particles.restart()

func disappear():
	sword_mesh.hide()
	trail.length_seconds = 0.0
	if end_particles:
		end_particles.restart()
	if sword_particles:
		sword_particles.emitting = false
