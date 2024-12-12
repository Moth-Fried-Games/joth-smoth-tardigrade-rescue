extends Resource
class_name AudioSettings

enum AudioType { MUSIC, SOUND, UI }

@export_range(0, 10) var limit: int = 5
@export var audio_name: String
@export var audio_type: AudioType
@export var audio_stream: AudioStream
@export_range(-40, 20) var volume: float = 0.0
@export_range(0.0, 4.0, .01) var pitch_scale: float = 1.0
@export_range(0.0, 1.0, .01) var pitch_randomness: float = 0.0
@export var max_distance_2d: float = 2000
@export var unit_size: float = 10
@export var max_distance_3d: float = 0
@export var reverb_tail: float = 0.0

var audio_count: int = 0


func change_audio_count(amount: int):
	audio_count = max(0, audio_count + amount)


func has_open_limit() -> bool:
	return audio_count < limit


func on_audio_finished():
	change_audio_count(-1)
