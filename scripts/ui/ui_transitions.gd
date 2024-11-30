extends CanvasLayer
class_name UITransitions

@onready var control_node: Control = $Control
@onready var progress_bar: ProgressBar = $Control/LoadingVBoxContainer/ProgressBar
@onready var loading_timer: Timer = $Timer

var transition_toggle: bool = false
var progress_value: float = 0

var loading_sounds: AudioStreamPlayer = null


func _ready() -> void:
	control_node.visible = false
	loading_timer.connect("timeout", _loading_timeout)


func change_scene(scene_path: String) -> void:
	toggle_transition(true)
	get_tree().change_scene_to_file(scene_path)


func update_progress_value(new_progress_value: float) -> void:
	progress_value = new_progress_value
	progress_bar.value = progress_value


func toggle_transition(new_transition_toggle: bool) -> void:
	transition_toggle = new_transition_toggle
	if transition_toggle:
		update_progress_value(0)
		control_node.visible = true
		GameGlobals.loading_screen = control_node.visible
		loading_sounds = GameGlobals.audio_manager.create_persistent_audio("ui_loading")
	else:
		if loading_timer.is_stopped():
			loading_timer.start()


func _loading_timeout() -> void:
	control_node.visible = false
	GameGlobals.loading_screen = control_node.visible
	update_progress_value(0)
	GameGlobals.audio_manager.fade_audio_out("ui_loading", loading_sounds, 1)
