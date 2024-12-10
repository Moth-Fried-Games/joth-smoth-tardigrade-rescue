extends CanvasLayer

@onready var start_button: Button = $Control/VBoxContainer/StartButton
@onready var quit_button: Button = $Control/VBoxContainer/QuitButton

func _ready() -> void:
	UiMain.ui_player.initialize()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	start_button.pressed.connect(change_to_game)
	quit_button.pressed.connect(quit_game)
	GameGlobals.in_menu = true
	UiMain.ui_transitions.toggle_transition(false)

func change_to_game() -> void:
	GameGlobals.in_menu = true
	UiMain.ui_transitions.change_scene_with_loading(GameGlobals.world_scene)

func quit_game() -> void:
	get_tree().quit()
