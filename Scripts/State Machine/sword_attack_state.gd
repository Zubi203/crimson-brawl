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

func exit():
	super.exit()
	sword.disappear()
