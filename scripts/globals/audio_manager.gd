extends Node
class_name AudioManager

var audio_setting_dict: Dictionary = {}
var persistent_audio: Array[Dictionary] = []


func _process(_delta: float) -> void:
	if persistent_audio.size() > 0:
		for per_aud in range(persistent_audio.size() - 1, -1, -1):
			if is_instance_valid(persistent_audio[per_aud]["Player"]):
				var persistent_audio_player: AudioStreamPlayer = persistent_audio[per_aud]["Player"]
				var reverb_tail: float = persistent_audio[per_aud]["ReverbTail"]
				if persistent_audio_player.is_playing():
					# print("Progress ", persistent_audio[per_aud]["Name"], " Current: ",persistent_audio_player.get_playback_position(), " Tail: ",persistent_audio_player.stream.get_length() - reverb_tail)
					if (
						persistent_audio_player.get_playback_position()
						>= (persistent_audio_player.stream.get_length() - reverb_tail)
					):
						var starting_position: float = (
							(
								persistent_audio_player.get_playback_position()
								- persistent_audio_player.stream.get_length()
							)
							+ reverb_tail
						)
						persistent_audio[per_aud]["Player"].play(starting_position)
						# print("Looping ", persistent_audio[per_aud]["Name"], " From: ",persistent_audio_player.get_playback_position(), " To: ",starting_position)
				else:
					persistent_audio[per_aud]["Player"].play()
					# print("Looping ", persistent_audio[per_aud]["Name"], " From: ",persistent_audio_player.get_playback_position())

			else:
				persistent_audio.remove_at(per_aud)


func load_audio():
	for audio_setting: AudioSettings in GameGlobals.game_data.audio_resources:
		audio_setting_dict[audio_setting.audio_name] = audio_setting


func create_2d_audio_at_location(audio_name: String, location: Vector2) -> AudioStreamPlayer2D:
	if audio_setting_dict.has(audio_name):
		var audio_setting: AudioSettings = audio_setting_dict[audio_name]
		if audio_setting.has_open_limit():
			audio_setting.change_audio_count(1)
			var new_2D_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
			add_child(new_2D_audio)

			match audio_setting.audio_type:
				AudioSettings.AudioType.MUSIC:
					new_2D_audio.bus = "Music"
				AudioSettings.AudioType.SOUND:
					new_2D_audio.bus = "Sounds"
				AudioSettings.AudioType.UI:
					new_2D_audio.bus = "UI"
			new_2D_audio.global_position = location
			new_2D_audio.stream = audio_setting.audio_stream
			new_2D_audio.volume_db = audio_setting.volume
			new_2D_audio.pitch_scale = audio_setting.pitch_scale
			new_2D_audio.pitch_scale += GameGlobals.rng.randf_range(
				-audio_setting.pitch_randomness, audio_setting.pitch_randomness
			)
			new_2D_audio.max_distance = audio_setting.max_distance_2d
			new_2D_audio.finished.connect(new_2D_audio.queue_free)
			new_2D_audio.tree_exited.connect(audio_setting.on_audio_finished)

			new_2D_audio.play()
			return new_2D_audio
		return null
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)
		return null


func create_2d_audio_at_parent(audio_name: String, parent: Node2D) -> AudioStreamPlayer2D:
	if audio_setting_dict.has(audio_name):
		var audio_setting: AudioSettings = audio_setting_dict[audio_name]
		if audio_setting.has_open_limit():
			audio_setting.change_audio_count(1)
			var new_2D_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
			parent.add_child(new_2D_audio)

			match audio_setting.audio_type:
				AudioSettings.AudioType.MUSIC:
					new_2D_audio.bus = "Music"
				AudioSettings.AudioType.SOUND:
					new_2D_audio.bus = "Sounds"
				AudioSettings.AudioType.UI:
					new_2D_audio.bus = "UI"
			new_2D_audio.stream = audio_setting.audio_stream
			new_2D_audio.volume_db = audio_setting.volume
			new_2D_audio.pitch_scale = audio_setting.pitch_scale
			new_2D_audio.pitch_scale += GameGlobals.rng.randf_range(
				-audio_setting.pitch_randomness, audio_setting.pitch_randomness
			)
			new_2D_audio.max_distance = audio_setting.max_distance_2d
			new_2D_audio.finished.connect(new_2D_audio.queue_free)
			new_2D_audio.tree_exited.connect(audio_setting.on_audio_finished)

			new_2D_audio.play()
			return new_2D_audio
		return null
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)
		return null


func create_3d_audio_at_location(audio_name: String, location: Vector3) -> AudioStreamPlayer3D:
	if audio_setting_dict.has(audio_name):
		var audio_setting: AudioSettings = audio_setting_dict[audio_name]
		if audio_setting.has_open_limit():
			audio_setting.change_audio_count(1)
			var new_3D_audio: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			add_child(new_3D_audio)

			match audio_setting.audio_type:
				AudioSettings.AudioType.MUSIC:
					new_3D_audio.bus = "Music"
				AudioSettings.AudioType.SOUND:
					new_3D_audio.bus = "Sounds"
				AudioSettings.AudioType.UI:
					new_3D_audio.bus = "UI"
			new_3D_audio.global_position = location
			new_3D_audio.stream = audio_setting.audio_stream
			new_3D_audio.volume_db = audio_setting.volume
			new_3D_audio.pitch_scale = audio_setting.pitch_scale
			new_3D_audio.pitch_scale += GameGlobals.rng.randf_range(
				-audio_setting.pitch_randomness, audio_setting.pitch_randomness
			)
			new_3D_audio.unit_size = audio_setting.unit_size
			new_3D_audio.max_distance = audio_setting.max_distance_3d
			new_3D_audio.finished.connect(new_3D_audio.queue_free)
			new_3D_audio.tree_exited.connect(audio_setting.on_audio_finished)

			new_3D_audio.play()
			return new_3D_audio
		return null
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)
		return null


func create_3d_audio_at_parent(audio_name: String, parent: Node3D) -> AudioStreamPlayer3D:
	if audio_setting_dict.has(audio_name):
		var audio_setting: AudioSettings = audio_setting_dict[audio_name]
		if audio_setting.has_open_limit():
			audio_setting.change_audio_count(1)
			var new_3D_audio: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			parent.add_child(new_3D_audio)

			match audio_setting.audio_type:
				AudioSettings.AudioType.MUSIC:
					new_3D_audio.bus = "Music"
				AudioSettings.AudioType.SOUND:
					new_3D_audio.bus = "Sounds"
				AudioSettings.AudioType.UI:
					new_3D_audio.bus = "UI"
			new_3D_audio.stream = audio_setting.audio_stream
			new_3D_audio.volume_db = audio_setting.volume
			new_3D_audio.pitch_scale = audio_setting.pitch_scale
			new_3D_audio.pitch_scale += GameGlobals.rng.randf_range(
				-audio_setting.pitch_randomness, audio_setting.pitch_randomness
			)
			new_3D_audio.unit_size = audio_setting.unit_size
			new_3D_audio.max_distance = audio_setting.max_distance_3d
			new_3D_audio.finished.connect(new_3D_audio.queue_free)
			new_3D_audio.tree_exited.connect(audio_setting.on_audio_finished)

			new_3D_audio.play()
			return new_3D_audio
		return null
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)
		return null


func create_audio(audio_name: String) -> AudioStreamPlayer:
	if audio_setting_dict.has(audio_name):
		var audio_setting: AudioSettings = audio_setting_dict[audio_name]
		if audio_setting.has_open_limit():
			audio_setting.change_audio_count(1)
			var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
			add_child(new_audio)

			match audio_setting.audio_type:
				AudioSettings.AudioType.MUSIC:
					new_audio.bus = "Music"
				AudioSettings.AudioType.SOUND:
					new_audio.bus = "Sounds"
				AudioSettings.AudioType.UI:
					new_audio.bus = "UI"
			new_audio.stream = audio_setting.audio_stream
			new_audio.volume_db = audio_setting.volume
			new_audio.pitch_scale = audio_setting.pitch_scale
			new_audio.pitch_scale += GameGlobals.rng.randf_range(
				-audio_setting.pitch_randomness, audio_setting.pitch_randomness
			)
			new_audio.finished.connect(new_audio.queue_free)
			new_audio.tree_exited.connect(audio_setting.on_audio_finished)
			new_audio.play()
			return new_audio
		return null
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)
		return null


func create_persistent_audio(audio_name: String) -> AudioStreamPlayer:
	if audio_setting_dict.has(audio_name):
		var audio_setting: AudioSettings = audio_setting_dict[audio_name]
		audio_setting.change_audio_count(1)
		var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(new_audio)

		match audio_setting.audio_type:
			AudioSettings.AudioType.MUSIC:
				new_audio.bus = "Music"
			AudioSettings.AudioType.SOUND:
				new_audio.bus = "Sounds"
			AudioSettings.AudioType.UI:
				new_audio.bus = "UI"
		new_audio.stream = audio_setting.audio_stream
		new_audio.volume_db = audio_setting.volume
		new_audio.pitch_scale = audio_setting.pitch_scale
		new_audio.pitch_scale += GameGlobals.rng.randf_range(
			-audio_setting.pitch_randomness, audio_setting.pitch_randomness
		)
		new_audio.max_polyphony = 1
		persistent_audio.append(
			{"Name": audio_name, "Player": new_audio, "ReverbTail": audio_setting.reverb_tail}
		)
		new_audio.play()
		return new_audio
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)
		return null


func destroy_audio(audio_name: String, audio_player: AudioStreamPlayer) -> void:
	if audio_setting_dict.has(audio_name):
		var audio_setting: AudioSettings = audio_setting_dict[audio_name]
		audio_setting.change_audio_count(-1)
		audio_player.queue_free()
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)


func destroy_2d_audio(audio_name: String, audio_player: AudioStreamPlayer2D) -> void:
	if audio_setting_dict.has(audio_name):
		var audio_setting: AudioSettings = audio_setting_dict[audio_name]
		audio_setting.change_audio_count(-1)
		audio_player.queue_free()
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)


func destroy_3d_audio(audio_name: String, audio_player: AudioStreamPlayer3D) -> void:
	if audio_setting_dict.has(audio_name):
		var audio_setting: AudioSettings = audio_setting_dict[audio_name]
		audio_setting.change_audio_count(-1)
		audio_player.queue_free()
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)


func fade_audio_out_and_destroy(
	audio_name: String, audio_player: AudioStreamPlayer, fade_duration: float
) -> void:
	if audio_setting_dict.has(audio_name):
		var fade_tween: Tween = create_tween()
		fade_tween.finished.connect(_on_fade_tween_finished.bind(audio_name, audio_player))
		fade_tween.tween_property(audio_player, "volume_db", -80, fade_duration).from_current()
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)


func _on_fade_tween_finished(audio_name: String, audio_player: AudioStreamPlayer) -> void:
	#print("Destroying Faded Audio ", audio_name, " ", audio_player)
	destroy_audio(audio_name, audio_player)


func fade_audio_out(
	audio_name: String, audio_player: AudioStreamPlayer, fade_duration: float
) -> void:
	if audio_setting_dict.has(audio_name):
		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(audio_player, "volume_db", -80, fade_duration).from_current()
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)


func fade_audio_in(
	audio_name: String, audio_player: AudioStreamPlayer, fade_duration: float
) -> void:
	if audio_setting_dict.has(audio_name):
		var audio_setting: AudioSettings = audio_setting_dict[audio_name]
		var fade_tween: Tween = create_tween()
		(
			fade_tween
			. tween_property(audio_player, "volume_db", audio_setting.volume, fade_duration)
			. from_current()
		)
	else:
		push_error("Audio Manager failed to find setting for name ", audio_name)
