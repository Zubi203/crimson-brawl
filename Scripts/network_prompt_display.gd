class_name PromptManager
extends CanvasLayer

const ROOM_ID_SIZE: int = 5

enum MenuState {
	NONE,
	LOADING,
	CONNECTION_FAILED,
	CONNECTION_LOST,
	JOIN_ROOM
}

@export var panels: Dictionary[MenuState, Control] = {
	MenuState.NONE: null,
	MenuState.LOADING: null,
	MenuState.CONNECTION_FAILED: null,
	MenuState.CONNECTION_LOST: null,
	MenuState.JOIN_ROOM: null
}

@export var background: Control
@export var text_copied_panel: Control
@export var room_id_input: LineEdit
@export var join_room_button: BaseButton

var current_state: MenuState:
	set(value):
		current_state = value
		
		for key in panels.keys():
			if panels[key] == null:
				continue
			if key == current_state and not key == MenuState.NONE:
				panels[key].show()
			else:
				panels[key].hide()
		
		if background == null:
			return
		if current_state == MenuState.NONE:
			background.hide()
			return
		_fade_in_background()

var bg_tween: Tween
var text_copied_tween: Tween

var room_id: String:
	get:
		if room_id_input == null:
			return ""
		return room_id_input.text


func _fade_in_background():
	if background == null:
		return
	
	if bg_tween and bg_tween.is_running():
		bg_tween.kill()
	background.show()
	bg_tween = create_tween()
	bg_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	bg_tween.tween_property(background, "modulate:a", 0.6, 0.3).from(0.0)

func _enter_tree() -> void:
	ServiceLocator.register("prompt_manager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister("prompt_manager")

func _ready() -> void:
	current_state = MenuState.NONE
	
	NetworkManager.OnOnlineIDCreated.connect(_on_text_copied)
	NetworkManager.OnPlayerDisconnected.connect(_on_disconnect)
	NetworkManager.OnServerDisconnected.connect(_on_disconnect.bind(1))
	NetworkManager.OnConnectionFailed.connect(_on_connection_failed)

func _on_text_copied(_text: String):
	if text_copied_panel == null:
		return
	
	if text_copied_tween and text_copied_tween.is_running():
		text_copied_tween.kill()
	text_copied_tween = create_tween()
	text_copied_panel.show()
	text_copied_tween.tween_property(text_copied_panel, "modulate:a", 1.0, 0.4)
	text_copied_tween.tween_interval(1.5)
	text_copied_tween.tween_property(text_copied_panel, "modulate:a", 0.0, 0.4)
	text_copied_tween.tween_callback(text_copied_panel.hide)

func _on_join_game_button_pressed():
	NetworkManager.start_client(room_id)
	current_state = MenuState.NONE

func _on_disconnect(_id: int):
	current_state = MenuState.CONNECTION_LOST

func _on_connection_failed():
	current_state = MenuState.CONNECTION_FAILED

func on_loading_start():
	current_state = MenuState.LOADING

func close_menus():
	current_state = MenuState.NONE

func _update_menu():
	if join_room_button == null:
		return
	if room_id_input == null:
		return
	
	if room_id.length() < 5:
		join_room_button.disabled = true
		return
	
	join_room_button.disabled = false

func _process(_delta: float) -> void:
	_update_menu()
