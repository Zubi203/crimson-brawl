class_name JumpingState
extends MovementState

@export var jump_force: float = 8.0
@export var gravity: float = 20.0
@export var standing_state: State
@export var jump_start_animation_name: String = "JumpStart"
@export var jump_land_animation_name: String = "JumpLand"

func enter():
	animation.set_animation(jump_start_animation_name)
	fighter.move_velocity.y = jump_force

func update(delta: float):
	super.update(delta)
	
	fighter.move_velocity.y -= gravity * delta
	
	if fighter.is_on_floor() and not standing_state == null:
		state_machine.change_state(standing_state.name)

func exit():
	animation.set_animation(jump_land_animation_name)
	fighter.move_velocity.y = 0.0
