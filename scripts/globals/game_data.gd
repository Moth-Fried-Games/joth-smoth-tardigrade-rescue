extends Node
class_name GameData

var audio_resources: Array[AudioSettings] = []

var resource_dict: Dictionary = {}

var game_paths: GamePaths = GamePaths.new()



func load_data() -> void:
	game_paths.load_paths()

	for audio_setting in game_paths.audio_resource_paths:
		var audio_setting_resource: AudioSettings = load(
			game_paths.audio_resource_paths[audio_setting]
		)
		audio_setting_resource.audio_name = audio_setting.get_basename().get_file()
		audio_resources.append(audio_setting_resource)


func get_threaded_resource(resource_name: String) -> Resource:
	if resource_dict.has(resource_name):
		if is_instance_valid(resource_dict[resource_name]):
			return resource_dict[resource_name]

	var is_resource_loaded: ResourceLoader.ThreadLoadStatus = (
		ResourceLoader.load_threaded_get_status(resource_name)
	)

	if is_resource_loaded != ResourceLoader.THREAD_LOAD_LOADED:
		ResourceLoader.load_threaded_request(resource_name)
		while is_resource_loaded != ResourceLoader.THREAD_LOAD_LOADED:
			await get_tree().process_frame
			is_resource_loaded = ResourceLoader.load_threaded_get_status(resource_name)

	if is_resource_loaded == ResourceLoader.THREAD_LOAD_LOADED:
		resource_dict[resource_name] = ResourceLoader.load_threaded_get(resource_name)
		return resource_dict[resource_name]
	else:
		return null
