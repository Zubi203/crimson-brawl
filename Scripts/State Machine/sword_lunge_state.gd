class_name SwordLungeState
extends SwordAttackState

@export var move_speed: float = 1.5
@export var lunge_start_time: float = 0.2
@export var lunge_end_time: float = 0.8
@export var second_hit_start_time: float = 0.7

var second_hit_active: bool = false

func enter():
	super.enter()
	second_hit_active = false
	audio_manager.play_random_pitch(sound_data.sword_slash_sound)

func update(delta: float):
	super.update(delta)
	
	if local_time >= second_hit_start_time and not second_hit_active:
		has_hit = false
		second_hit_active = true
	
	if local_time >= lunge_start_time and local_time <= lunge_end_time:
		fighter.add_force(move_speed * fighter.forward_direction)
