class_name JumpingState
extends MovementState

@export var jump_force: float = 8.0
@export var gravity: float = 20.0
@export var standing_state: State
@export var jump_start_animation_name: String = "JumpStart"
@export var jump_land_animation_name: String = "JumpLand"
@export var jump_particles: GPUParticles3D
@export var land_particles: GPUParticles3D

func can_enter() -> bool:
	return stamina_controller.stamina_available(stamina_data.light_attack_cost)
	
func enter():
	super.enter()
	
	audio_manager.play_random_pitch(sound_data.jump)
	signals.Jumped.emit()
	
	if jump_particles:
		jump_particles.restart()
	
	animation.set_animation(jump_start_animation_name)
	fighter.move_velocity.y = jump_force
	stamina_controller.consume_stamina(stamina_data.light_attack_cost)


func update(delta: float):
	super.update(delta)
	
	fighter.move_velocity.y -= gravity * delta
	
	if fighter.is_on_floor() and not standing_state == null:
		state_machine.change_state(standing_state.name)

func exit():
	if land_particles:
		land_particles.restart()
	
	audio_manager.play_random_pitch(sound_data.jump_land)
	animation.set_animation(jump_land_animation_name)
	fighter.move_velocity.y = 0.0
