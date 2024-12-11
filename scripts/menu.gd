extends CanvasLayer

var menu_music: AudioStreamPlayer = null

# Main Menu
@onready var start_button: Button = $Control/TabContainer/Main/VBoxContainer/StartButton
@onready var how_button: Button = $Control/TabContainer/Main/VBoxContainer/HowButton
@onready var settings_button: Button = $Control/TabContainer/Main/VBoxContainer/SettingsButton
@onready var credits_button: Button = $Control/TabContainer/Main/VBoxContainer/CreditsButton
@onready var quit_button: Button = $Control/TabContainer/Main/VBoxContainer/QuitButton

# How to Play

# Settings

# Credits

func _ready() -> void:
	UiMain.ui_player.initialize()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	start_button.pressed.connect(change_to_game)
	quit_button.pressed.connect(quit_game)
	GameGlobals.in_menu = true
	UiMain.ui_transitions.toggle_transition(false)
	menu_music = GameGlobals.audio_manager.create_persistent_audio("music_menu")

func change_to_game() -> void:
	GameGlobals.in_menu = true
	GameGlobals.audio_manager.fade_audio_out_and_destroy("music_menu",menu_music,1)
	UiMain.ui_transitions.change_scene_with_loading(GameGlobals.world_scene)

func quit_game() -> void:
	get_tree().quit()
