class_name FighterHUD
extends CanvasLayer

var fighter_parent: Fighter = null

@export var health_bar: Range
@export var health_bar_underlay: Range
@export var health_text: Label
@export var stamina_bar: Range
@export var stats_container: Control
@export var player_pos_0: Control
@export var player_pos_1: Control

var health_underlay_tween: Tween
const UNDERLAY_MOVE_SPEED: float = 0.5

func _ready() -> void:
	if owner is Fighter:
		fighter_parent = owner
	
	if fighter_parent == null:
		return
	
	_set_max_values(fighter_parent)
	fighter_parent.HealthChanged.connect(_update_health)
	fighter_parent.StaminaUpdated.connect(_update_stamina)
	
	if stats_container == null:
		return
	if player_pos_0 == null:
		return
	if player_pos_1 == null:
		return
	
	match fighter_parent.player_id:
		0:
			stats_container.position = player_pos_0.position
		_:
			stats_container.position = player_pos_1.position
			stats_container.offset_transform_scale.x *= -1

func _update_stamina(stamina: float):
	if stamina_bar == null:
		return
	stamina_bar.value = stamina

func _update_health(fighter: Fighter):
	if fighter == null:
		return
	if fighter != fighter_parent:
		return
	
	if health_bar == null:
		return
	health_bar.value = fighter.current_health
	
	if health_bar_underlay == null:
		return
	if health_underlay_tween and health_underlay_tween.is_running():
		health_underlay_tween.kill()
	health_underlay_tween = create_tween()
	health_underlay_tween.tween_property(health_bar_underlay, "value", fighter.current_health, UNDERLAY_MOVE_SPEED)
	
	if health_text == null:
		return
	health_text.text = str(fighter.current_health, " / ", fighter.max_health)
	
	
func _set_max_values(fighter: Fighter):
	if health_bar == null:
		return
	health_bar.max_value = fighter.max_health
	
	if health_bar_underlay == null:
		return
	health_bar_underlay.max_value = fighter.max_health
	
	if stamina_bar == null:
		return
	stamina_bar.max_value = fighter.max_stamina
	
	
