extends CanvasLayer
class_name UIPlayer

@onready var crosshair_texture_rect: TextureRect = $Control/CrosshairTextureRect
@onready var stress_texture_progress_bar: TextureProgressBar = $Control/StressTextureProgressBar
@onready var guns_animation_player: AnimationPlayer = $Control/Weapons/GunsAnimationPlayer
@onready var punches_animation_player: AnimationPlayer = $Control/Weapons/PunchesAnimationPlayer

var player_node: CharacterBody3D = null

var gun_side: bool = false
var punch_side: bool = false

var stress: float = 0

func _process(_delta: float) -> void:
	var stress_percent: float = (stress / 60.0) * 100.0
	stress_texture_progress_bar.value = stress_percent

func increase_stress(value: float) -> void:
	stress += value
	stress = clampf(stress, 0, 60)

func decrease_stress(value: float) -> void:
	stress -= value
	stress = clampf(stress, 0, 60)

func fire_guns() -> void:
	if not guns_animation_player.is_playing():
		if gun_side:
			guns_animation_player.play("shoot_left")
			gun_side = !gun_side
		else:
			guns_animation_player.play("shoot_right")
			gun_side = !gun_side

func throw_punch() -> void:
	if not punches_animation_player.is_playing():
		if punch_side:
			punches_animation_player.play("punch_left")
			punch_side = !punch_side
		else:
			punches_animation_player.play("punch_right")
			punch_side = !punch_side

func gun_check() -> void:
	if is_instance_valid(player_node):
		player_node.gun_check(gun_side)

func punch_check() -> void:
	if is_instance_valid(player_node):
		player_node.punch_check()
