class_name JumpingState
extends MovementState

@export var jump_force: float = 8.0
@export var gravity: float = 20.0
@export var standing_state: State
@export var jump_start_animation_name: String = "JumpStart"
@export var jump_land_animation_name: String = "JumpLand"
@export var jump_particles: GPUParticles3D
@export var land_particles: GPUParticles3D
@export var jump_attack_state: State = null
	
func enter():
	super.enter()
	
	audio_manager.play_random_pitch(sound_data.jump)
	signals.Jumped.emit()
	
	if jump_particles:
		jump_particles.restart()
	
	animation.set_animation(jump_start_animation_name)
	fighter.move_velocity.y = jump_force


func update(delta: float):
	super.update(delta)
	
	fighter.move_velocity.y -= gravity * delta
	
	if fighter.is_on_floor() and not standing_state == null:
		state_machine.change_state(standing_state.name)
		_on_land()
		return
	
	if input_buffer.was_pressed("light_attack", 5) or input_buffer.was_pressed("heavy_attack", 5):
		if jump_attack_state != null:
			state_machine.change_state(jump_attack_state.name)
			return

func _on_land():
	if land_particles:
		land_particles.restart()
	audio_manager.play_random_pitch(sound_data.jump_land)
	animation.set_animation(jump_land_animation_name)
	fighter.move_velocity.y = 0.0
