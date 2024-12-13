extends CharacterBody3D

# Movement
const MAX_VELOCITY_AIR: float = 6.0
const MAX_VELOCITY_GROUND: float = 9.0
const MAX_VELOCITY_DASH: float = MAX_VELOCITY_GROUND * 4.0
const MAX_VELOCITY_CROUCH: float = MAX_VELOCITY_GROUND / 2.0
const MAX_ACCELERATION: float = 10 * MAX_VELOCITY_GROUND
const MAX_ACCELERATION_DASH: float = MAX_ACCELERATION * 8
const GRAVITY: float = 15.34
const STOP_SPEED: float = 1.5
const JUMP_IMPULSE: float = sqrt(2 * GRAVITY * 2)
const DIVE_IMPULSE: float = -JUMP_IMPULSE * 4

var friction: float = 4.0
var direction: Vector3 = Vector3()
var dash_dir: Vector3 = Vector3()

# Inputs
var wish_jump: bool = false
var wish_crouch: bool = false
var wish_dash: bool = false
var wish_dive: bool = false

var dive_window: float = 0
var dive_attempt: bool = false
var dive_falling: bool = false
var dive_distance: Vector3 = Vector3()

# Nodes
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var placeholder_sprite_3d: Sprite3D = $PlaceholderSprite3D
@onready var head_node_3d: Node3D = $HeadNode3D
@onready var camera_3d: Camera3D = $HeadNode3D/Camera3D
@onready var dash_timer: Timer = $DashTimer
@onready var stairs_down_ray_cast_3d: RayCast3D = $StairsDownRayCast3D
@onready var stairs_up_ray_cast_3d: RayCast3D = $StairsUpRayCast3D
@onready var melee_area_3d: Area3D = $HeadNode3D/MeleeArea3D
@onready var left_bullet_marker_3d: Marker3D = $HeadNode3D/LeftBulletMarker3D
@onready var right_bullet_marker_3d: Marker3D = $HeadNode3D/RightBulletMarker3D
@onready var target_marker_3d: Marker3D = $HeadNode3D/TargetMarker3D
@onready var pickup_area_3d: Area3D = $HeadNode3D/PickupArea3D

var world_node: Node3D = null

# UI
var ui_player: UIPlayer = null


func _ready() -> void:
	placeholder_sprite_3d.visible = false
	world_node = get_tree().current_scene
	if "player_node" in world_node:
		world_node.player_node = self
		world_node.camera_node = camera_3d
	if not is_in_group("players"):
		add_to_group("players")
	ui_player = UiMain.ui_player
	ui_player.player_node = self


func _input(event):
	# Camera rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_handle_camera_rotation(event)


func _handle_camera_rotation(event: InputEvent):
	# Rotate the camera based on the mouse movement
	rotate_y(deg_to_rad(-event.relative.x * GameGlobals.game_settings.mouse_sensitivity))
	head_node_3d.rotate_x(
		deg_to_rad(-event.relative.y * GameGlobals.game_settings.mouse_sensitivity)
	)

	# Stop the head from rotating to far up or down
	head_node_3d.rotation.x = clamp(head_node_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func process_bullet_hit() -> void:
	if not ui_player.petting_equipped:
		ui_player.hurt_effect()
		ui_player.increase_stress(1)


func process_melee_hit() -> void:
	if not ui_player.petting_equipped:
		ui_player.hurt_effect()
		ui_player.increase_stress(2)


func gun_check(gun_side: bool) -> void:
	var player_bullet = GameGlobals.player_bullet.instantiate()
	if gun_side:
		player_bullet.direction = right_bullet_marker_3d.global_position.direction_to(
			target_marker_3d.global_position
		)
		player_bullet.starting_position = right_bullet_marker_3d.global_position
	else:
		player_bullet.direction = left_bullet_marker_3d.global_position.direction_to(
			target_marker_3d.global_position
		)
		player_bullet.starting_position = left_bullet_marker_3d.global_position
	world_node.add_child(player_bullet)


func punch_check() -> void:
	if melee_area_3d.has_overlapping_bodies():
		var bodies := melee_area_3d.get_overlapping_bodies()
		if bodies.size() > 0:
			for body in bodies:
				if body.is_in_group("enemies"):
					if not body.dead:
						body.process_hit()
						punch_hit_sound()
	if melee_area_3d.has_overlapping_areas():
		var areas := melee_area_3d.get_overlapping_areas()
		if areas.size() > 0:
			for area in areas:
				if area.is_in_group("doors"):
					if is_instance_valid(area):
						if not area.destroyed:
							area.destroy_door()
							punch_hit_sound()


func _physics_process(delta: float) -> void:
	process_input(delta)
	process_stress(delta)
	process_pickup()
	process_movement(delta)

	#if ui_color_rect.color.a != 0.0:
	#ui_color_rect.color.a = lerpf(ui_color_rect.color.a, 0, 0.25)


func process_input(delta: float) -> void:
	direction = Vector3()

	# Movement directions
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backwards"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	# Jumping
	wish_jump = Input.is_action_just_pressed("action_jump")

	# Crouching
	wish_crouch = Input.is_action_pressed("action_crouch")

	# Dashing
	wish_dash = Input.is_action_just_pressed("action_dash")
	if wish_dash and dash_timer.is_stopped():
		dash_dir = direction.normalized()
		dash_timer.start()
		GameGlobals.audio_manager.create_audio("sound_flapdash")
	if dash_timer.is_stopped():
		if camera_3d.fov != 80:
			camera_3d.fov = lerpf(camera_3d.fov, 80, 0.25)
	else:
		if camera_3d.fov != 90:
			camera_3d.fov = lerpf(camera_3d.fov, 90, 0.25)
	# Diving
	if not is_on_floor():
		if not wish_dive and Input.is_action_just_pressed("action_crouch"):
			if dive_attempt:
				if dive_window > 0 and dive_window <= 0.5:
					dive_attempt = false
					wish_dive = true
					dive_window = 0
					dive_distance = global_position
				else:
					dive_attempt = false
					dive_window = 0
			else:
				dive_attempt = true
		if dive_attempt:
			dive_window += delta

	if ui_player.weapons_equipped:
		if Input.is_action_pressed("action_shoot") and not Input.is_action_pressed("action_punch"):
			ui_player.fire_guns()
		elif (
			Input.is_action_pressed("action_punch") and not Input.is_action_pressed("action_shoot")
		):
			ui_player.throw_punch()

	if ui_player.petting_animation_player:
		if Input.is_action_just_pressed("action_shoot"):
			ui_player.pet_left()
		if Input.is_action_just_pressed("action_punch"):
			ui_player.pet_right()


func process_stress(delta: float) -> void:
	if not ui_player.durability >= 666:
		ui_player.increase_stress(delta)


func process_pickup() -> void:
	if pickup_area_3d.has_overlapping_areas():
		var areas = pickup_area_3d.get_overlapping_areas()
		if areas.size() > 0:
			for area in areas:
				if area.is_in_group("pets"):
					if ui_player.weapons_equipped:
						if area.plushie:
							ui_player.switch_to_pet_plushie()
						else:
							ui_player.switch_to_pet_real()
						area.queue_free()


func process_movement(delta: float) -> void:
	# Get the normalized input direction so that we don't move faster on diagonals
	var wish_dir: Vector3 = direction.normalized()

	if not dash_timer.is_stopped():
		velocity = update_velocity_dash(dash_dir, delta)
	else:
		if is_on_floor():
			# If wish_jump is true then we won't apply any friction and allow the
			# player to jump instantly, this gives us a single frame where we can
			# perfectly bunny hop
			if wish_jump:
				if wish_crouch:
					velocity.y = JUMP_IMPULSE * 2
					GameGlobals.audio_manager.create_audio("sound_flapbig")
				else:
					velocity.y = JUMP_IMPULSE
					GameGlobals.audio_manager.create_audio("sound_flap")
				# Update velocity as if we are in the air
				velocity = update_velocity_air(wish_dir, delta)
				wish_jump = false
			else:
				velocity = update_velocity_ground(wish_dir, delta)

		else:
			if wish_jump:
				velocity.y = JUMP_IMPULSE
				GameGlobals.audio_manager.create_audio("sound_flap")
				# Update velocity as if we are in the air
				velocity = update_velocity_air(wish_dir, delta)
				wish_jump = false
			else:
				if dash_timer.is_stopped():
					# Only apply gravity while in the air
					velocity.y -= GRAVITY * delta
					velocity = update_velocity_air(wish_dir, delta)

	# Handle crouch.
	if wish_crouch and is_on_floor():
		if head_node_3d.transform.origin.y != 1:
			head_node_3d.transform.origin.y = lerpf(head_node_3d.transform.origin.y, 0.8, 0.25)
		if collision_shape_3d.shape.height != 1:
			collision_shape_3d.shape.height = lerpf(collision_shape_3d.shape.height, 1, 0.25)
		if collision_shape_3d.position.y != 0.5:
			collision_shape_3d.position.y = lerpf(collision_shape_3d.position.y, 0.5, 0.25)
	elif wish_crouch and not is_on_floor():
		if head_node_3d.transform.origin.y != 1.8:
			head_node_3d.transform.origin.y = lerpf(head_node_3d.transform.origin.y, 1.8, 0.25)
		if collision_shape_3d.shape.height != 1:
			collision_shape_3d.shape.height = lerpf(collision_shape_3d.shape.height, 1, 0.25)
		if collision_shape_3d.position.y != 1.5:
			collision_shape_3d.position.y = lerpf(collision_shape_3d.position.y, 1.5, 0.25)
	else:
		if head_node_3d.transform.origin.y != 1.8:
			head_node_3d.transform.origin.y = lerpf(head_node_3d.transform.origin.y, 1.8, 0.25)
		if collision_shape_3d.shape.height != 2:
			collision_shape_3d.shape.height = lerpf(collision_shape_3d.shape.height, 2, 0.25)
		if collision_shape_3d.position.y != 1:
			collision_shape_3d.position.y = lerpf(collision_shape_3d.position.y, 1, 0.25)

	# Handle Dive
	if wish_dive:
		if not is_on_floor():
			if not dive_falling:
				dive_falling = true
				velocity.y = DIVE_IMPULSE
				GameGlobals.audio_manager.create_audio("sound_flapbig")
		else:
			dive_falling = false
			wish_dive = false

	# Move the player once velocity has been calculated
	if not _snap_up_stairs_check(delta):
		move_and_slide()
		_snap_down_to_stairs_check()


func accelerate(wish_dir: Vector3, max_velocity: float, delta: float):
	# Get our current speed as a projection of velocity onto the wish_dir
	var current_speed: float = velocity.dot(wish_dir)
	# How much we accelerate is the difference between the max speed and the current speed
	# clamped to be between 0 and MAX_ACCELERATION which is intended to stop you from going too fast
	var add_speed: float = clamp(max_velocity - current_speed, 0, MAX_ACCELERATION * delta)

	return velocity + add_speed * wish_dir


func accelerate_dash(wish_dir: Vector3, max_velocity: float, delta: float):
	# Get our current speed as a projection of velocity onto the wish_dir
	var current_speed: float = velocity.dot(wish_dir)
	# How much we accelerate is the difference between the max speed and the current speed
	# clamped to be between 0 and MAX_ACCELERATION which is intended to stop you from going too fast
	var add_speed: float = clamp(max_velocity - current_speed, 0, MAX_ACCELERATION_DASH * delta)

	return velocity + add_speed * wish_dir


func update_velocity_ground(wish_dir: Vector3, delta: float):
	# Apply friction when on the ground and then accelerate
	var speed: float = velocity.length()

	if speed != 0:
		var control: float = max(STOP_SPEED, speed)
		var drop: float = 0.0
		if wish_crouch:
			drop = control * friction * 2 * delta
		else:
			drop = control * friction * delta

		# Scale the velocity based on friction
		velocity *= max(speed - drop, 0) / speed

	if wish_crouch:
		return accelerate(wish_dir, MAX_VELOCITY_CROUCH, delta)
	else:
		return accelerate(wish_dir, MAX_VELOCITY_GROUND, delta)


func update_velocity_air(wish_dir: Vector3, delta: float):
	# Do not apply any friction
	return accelerate(wish_dir, MAX_VELOCITY_AIR, delta)


func update_velocity_dash(wish_dir: Vector3, delta: float):
	# Do not apply any friction
	return accelerate(wish_dir, MAX_VELOCITY_DASH, delta)


const MAX_STEP_HEIGHT = 0.5
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF


func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	# Modified slightly from tutorial. I don't notice any visual difference but I think this is correct.
	# Since it is called after move_and_slide, _last_frame_was_on_floor should still be current frame number.
	# After move_and_slide off top of stairs, on floor should then be false. Update raycast incase it's not already.
	stairs_down_ray_cast_3d.force_raycast_update()
	var floor_below: bool = (
		stairs_down_ray_cast_3d.is_colliding()
		and not is_surface_too_steep(stairs_down_ray_cast_3d.get_collision_normal())
	)
	var was_on_floor_last_frame = Engine.get_physics_frames() == _last_frame_was_on_floor
	if (
		not is_on_floor()
		and velocity.y <= 0
		and (was_on_floor_last_frame or _snapped_to_stairs_last_frame)
		and floor_below
	):
		var body_test_result = KinematicCollision3D.new()
		if (
			self.test_move(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result)
			and (
				body_test_result.get_collider().is_class("StaticBody3D")
				or body_test_result.get_collider().is_class("CSGShape3D")
			)
		):
			# _save_camera_pos_for_smoothing()
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap


func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame:
		return false
	# Don't snap stairs if trying to jump, also no need to check for stairs ahead if not moving
	if self.velocity.y > 0 or (self.velocity * Vector3(1, 0, 1)).length() == 0:
		return false
	var expected_move_motion = self.velocity * Vector3(1, 0, 1) * delta
	var step_pos_with_clearance = self.global_transform.translated(
		expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0)
	)
	# Run a body_test_motion slightly above the pos we expect to move to, towards the floor.
	#  We give some clearance above to ensure there's ample room for the player.
	#  If it hits a step <= MAX_STEP_HEIGHT, we can teleport the player on top of the step
	#  along with their intended motion forward.
	var down_check_result = KinematicCollision3D.new()
	if (
		self.test_move(
			step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT * 2, 0), down_check_result
		)
		and (
			down_check_result.get_collider().is_class("StaticBody3D")
			or down_check_result.get_collider().is_class("CSGShape3D")
		)
	):
		var step_height = (
			(
				(step_pos_with_clearance.origin + down_check_result.get_travel())
				- self.global_position
			)
			. y
		)
		# Note I put the step_height <= 0.01 in just because I noticed it prevented some physics glitchiness
		# 0.02 was found with trial and error. Too much and sometimes get stuck on a stair. Too little and can jitter if running into a ceiling.
		# The normal character controller (both jolt & default) seems to be able to handled steps up of 0.1 anyway
		if (
			step_height > MAX_STEP_HEIGHT
			or step_height <= 0.01
			or (down_check_result.get_position() - self.global_position).y > MAX_STEP_HEIGHT
		):
			return false
		stairs_up_ray_cast_3d.global_position = (
			down_check_result.get_position()
			+ Vector3(0, MAX_STEP_HEIGHT, 0)
			+ expected_move_motion.normalized() * 0.1
		)
		stairs_up_ray_cast_3d.force_raycast_update()
		if (
			stairs_up_ray_cast_3d.is_colliding()
			and not is_surface_too_steep(stairs_up_ray_cast_3d.get_collision_normal())
		):
			# _save_camera_pos_for_smoothing()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false


func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle


func punch_hit_sound() -> void:
	match GameGlobals.rng.randi_range(0, 1):
		0:
			GameGlobals.audio_manager.create_audio("sound_punchhit1")
		1:
			GameGlobals.audio_manager.create_audio("sound_punchhit2")
