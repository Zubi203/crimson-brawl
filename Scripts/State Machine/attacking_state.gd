class_name AttackingState
extends State

@export var damage: int = 15
@export var standing_state: State
@export var animation_name: String = "LightAttack"
@export var duration: float = 0.3
@export var forward_force: float = 2.0

@export var cooldown: float = 1.0
var cooldown_end_time: float

@export var hit_sender: HitSender
var has_hit: bool = false
@export var startup_time: float = 0.0
@export var active_frames_time: float = 0.3

@onready var hit_effect: PackedScene = preload("uid://dcaye7jt4o6jj")

func can_enter() -> bool:
	if Time.get_unix_time_from_system() < cooldown_end_time:
		return false
	
	return true

func enter():
	super.enter()
	fighter.add_force(forward_force * fighter.forward_direction)
	animation.set_animation(animation_name)

func update(delta: float):
	super.update(delta)
	
	var hit_end_time: float = startup_time + active_frames_time
	if local_time >= startup_time and local_time <= hit_end_time:
		if hit_sender:
			var hit: HitReciever = hit_sender.detect_hit()
			
			if hit and not has_hit:
				_spawn_hit_effect(hit)
				has_hit = true
				audio_manager.play_random_pitch(sound_data.hit)
				hit.hit(damage)
	
	if local_time >= duration:
		state_machine.change_state(standing_state.name)

func exit():
	super.exit()
	has_hit = false
	
	cooldown_end_time = Time.get_unix_time_from_system() + cooldown

func _spawn_hit_effect(hit: HitReciever):
	var midpoint: Vector3 = (hit.global_position + hit_sender.global_position) / 2.0
	var effect = hit_effect.instantiate()
	hit.add_child(effect)
	effect.global_position = midpoint
	
