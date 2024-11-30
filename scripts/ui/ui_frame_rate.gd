extends CanvasLayer
class_name UIFrameRate

@onready var fps_label: Label = $Control/Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameGlobals.game_settings.show_fps:
		if not visible:
			visible = true
		fps_label.text = str(Engine.get_frames_per_second(), " FPS")
	else:
		if visible:
			visible = false
