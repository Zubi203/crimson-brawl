class_name HeavyAttackState
extends AttackingState

func enter():
	super.enter()
	signals.BeganHeavyAttack.emit()
