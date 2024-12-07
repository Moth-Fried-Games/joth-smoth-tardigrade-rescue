extends CharacterBody3D

const SPEED: float  = 6.0
const JUMP_VELOCITY: float  = 4.5

@onready var standing_collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var placeholder_sprite_3d: Sprite3D = $PlaceholderSprite3D
@onready var melee_ray_cast_3d: RayCast3D = $MeleeRayCast3D
@onready var range_ray_cast_3d: RayCast3D = $RangeRayCast3D
@onready var melee_timer: Timer = $MeleeTimer
@onready var range_timer: Timer = $RangeTimer
@onready var telegraph_timer: Timer = $TelegraphTimer
@onready var bullet_marker_3d: Marker3D = $PlaceholderSprite3D/BulletMarker3D

var world_node: Node3D = null
var player_node: CharacterBody3D = null
var camera_node: Camera3D = null
var starting_position: Vector3 = Vector3.INF

var dead: bool = false
var melee: bool = false
var ranged: bool = true

var attacking: bool = false

func _ready() -> void:
	world_node = get_tree().current_scene
	player_node = world_node.player_node
	camera_node = world_node.camera_node
	if starting_position != Vector3.INF:
		global_position = starting_position
	if not is_in_group("enemies"):
		add_to_group("enemies")

func shoot_player() -> void:
	var enemy_bullet = GameGlobals.enemy_bullet.instantiate()
	var bullet_target: Vector3 = Vector3()
	if player_node.wish_crouch:
		bullet_target = player_node.global_transform.origin + Vector3(0, 0.5, 0)
	else:
		bullet_target = player_node.global_transform.origin + Vector3(0, 1, 0)
	enemy_bullet.direction = bullet_marker_3d.global_position.direction_to(bullet_target)
	enemy_bullet.starting_position = bullet_marker_3d.global_position
	world_node.add_child(enemy_bullet)

func _physics_process(delta: float) -> void:
	# Melee Player if close.
	if melee:
		if melee_ray_cast_3d.is_colliding():
			var collided_with := melee_ray_cast_3d.get_collider()
			if is_instance_valid(collided_with):
				if collided_with.is_in_group("players"):
					if not attacking and telegraph_timer.is_stopped() and melee_timer.is_stopped():
						telegraph_timer.start()
						attacking = true
					if attacking and telegraph_timer.is_stopped() and melee_timer.is_stopped():
						attacking = false
						melee_timer.start()
						player_node.process_hit()
	# Shoot if the Player is in sight.
	if ranged:
		if range_ray_cast_3d.is_colliding():
			var collided_with := range_ray_cast_3d.get_collider()
			if is_instance_valid(collided_with):
				if collided_with.is_in_group("players"):
					if not attacking and telegraph_timer.is_stopped() and range_timer.is_stopped():
						telegraph_timer.start()
						attacking = true
					if attacking and telegraph_timer.is_stopped() and range_timer.is_stopped():
						attacking = false
						range_timer.start()
						shoot_player()

	# Make sprite look at camera.
	placeholder_sprite_3d.look_at(camera_node.global_transform.origin, Vector3(0, 1, 0))
	if player_node.wish_crouch:
		melee_ray_cast_3d.look_at(
			player_node.global_transform.origin + Vector3(0, 0.5, 0), Vector3(0, 1, 0)
		)
		range_ray_cast_3d.look_at(
			player_node.global_transform.origin + Vector3(0, 0.5, 0), Vector3(0, 1, 0)
		)
	else:
		melee_ray_cast_3d.look_at(
			player_node.global_transform.origin + Vector3(0, 1, 0), Vector3(0, 1, 0)
		)
		range_ray_cast_3d.look_at(
			player_node.global_transform.origin + Vector3(0, 1, 0), Vector3(0, 1, 0)
		)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Move towards the player.
	var direction := global_position.direction_to(player_node.global_position)
	if direction and not attacking:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func process_hit() -> void:
	if not dead:
		dead = true
		UiMain.ui_player.decrease_stress(1)
		queue_free()
