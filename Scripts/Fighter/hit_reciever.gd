class_name HitReciever
extends Area3D

var fighter: Fighter
@export var hit_state_name: String = "ChestHit"

func initialize(_fighter: Fighter):
	fighter = _fighter

func hit(damage: int):
	fighter.take_damage(self, damage)
