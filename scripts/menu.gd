extends CanvasLayer

var menu_music: AudioStreamPlayer = null

@onready var tab_container: TabContainer = $Control/TabContainer

# Main Menu
@onready var start_button: Button = $Control/TabContainer/Main/VBoxContainer/StartButton
@onready var how_button: Button = $Control/TabContainer/Main/VBoxContainer/HowButton
@onready var settings_button: Button = $Control/TabContainer/Main/VBoxContainer/SettingsButton
@onready var credits_button: Button = $Control/TabContainer/Main/VBoxContainer/CreditsButton
@onready var quit_button: Button = $Control/TabContainer/Main/VBoxContainer/QuitButton

# How to Play
@onready var howto_return_button: Button = $Control/TabContainer/HowTo/VBoxContainer/ReturnButton

# Settings
@onready
var settings_return_button: Button = $Control/TabContainer/Settings/VBoxContainer/ReturnButton

# Credits
@onready var credits_return_button: Button = $Control/TabContainer/Credits/VBoxContainer/ReturnButton
@onready
var credits_rich_text_label: RichTextLabel = $Control/TabContainer/Credits/VBoxContainer/RichTextLabel


func _ready() -> void:
	start_button.pressed.connect(change_to_game)
	quit_button.pressed.connect(quit_game)
	how_button.pressed.connect(howto_menu)
	settings_button.pressed.connect(settings_menu)
	credits_button.pressed.connect(credits_menu)
	howto_return_button.pressed.connect(main_menu)
	settings_return_button.pressed.connect(main_menu)
	credits_return_button.pressed.connect(main_menu)
	credits_rich_text_label.meta_clicked.connect(credits_click_link)
	UiMain.ui_player.initialize()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameGlobals.in_menu = true
	UiMain.ui_transitions.toggle_transition(false)
	menu_music = GameGlobals.audio_manager.create_persistent_audio("music_menu")
	tab_container.current_tab = 0


func _input(_event: InputEvent) -> void:
	if Input.is_anything_pressed() and tab_container.current_tab == 0:
		main_menu()


func main_menu() -> void:
	tab_container.current_tab = 1


func howto_menu() -> void:
	tab_container.current_tab = 2


func settings_menu() -> void:
	tab_container.current_tab = 3


func credits_menu() -> void:
	tab_container.current_tab = 4


func credits_click_link(meta: Variant) -> void:
	OS.shell_open(meta)


func change_to_game() -> void:
	GameGlobals.in_menu = true
	GameGlobals.audio_manager.fade_audio_out_and_destroy("music_menu", menu_music, 1)
	UiMain.ui_transitions.change_scene_with_loading(GameGlobals.world_scene)


func quit_game() -> void:
	get_tree().quit()
