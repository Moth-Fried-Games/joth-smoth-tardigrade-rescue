extends CanvasLayer
class_name UITransitions

@onready var control_node: Control = $Control
@onready var progress_bar: ProgressBar = $Control/LoadingVBoxContainer/ProgressBar
@onready var loading_timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $Fade/AnimationPlayer

var transition_toggle: bool = false
var progress_value: float = 0

var loading_sounds: AudioStreamPlayer = null

var scene_path: String = ""
var loading_bar: bool = false

func _ready() -> void:
	control_node.visible = false
	loading_timer.connect("timeout", _loading_timeout)
	animation_player.animation_finished.connect(_on_fade_finished)

func _on_fade_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		if loading_bar:
			toggle_transition(true)
		get_tree().change_scene_to_file(scene_path)
	if anim_name == "fade_out":
		GameGlobals.loading_screen = false

func change_scene(new_scene_path: String) -> void:
	scene_path = new_scene_path
	loading_bar = false
	animation_player.play("fade_in")

func change_scene_with_loading(new_scene_path: String) -> void:
	scene_path = new_scene_path
	loading_bar = true
	animation_player.play("fade_in")


func update_progress_value(new_progress_value: float) -> void:
	progress_value = new_progress_value
	progress_bar.value = progress_value


func toggle_transition(new_transition_toggle: bool) -> void:
	transition_toggle = new_transition_toggle
	if transition_toggle:
		update_progress_value(0)
		control_node.visible = true
		GameGlobals.loading_screen = true
		#loading_sounds = GameGlobals.audio_manager.create_persistent_audio("ui_loading")
	else:
		if loading_timer.is_stopped():
			loading_timer.start()

func _loading_timeout() -> void:
	if control_node.visible:
		control_node.visible = false
	update_progress_value(0)
	animation_player.play("fade_out")
	#GameGlobals.audio_manager.fade_audio_out("ui_loading", loading_sounds, 1)
