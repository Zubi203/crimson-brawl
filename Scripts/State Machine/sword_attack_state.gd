class_name SwordAttackState
extends AttackingState

@export var sword: Sword

func can_enter() -> bool:
	if sword == null:
		return false
	super.can_enter()
	return true

func enter():
	super.enter()
	hit_sender = sword.hit_sender
	sword.appear()
	audio_manager.play_random_pitch(sound_data.sword_start_sound)

func exit():
	super.exit()
	sword.disappear()
