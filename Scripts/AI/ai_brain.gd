class_name AIBrain
extends Node

enum AttackPhase {
	NONE,
	WAITING,
	PERFORMING
}

@export var max_level_bounds: float = 5.0
@export var min_level_bounds: float = -5.0
@export var min_pursuit_distance: float = 0.5
@export var stamina_advantage_threshold_percent: float = 0.2
@export var light_attack_range: float = 1.4
@export var heavy_attack_range: float = 1.7

@export_category("Traits")
@export_range(0.0, 1.0, 0.01) var skill: float = 0.5
@export_range(0.0, 1.0, 0.01) var bravery: float = 0.5

var fear: float = 0.0:
	set(value):
		fear = value
		fear = clampf(fear, 0.0, 1.0)
@export var fear_falloff: float = 0.2
@export var fear_gain: float = 0.2

var fighter_parent: Fighter
var opponent_distance: float
var opponent_attacking: bool = false
var detector: AIDetector
var attack_type: int = 0
var attack_phase: AttackPhase = AttackPhase.NONE
var arena_center_point: Vector3 = Vector3.ZERO


var opponent: Fighter:
	get:
		if fighter_parent == null:
			return null
		return fighter_parent.opponent

var stamina_controller: StaminaController:
	get:
		if fighter_parent == null:
			return null
		return fighter_parent.stamina_controller

var forward_input_key: String:
	get:
		if fighter_parent == null:
			return ""
		
		return "move_left" if fighter_parent.forward_direction > 0 else "move_right"

var backward_input_key: String:
	get:
		if fighter_parent == null:
			return ""
		
		return "move_left" if fighter_parent.forward_direction < 0 else "move_right"


func _ready() -> void:
	if not owner is Fighter:
		return
	
	fighter_parent = owner
	
	fighter_parent.HealthChanged.connect(_on_fighter_damaged)
	
	for child in owner.get_children():
		if child is AIDetector:
			detector = child
	
	if detector == null:
		return
	detector.DetectedHeavyAttack.connect(_on_heavy_attack_detected)
	detector.DetectedLightAttack.connect(_on_light_attack_detected)

func _physics_process(delta: float) -> void:
	fear = move_toward(fear, 0.0, delta * fear_falloff)

func decide_inputs() -> Dictionary[String, bool]:
	var inputs: Dictionary[String, bool] = {}
	
	if fighter_parent == null:
		return inputs
	
	opponent_distance = fighter_parent.global_position.distance_to(opponent.global_position)
	
	if opponent_distance <= min_pursuit_distance:
		inputs[backward_input_key] = true
	
	if not fighter_parent.is_on_floor():
		inputs[backward_input_key] = true
		return inputs
	
	if _against_level_bounds():
		fear = 0.0
	
	if attack_phase == AttackPhase.PERFORMING:
		attack_phase = AttackPhase.NONE
		match attack_type:
			1:
				inputs["light_attack"] = true
				return inputs
			2:
				inputs["heavy_attack"] = true
				return inputs
	
	if opponent_attacking:
		var dodge_type: int = _dodge_attack()
		
		if dodge_type > 0:
			inputs[backward_input_key] = true
			
			match dodge_type:
				1:
					inputs["jump"] = true
				2:
					inputs["dash"] = true
		
		opponent_attacking = false
		return inputs
	
	if attack_phase == AttackPhase.NONE:
		_attack_wait_time(_decide_attack())
	
	if not _has_advantage():
		inputs[backward_input_key] = true
		return inputs
	
	if opponent_distance > min_pursuit_distance:
		inputs[forward_input_key] = true
	
	return inputs

func _on_light_attack_detected():
	opponent_attacking = true

func _on_heavy_attack_detected():
	opponent_attacking = true

# 0 = no dodge, 1 = jump, 2 = dash
func _dodge_attack() -> int:
	if not opponent_attacking:
		return 0
	
	if opponent_distance > 1.5:
		return 0
	
	var skill_check: bool = randf() < skill
	
	if not skill_check:
		return 0
	
	var can_jump: bool = stamina_controller.stamina_available(stamina_controller.data.stamina_costs[StaminaData.MoveTypes.JUMP])
	var can_dash: bool = stamina_controller.stamina_available(stamina_controller.data.stamina_costs[StaminaData.MoveTypes.DASH])
	
	if can_dash and not can_jump:
		return 2
	if not can_dash and can_jump:
		return 1
	if can_dash and can_jump:
		return randi_range(1, 2)
	
	return 0

func _on_fighter_damaged(fighter: Fighter):
	if not fighter == fighter_parent:
		return
	fear += fear_gain

func _has_advantage() -> bool:
	
	# calculates a float between -1 and 1
	# 0 means both have equal health
	# a positive number means this character has an advantage
	# a negative number means this character is at a disadvantage
	var health_difference: float = (float(fighter_parent.current_health) - float(opponent.current_health)) / float(fighter_parent.max_health)
	
	var stamina_percent: float = stamina_controller.current_stamina / stamina_controller.data.max_stamina
	var has_enough_stamina: bool = stamina_percent > stamina_advantage_threshold_percent
	
	if fear > bravery or health_difference < -bravery or not has_enough_stamina:
		return false
	return true

func _attack_wait_time(attack: int):
	attack_type = attack
	attack_phase = AttackPhase.WAITING
	await detector.reaction_time_delay()
	attack_phase = AttackPhase.PERFORMING

# 0 = no attack, 1 = light attack, 2 = heavy attack
func _decide_attack() -> int:
	if opponent_distance > heavy_attack_range:
		return 0
	
	var can_heavy_attack: bool = stamina_controller.stamina_available(stamina_controller.data.stamina_costs[StaminaData.MoveTypes.HEAVY_ATTACK])
	var can_light_attack: bool = stamina_controller.stamina_available(stamina_controller.data.stamina_costs[StaminaData.MoveTypes.LIGHT_ATTACK])
	
	var perform_perfect_attack: bool = randf() < skill
	if perform_perfect_attack:
		if opponent_distance > light_attack_range and opponent_distance <= heavy_attack_range:
			if can_heavy_attack:
				return 2
		elif can_light_attack:
			return 1
	
	if randf() < skill:
		if can_heavy_attack and not can_light_attack:
			return 2
		elif not can_heavy_attack and can_light_attack:
			return 1
		else:
			return randi_range(1, 2)
	
	return 0

func _against_level_bounds() -> bool:
	var pos_z: float = arena_center_point.z + fighter_parent.global_position.z
	return pos_z > max_level_bounds or pos_z < min_level_bounds
