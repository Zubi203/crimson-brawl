extends CanvasLayer



func _on_local_mp_button_pressed() -> void:
	GlobalData.game_mode = GlobalData.GameMode.LOCAL_PLAYER_VS_PLAYER
	SceneTransition.transition(GlobalData.Scenes.MAIN_GAME, GlobalData.Scenes.TITLE_SCREEN)


func _on_pv_e_button_pressed() -> void:
	GlobalData.game_mode = GlobalData.GameMode.PLAYER_VS_AI
	SceneTransition.transition(GlobalData.Scenes.MAIN_GAME, GlobalData.Scenes.TITLE_SCREEN)


func _on_online_mp_button_pressed() -> void:
	GlobalData.game_mode = GlobalData.GameMode.ONLINE_MULTIPLAYER
	SceneTransition.transition(GlobalData.Scenes.MAIN_GAME, GlobalData.Scenes.TITLE_SCREEN)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
