class_name StaminaData
extends Resource

enum MoveTypes{
	FREE,
	JUMP,
	DASH,
	LIGHT_ATTACK,
	HEAVY_ATTACK,
	SWORD_LIGHT,
	SWORD_HEAVY
}

@export var max_stamina: float = 100.0
@export var regen_delay: float = 0.3
@export var regen_rate: float = 20.0

@export var stamina_costs: Dictionary[MoveTypes, float] = {
	MoveTypes.FREE: 0.0,
	MoveTypes.JUMP: 8,
	MoveTypes.DASH: 15,
	MoveTypes.LIGHT_ATTACK: 5.0,
	MoveTypes.HEAVY_ATTACK: 15,
	MoveTypes.SWORD_LIGHT: 12,
	MoveTypes.SWORD_HEAVY: 20
}
