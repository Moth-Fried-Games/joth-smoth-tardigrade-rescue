@tool
extends EditorPlugin

var editor_control: FlowContainer = null

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	editor_control = FlowContainer.new()
	editor_control.set_anchors_preset(Control.PRESET_CENTER)
	editor_control.alignment = FlowContainer.ALIGNMENT_CENTER
	editor_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor_control.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var update_dictionary_button: Button = Button.new()
	update_dictionary_button.text = "Update Dictionaries"
	update_dictionary_button.set_anchors_preset(Control.PRESET_CENTER)
	update_dictionary_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	update_dictionary_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	update_dictionary_button.pressed.connect(update_dictionaries)
	editor_control.add_child(update_dictionary_button)
	add_control_to_bottom_panel(editor_control,"Editor Scripts")

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_bottom_panel(editor_control)
	editor_control.queue_free()

# Dictionary Updating

var audio_resource_paths: Dictionary = {}

var dictionary_path: String = "res://scripts/dictionaries/"

func save_dictionary(file_name: String, dictionary_data: Dictionary) -> void:
	var dictionary_file := FileAccess.open(str(dictionary_path,file_name), FileAccess.WRITE)
	var json_string := JSON.stringify(dictionary_data)
	dictionary_file.store_line(json_string)
	dictionary_file.close()

func update_dictionaries() -> void:
	# Populate Audio Paths
	for audio_setting_file in GameUtils.get_all_files("res://assets/audio/","tres"):
		audio_resource_paths[audio_setting_file.get_file().get_basename()] = audio_setting_file
	save_dictionary("audio_resource_paths.json", audio_resource_paths)
	print("Dictionaries Updated")
