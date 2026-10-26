class_name DashingState
extends State

@export var duration: float = 0.2
@export var distance: float =  1.5
@export var cooldown: float =  1.0
var cooldown_end_time: float
@export var animation_name: String = "Dash"
@export var next_state: State = null
var move_dir: int 

@export var dash_particles: GPUParticles3D
@export var dash_stop_particles: GPUParticles3D

func can_enter() -> bool:
	if input_buffer.movement_direction() == 0:
		return false
	
	if Time.get_unix_time_from_system() < cooldown_end_time:
		return false
	
	super.can_enter()
	
	return true

func enter():
	super.enter()
	
	if dash_particles:
		if fighter.forward_direction != input_buffer.movement_direction() and input_buffer.movement_direction() != 0:
			dash_particles.rotation_degrees.y = 180
		else :
			dash_particles.rotation_degrees.y = 0
		dash_particles.restart()
	
	fighter.is_invulnerable = true
	audio_manager.play_random_pitch(sound_data.dash)
	signals.Dashed.emit()
	
	move_dir = input_buffer.movement_direction()
	fighter.move_velocity = Vector3.ZERO
	animation.set_animation(animation_name)

func update(delta: float):
	super.update(delta)
	
	if local_time >= duration:
		state_machine.change_state(next_state.name)
	
	var speed = distance / duration
	fighter.move_velocity.z = speed * move_dir

func exit():
	super.exit()
	
	if dash_stop_particles:
		if fighter.forward_direction != input_buffer.movement_direction() and input_buffer.movement_direction() != 0:
			dash_stop_particles.rotation_degrees.y = 180
		else :
			dash_stop_particles.rotation_degrees.y = 0
		dash_stop_particles.restart()
	
	fighter.is_invulnerable = false
	fighter.move_velocity = Vector3.ZERO
	cooldown_end_time = Time.get_unix_time_from_system() + cooldown
