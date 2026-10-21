extends Node

enum Scenes {
	TITLE_SCREEN,
	MAIN_GAME
}

enum GameMode {
	LOCAL_PLAYER_VS_PLAYER,
	PLAYER_VS_AI,
	ONLINE_MULTIPLAYER
}

var current_scene: Scenes = Scenes.TITLE_SCREEN
const SCENE_PATHS: Dictionary[Scenes, String] = {
	Scenes.TITLE_SCREEN: "uid://bilxhlx6q35ji",
	Scenes.MAIN_GAME: "uid://dvck7orxrqv5b"
}

var game_mode: GameMode
