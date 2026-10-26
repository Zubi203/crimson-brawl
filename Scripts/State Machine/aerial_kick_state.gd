class_name AerialKickState
extends AttackingState

@export var move_speed: float = 3.0
@export var gravity: float = 20.0
@export var jumping_state: JumpingState
@export var standing_state: StandingState
@export var jump_land_animation_name: String = "JumpLand"
@export var land_particles: GPUParticles3D

func can_enter() -> bool:
	super.can_enter()
	
	if jumping_state == null:
		return false
	
	if not state_machine.current_state.name == jumping_state.name:
		return false
	
	return true

func enter():
	super.enter()

func update(delta: float):
	super.update(delta)
	
	fighter.move_velocity.y -= gravity * delta
	
	var move_dir: int = input_buffer.movement_direction()
	fighter.move_velocity.z = move_dir * move_speed
	
	if fighter.is_on_floor() and not standing_state == null:
		state_machine.change_state(standing_state.name)

func exit():
	super.exit()
	if land_particles:
		land_particles.restart()
	
	audio_manager.play_random_pitch(sound_data.jump_land)
	animation.set_animation(jump_land_animation_name)
	fighter.move_velocity.y = 0.0
