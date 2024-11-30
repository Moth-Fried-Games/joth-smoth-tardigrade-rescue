extends Node
class_name GameSettings

var display_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
var vsync_mode: DisplayServer.VSyncMode = DisplayServer.VSYNC_ENABLED
var frame_rate_cap: int = 0
var show_fps: bool = true
var crt_filter: bool = true

var master_volume: float = 0.5
var music_volume: float = 0.5
var sound_volume: float = 0.5
var ui_volume: float = 0.5

var last_viewport_size: Vector2 = Vector2.ZERO


func _process(_delta: float) -> void:
	update_stretch_mode()


func update_stretch_mode() -> void:
	var current_viewport_size: Vector2 = get_window().size
	if last_viewport_size != current_viewport_size:
		last_viewport_size = current_viewport_size
		if last_viewport_size.x >= 1280 and last_viewport_size.y >= 720:
			get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
			get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
			#print("Normal Window")
		else:
			get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
			get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
			#print("Smaller Window")


func load_settings() -> void:
	update_display_mode(display_mode)
	update_vsync_mode(vsync_mode)
	update_frame_rate_cap(frame_rate_cap)
	update_master_volume(master_volume)
	update_music_volume(music_volume)
	update_sound_volume(sound_volume)
	update_ui_volume(ui_volume)


func update_display_mode(new_display_mode: DisplayServer.WindowMode) -> void:
	display_mode = new_display_mode
	DisplayServer.window_set_mode(display_mode)


func update_vsync_mode(new_vsync_mode: DisplayServer.VSyncMode) -> void:
	vsync_mode = new_vsync_mode
	DisplayServer.window_set_vsync_mode(vsync_mode)


func update_frame_rate_cap(new_frame_rate_cap: int) -> void:
	frame_rate_cap = new_frame_rate_cap
	match frame_rate_cap:
		0:
			Engine.set_max_fps(0)
		1:
			Engine.set_max_fps(30)
		2:
			Engine.set_max_fps(60)
		3:
			var display_refresh: float = DisplayServer.screen_get_refresh_rate()
			Engine.set_max_fps(ceili(display_refresh))


func update_show_fps(new_show_fps: bool) -> void:
	show_fps = new_show_fps


func update_crt_filter(new_crt_filter: bool) -> void:
	crt_filter = new_crt_filter


func update_master_volume(new_master_volume: float) -> void:
	master_volume = new_master_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))


func update_music_volume(new_music_volume: float) -> void:
	music_volume = new_music_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))


func update_sound_volume(new_sound_volume: float) -> void:
	sound_volume = new_sound_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear_to_db(sound_volume))


func update_ui_volume(new_ui_volume: float) -> void:
	ui_volume = new_ui_volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear_to_db(ui_volume))
