class_name StandingState
extends MovementState

@export var attack_buffer_frames: int = 5
@export var jumping_state: State = null
@export var light_attack_state: State = null
@export var heavy_attack_state: State = null
@export var dash_state: State = null
@export var back_heavy_state: State = null
@export var down_heavy_state: State = null
@export var front_heavy_state: State = null
@export var back_light_state: State = null
@export var down_light_state: State = null
@export var front_light_state: State = null

func update(delta: float):
	super.update(delta)
	
	if input_buffer.is_pressed("jump") and not jumping_state == null:
		state_machine.change_state(jumping_state.name)
		return
	
	if input_buffer.was_pressed("light_attack", attack_buffer_frames) and not light_attack_state == null:
		if input_buffer.was_pressed("crouch") and not down_light_state == null:
			state_machine.change_state(down_light_state.name)
			return
		if moving_backward() and not back_light_state == null:
			state_machine.change_state(back_light_state.name)
			return
		if moving_forward() and not front_light_state == null:
			state_machine.change_state(front_light_state.name)
			return
		
		state_machine.change_state(light_attack_state.name)
		return
	
	if input_buffer.was_pressed("heavy_attack", attack_buffer_frames) and not heavy_attack_state == null:
		if input_buffer.was_pressed("crouch") and not down_heavy_state == null:
			state_machine.change_state(down_heavy_state.name)
			return
		if moving_backward() and not back_heavy_state == null:
			state_machine.change_state(back_heavy_state.name)
			return
		if moving_forward() and not front_heavy_state == null:
			state_machine.change_state(front_heavy_state.name)
			return
			
		state_machine.change_state(heavy_attack_state.name)
		return
	
	if input_buffer.is_pressed("dash") and not dash_state == null:
		state_machine.change_state(dash_state.name)
		return
	
	if not fighter.is_on_floor():
		fighter.move_velocity.y -= delta * 10

func moving_forward() -> bool:
	if input_buffer.movement_direction() == 0:
		return false
	if input_buffer.movement_direction() == fighter.forward_direction:
		return true
	return false

func moving_backward() -> bool:
	if input_buffer.movement_direction() == 0:
		return false
	if input_buffer.movement_direction() != fighter.forward_direction:
		return true
	return false
