extends CharacterBody3D


const SPEED = 6.0
const JUMP_VELOCITY = 4.5

@onready var standing_collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var placeholder_sprite_3d: Sprite3D = $PlaceholderSprite3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var melee_timer: Timer = $MeleeTimer

var world_node: Node3D = null
var player_node: CharacterBody3D = null
var camera_node: Camera3D = null


func _ready() -> void:
	world_node = get_tree().current_scene
	player_node = world_node.player_node
	camera_node = world_node.camera_node
	if not is_in_group("enemies"):
		add_to_group("enemies")

func _physics_process(delta: float) -> void:
	
	# Melee Player if close.
	if ray_cast_3d.is_colliding():
		var collided_with := ray_cast_3d.get_collider()
		if collided_with.is_in_group("players"):
			if melee_timer.is_stopped():
				melee_timer.start()
				player_node.hurt_screen()

	# Make sprite look at camera.
	placeholder_sprite_3d.look_at(camera_node.global_transform.origin,Vector3(0,1,0))
	if player_node.wish_crouch:
		ray_cast_3d.look_at(player_node.global_transform.origin+Vector3(0,0.5,0),Vector3(0,1,0))
	else:
		ray_cast_3d.look_at(player_node.global_transform.origin+Vector3(0,1,0),Vector3(0,1,0))

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Move towards the player.
	var direction := global_position.direction_to(player_node.global_position)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
