class_name MovementState
extends State

@export var move_speed: float = 1.5
@export var blend_position_parameter_path: String

func update(delta: float):
	super.update(delta)
	
	var move_dir: int = input_buffer.movement_direction()
	fighter.move_velocity.z = move_dir * move_speed
	
	if blend_position_parameter_path == null:
		return
	
	var blend_pos: float = move_dir * fighter.forward_direction
	animation.set_blend_point(blend_position_parameter_path, blend_pos)

func exit():
	super.exit()
	fighter.move_velocity.z = 0.0
