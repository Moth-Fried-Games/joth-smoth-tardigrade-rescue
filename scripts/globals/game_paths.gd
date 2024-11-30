@tool
extends Node
class_name GamePaths

var audio_resource_paths: Dictionary = {}

var dictionary_path: String = "res://scripts/dictionaries/"


func load_dictionary(file_name: String) -> Dictionary:
	var dictionary_file := FileAccess.open(str(dictionary_path, file_name), FileAccess.READ)
	var json_string := dictionary_file.get_line()
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if not parse_result == OK:
		print(
			"JSON Parse Error: ",
			json.get_error_message(),
			" in ",
			json_string,
			" at line ",
			json.get_error_line()
		)
	dictionary_file.close()
	return json.data


# Called when the node enters the scene tree for the first time.
func load_paths() -> void:
	audio_resource_paths = load_dictionary("audio_resource_paths.json")
