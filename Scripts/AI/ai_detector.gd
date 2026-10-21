class_name AIDetector
extends Node

signal DetectedLightAttack
signal DetectedHeavyAttack

var fighter: Fighter

@export var min_reaction_time: float = 0.05
@export var max_reaction_time: float = 0.2

func _ready() -> void:
	if not owner is Fighter:
		return
	
	fighter = owner
	
	if fighter.opponent == null:
		return
	
	var opponent_signals: FighterSignals = fighter.opponent.fighter_signals
	
	if opponent_signals == null:
		return
	opponent_signals.BeganHeavyAttack.connect(_on_opponent_began_heavy_attack)
	opponent_signals.BeganLightAttack.connect(_on_opponent_began_light_attack)

func _on_opponent_began_light_attack():
	await reaction_time_delay()
	DetectedLightAttack.emit()

func _on_opponent_began_heavy_attack():
	await reaction_time_delay()
	DetectedHeavyAttack.emit()

func reaction_time_delay():
	var wait_time: float = randf_range(min_reaction_time, max_reaction_time)
	await  get_tree().create_timer(wait_time).timeout
