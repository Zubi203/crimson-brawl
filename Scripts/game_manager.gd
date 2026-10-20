class_name GameManager
extends Node

enum GameState{
	LOADING,
	COUNTDOWN,
	PLAYING,
	ENDED
}
var current_state: GameState

@export var animation_player: AnimationPlayer
@export var start_animation_name: String = "Start"
@export var end_animation_name: String = "End"
@export var end_text_label: Label

func _enter_tree() -> void:
	ServiceLocator.register("game_manager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister("game_manager")

func _ready() -> void:
	GlobalEvents.FighterDefeated.connect(_on_fighter_defeated)
	
	if animation_player == null:
		return
	animation_player.animation_finished.connect(_on_animation_finished)
	_change_state(GameState.COUNTDOWN)

func _change_state(new_state: GameState):
	current_state = new_state
	
	match current_state:
		GameState.LOADING:
			pass
		GameState.COUNTDOWN:
			animation_player.play(start_animation_name)
		GameState.PLAYING:
			pass
		GameState.ENDED:
			animation_player.play(end_animation_name)

func _on_fighter_defeated(fighter: Fighter):
	_change_state(GameState.ENDED)
	
	if end_text_label == null:
		return
	
	if fighter.player_id == 0:
		end_text_label.text = "PLAYER 2 WINS!"
	else:
		end_text_label.text = "PLAYER 1 WINS!"

func _on_animation_finished(anim_name: String):
	if anim_name == start_animation_name:
		_change_state(GameState.PLAYING)
		return
	
	if anim_name == end_animation_name:
		# return to menu
		return
