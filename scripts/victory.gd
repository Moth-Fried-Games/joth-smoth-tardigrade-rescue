extends CanvasLayer

@onready var start_button: Button = $Control/VBoxContainer/VBoxContainer/StartButton
@onready var title_button: Button = $Control/VBoxContainer/VBoxContainer/TitleButton

var victory_jingle: AudioStreamPlayer = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UiMain.ui_player.initialize()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	start_button.pressed.connect(change_to_game)
	title_button.pressed.connect(change_to_menu)
	GameGlobals.in_victory = true
	UiMain.ui_transitions.toggle_transition(false)
	victory_jingle = GameGlobals.audio_manager.create_audio("music_victory")


func change_to_game() -> void:
	GameGlobals.in_victory = false
	if is_instance_valid(victory_jingle):
		GameGlobals.audio_manager.fade_audio_out_and_destroy("music_victory", victory_jingle, 1)
	UiMain.ui_transitions.change_scene_with_loading(GameGlobals.world_scene)


func change_to_menu() -> void:
	GameGlobals.in_victory = false
	if is_instance_valid(victory_jingle):
		GameGlobals.audio_manager.fade_audio_out_and_destroy("music_victory", victory_jingle, 1)
	UiMain.ui_transitions.change_scene(GameGlobals.menu_scene)
