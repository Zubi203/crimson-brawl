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

@export var fighter_0_spawn: Node3D
@export var fighter_1_spawn: Node3D

@export var ranger_fighter_scene: PackedScene
@export var tavernkeep_fighter_scene: PackedScene
@export var ai_fighter_scene: PackedScene

func _enter_tree() -> void:
	ServiceLocator.register("game_manager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister("game_manager")

func _ready() -> void:
	GlobalEvents.FighterDefeated.connect(_on_fighter_defeated)
	
	if animation_player == null:
		return
	animation_player.animation_finished.connect(_on_animation_finished)
	_change_state(GameState.LOADING)

func _setup_fighters():
	if ai_fighter_scene == null or ranger_fighter_scene == null or tavernkeep_fighter_scene == null:
		return
	if fighter_0_spawn == null or fighter_1_spawn == null:
		return
	
	var left_fighter: Fighter
	var right_fighter: Fighter
	
	match GlobalData.game_mode:
		GlobalData.GameMode.LOCAL_PLAYER_VS_PLAYER:
			left_fighter = spawn_fighter(ranger_fighter_scene)
			right_fighter = spawn_fighter(tavernkeep_fighter_scene)
		GlobalData.GameMode.ONLINE_MULTIPLAYER:
			left_fighter = spawn_fighter(ranger_fighter_scene)
			right_fighter = spawn_fighter(tavernkeep_fighter_scene)
		GlobalData.GameMode.PLAYER_VS_AI:
			left_fighter = spawn_fighter(ranger_fighter_scene)
			right_fighter = spawn_fighter(ai_fighter_scene)
	
	left_fighter.setup(right_fighter, 0)
	right_fighter.setup(left_fighter, 1)
	
	left_fighter.global_position = fighter_0_spawn.global_position
	right_fighter.global_position = fighter_1_spawn.global_position
	
	_change_state(GameState.COUNTDOWN)

func spawn_fighter(fighter_scene: PackedScene) -> Fighter:
	var fighter: Fighter = fighter_scene.instantiate()
	get_tree().current_scene.add_child(fighter)
	return fighter

func _change_state(new_state: GameState):
	current_state = new_state
	
	match current_state:
		GameState.LOADING:
			_setup_fighters.call_deferred()
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
	
	match GlobalData.game_mode:
		GlobalData.GameMode.PLAYER_VS_AI:
			if fighter.player_id == 0:
				end_text_label.text = "DEFEAT!"
			else:
				end_text_label.text = "VICTORY!"
		_:
			if fighter.player_id == 0:
				end_text_label.text = "PLAYER 2 WINS!"
			else:
				end_text_label.text = "PLAYER 1 WINS!"
		

func _on_animation_finished(anim_name: String):
	if anim_name == start_animation_name:
		_change_state(GameState.PLAYING)
		return
	
	if anim_name == end_animation_name:
		SceneTransition.transition(GlobalData.Scenes.TITLE_SCREEN, GlobalData.Scenes.MAIN_GAME)
		return
