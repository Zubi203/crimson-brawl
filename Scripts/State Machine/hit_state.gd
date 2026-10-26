class_name HitState
extends State

@export var duration: float = 0.3
@export var animation_name: String = "ChestHit"
@export var standing_state: State
@export var gravity: float = 20.0

func enter():
	super.enter()
	fighter.move_velocity = Vector3.ZERO
	animation.set_animation(animation_name)

func update(delta: float):
	super.update(delta)
	
	fighter.move_velocity.y -= gravity * delta
	
	if local_time >= duration:
		state_machine.change_state(standing_state.name)
