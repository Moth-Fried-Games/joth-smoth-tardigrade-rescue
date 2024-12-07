extends Node

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var game_settings: GameSettings = GameSettings.new()
var game_data: GameData = GameData.new()

var audio_manager: AudioManager = AudioManager.new()

var player_bullet: Resource = preload("res://scenes/player_bullet.tscn")
var enemy_bullet: Resource = preload("res://scenes/enemy_bullet.tscn")

var enemy_resources: Dictionary = {
	"Ground Melee": preload("res://scenes/enemies/enemy_test.tscn"),
	"Ground Ranged": preload("res://scenes/enemies/enemy_test.tscn"),
	"Floating Melee": preload("res://scenes/enemies/enemy_fly_test.tscn"),
	"Floating Ranged": preload("res://scenes/enemies/enemy_fly_test.tscn"),
	"Boss": preload("res://scenes/enemies/enemy_test.tscn"),
}

var in_title_screen: bool = false
var loading_screen: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	rng.randomize()
	add_child(game_settings)
	add_child(game_data)
	add_child(audio_manager)
	game_settings.load_settings()
	game_data.load_data()
	audio_manager.load_audio()
