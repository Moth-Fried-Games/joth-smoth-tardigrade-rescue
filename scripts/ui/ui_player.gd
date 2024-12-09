extends CanvasLayer
class_name UIPlayer

@onready var crosshair_texture_rect: TextureRect = $Control/CrosshairTextureRect
@onready var stress_texture_progress_bar: TextureProgressBar = $Control/StressTextureProgressBar
@onready var weapon_animation_player: AnimationPlayer = $Control/Weapons/WeaponAnimationPlayer
@onready var petting_animation_player: AnimationPlayer = $Control/Petting/PettingAnimationPlayer
@onready var punch_l: AnimatedSprite2D = $Control/Weapons/Control/PunchL
@onready var punch_r: AnimatedSprite2D = $Control/Weapons/Control2/PunchR
@onready var gun_l: AnimatedSprite2D = $Control/Weapons/Control3/GunL
@onready var gun_r: AnimatedSprite2D = $Control/Weapons/Control4/GunR
@onready var pet_l: AnimatedSprite2D = $Control/Petting/Control/PetL
@onready var pet_u: AnimatedSprite2D = $Control/Petting/Control2/PetU
@onready var pet_timer: Timer = $PetTimer

var player_node: CharacterBody3D = null

var gun_side: bool = false
var punch_side: bool = false

var stress: float = 0

var durability: float = 0

var weapons_equipped: bool = false
var petting_equipped: bool = false


func _ready() -> void:
	weapon_animation_player.animation_finished.connect(
		_on_weapon_animation_player_animation_finished
	)
	petting_animation_player.animation_finished.connect(
		_on_petting_animation_player_animation_finished
	)
	pet_l.animation_finished.connect(_on_pet_l_animation_finished)
	pet_u.animation_finished.connect(_on_pet_u_animation_finished)
	punch_l.animation_finished.connect(_on_punch_l_animation_finished)
	punch_r.animation_finished.connect(_on_punch_r_animation_finished)
	gun_l.animation_finished.connect(_on_gun_l_animation_finished)
	gun_r.animation_finished.connect(_on_gun_r_animation_finished)
	weapon_animation_player.play("equip")
	petting_animation_player.play("new")


func _process(_delta: float) -> void:
	var stress_percent: float = (stress / 60.0) * 100.0
	stress_texture_progress_bar.value = stress_percent

	if weapons_equipped:
		if player_node.velocity == Vector3.ZERO:
			weapon_animation_player.play("idle")
		elif player_node.velocity != Vector3.ZERO and player_node.is_on_floor():
			weapon_animation_player.play("move")
		else:
			weapon_animation_player.play("RESET")


func increase_stress(value: float) -> void:
	stress += value
	stress = clampf(stress, 0, 60)


func decrease_stress(value: float) -> void:
	stress -= value
	stress = clampf(stress, 0, 60)


func switch_to_pet_plushie() -> void:
	weapon_animation_player.play("unequip")
	weapons_equipped = false
	durability = randf_range(2, 4)


func switch_to_pet_real() -> void:
	weapon_animation_player.play("unequip")
	weapons_equipped = false
	durability = 666


func switch_to_weapon() -> void:
	petting_animation_player.play("unequip")
	petting_equipped = false


func pet_left() -> void:
	if petting_equipped:
		if durability < 666:
			if pet_l.animation == "idle_plush" and pet_u.animation == "idle":
				pet_l.play("pet_left_plush")
				pet_u.play("pet_left")
		else: 
			if pet_l.animation == "idle_real" and pet_u.animation == "idle":
				pet_l.play("pet_left_real")
				pet_u.play("pet_left")
				


func pet_right() -> void:
	if petting_equipped:
		if durability < 666:
			if pet_l.animation == "idle_plush" and pet_u.animation == "idle":
				pet_l.play("pet_right_plush")
				pet_u.play("pet_right")
		else: 
			if pet_l.animation == "idle_real" and pet_u.animation == "idle":
				pet_l.play("pet_right_real")
				pet_u.play("pet_right")

func _on_pet_l_animation_finished() -> void:
	if durability < 666:
		pet_l.play("idle_plush")
	else:
		pet_l.play("idle_real")
	pet_the_thing()

func _on_pet_u_animation_finished() -> void:
	pet_u.play("idle")

func pet_the_thing() -> void:
	decrease_stress(1)
	if pet_timer.is_stopped():
		if durability < 666:
			switch_to_weapon()


func fire_guns() -> void:
	if weapons_equipped:
		if gun_side:
			if gun_r.animation == "idle" and gun_l.animation != "shoot":
				gun_l.play("shoot")
				gun_side = !gun_side
				gun_check()
		else:
			if gun_l.animation == "idle" and gun_r.animation != "shoot":
				gun_r.play("shoot")
				gun_side = !gun_side
				gun_check()


func throw_punch() -> void:
	if weapons_equipped:
		if punch_side:
			if punch_r.animation == "idle" and punch_l.animation != "punch":
				punch_l.play("punch")
				punch_side = !punch_side
				punch_check()
		else:
			if punch_l.animation == "idle" and punch_r.animation != "punch":
				punch_r.play("punch")
				punch_side = !punch_side
				punch_check()


func gun_check() -> void:
	if is_instance_valid(player_node):
		player_node.gun_check(gun_side)


func punch_check() -> void:
	if is_instance_valid(player_node):
		player_node.punch_check()


func _on_weapon_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "equip":
		weapons_equipped = true
	if anim_name == "unequip":
		petting_animation_player.play("equip")


func _on_petting_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "equip":
		petting_equipped = true
		pet_timer.start(durability)
	if anim_name == "unequip":
		weapon_animation_player.play("equip")


func _on_punch_l_animation_finished() -> void:
	if punch_l.animation == "punch":
		punch_l.play("idle")


func _on_punch_r_animation_finished() -> void:
	if punch_r.animation == "punch":
		punch_r.play("idle")


func _on_gun_l_animation_finished() -> void:
	if gun_l.animation == "shoot":
		gun_l.play("idle")


func _on_gun_r_animation_finished() -> void:
	if gun_r.animation == "shoot":
		gun_r.play("idle")
