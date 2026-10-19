class_name DefeatState
extends State

@export var defeat_animation_name: String = "Defeat"
@export var knockback: float = 20.0

func enter():
	super.enter()
	fighter.add_force(knockback * -fighter.forward_direction)
	animation.set_animation(defeat_animation_name)
