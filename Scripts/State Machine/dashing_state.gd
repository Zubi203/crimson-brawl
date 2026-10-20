class_name DashingState
extends State

@export var duration: float = 0.2
@export var distance: float =  1.5
@export var cooldown: float =  1.0
var cooldown_end_time: float
@export var animation_name: String = "Dash"
@export var next_state: State = null
var move_dir: int 

func can_enter() -> bool:
	if input_buffer.movement_direction() == 0:
		return false
	
	if Time.get_unix_time_from_system() < cooldown_end_time:
		return false
	
	return stamina_controller.stamina_available(stamina_data.dash_cost)

func enter():
	super.enter()
	
	move_dir = input_buffer.movement_direction()
	fighter.move_velocity = Vector3.ZERO
	animation.set_animation(animation_name)
	stamina_controller.consume_stamina(stamina_data.dash_cost)

func update(delta: float):
	super.update(delta)
	
	if local_time >= duration:
		state_machine.change_state(next_state.name)
	
	var speed = distance / duration
	fighter.move_velocity.z = speed * move_dir

func exit():
	super.exit()
	
	fighter.move_velocity = Vector3.ZERO
	cooldown_end_time = Time.get_unix_time_from_system() + cooldown
