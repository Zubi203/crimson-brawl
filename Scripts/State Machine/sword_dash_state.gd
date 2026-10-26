class_name SwordDashState
extends SwordAttackState

@export var dash_particles: GPUParticles3D

func enter():
	super.enter()
	if dash_particles:
		dash_particles.rotation_degrees.y = 180
		dash_particles.restart()
