extends Node3D

@onready var room: DungeonRoom3D = null
@onready var wall_f1: Node3D = $FORWARD/WALL_F
@onready var door__f1: Node3D = $"FORWARD/DOOR?_F"
@onready var wall_f2: Node3D = $FORWARD2/WALL_F
@onready var door__f2: Node3D = $"FORWARD2/DOOR?_F"

@onready var wall_b1: Node3D = $BACK/WALL_B
@onready var door__b1: Node3D = $"BACK/DOOR?_B"
@onready var wall_b2: Node3D = $BACK2/WALL_B
@onready var door__b2: Node3D = $"BACK2/DOOR?_B"

@onready var wall_l1: Node3D = $LEFT/WALL_L
@onready var door__l1: Node3D = $"LEFT/DOOR?_L"
@onready var wall_l2: Node3D = $LEFT2/WALL_L
@onready var door__l2: Node3D = $"LEFT2/DOOR?_L"

@onready var wall_r1: Node3D = $RIGHT/WALL_R
@onready var door__r1: Node3D = $"RIGHT/DOOR?_R"
@onready var wall_r2: Node3D = $RIGHT2/WALL_R
@onready var door__r2: Node3D = $"RIGHT2/DOOR?_R"

@onready var pet_pickup: Area3D = $PetPickup

@onready var enemy_spawner: Node3D = $EnemySpawner
@onready var enemy_spawner_2: Node3D = $EnemySpawner2
@onready var enemy_spawner_3: Node3D = $EnemySpawner3
@onready var enemy_spawner_4: Node3D = $EnemySpawner4

var world_node: Node3D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	room = get_parent()
	room.dungeon_done_generating.connect(setup_room)
	world_node = get_tree().current_scene
	world_node.add_room(get_path())


func setup_room() -> void:
	if room.get_door_by_node(door__f1).get_room_leads_to() != null:
		wall_f1.queue_free()
	else:
		door__f1.queue_free()
	if room.get_door_by_node(door__f2).get_room_leads_to() != null:
		wall_f2.queue_free()
	else:
		door__f2.queue_free()
	if room.get_door_by_node(door__b1).get_room_leads_to() != null:
		wall_b1.queue_free()
	else:
		door__b1.queue_free()
	if room.get_door_by_node(door__b2).get_room_leads_to() != null:
		wall_b2.queue_free()
	else:
		door__b2.queue_free()
	if room.get_door_by_node(door__l1).get_room_leads_to() != null:
		wall_l1.queue_free()
	else:
		door__l1.queue_free()
	if room.get_door_by_node(door__l2).get_room_leads_to() != null:
		wall_l2.queue_free()
	else:
		door__l2.queue_free()
	if room.get_door_by_node(door__r1).get_room_leads_to() != null:
		wall_r1.queue_free()
	else:
		door__r1.queue_free()
	if room.get_door_by_node(door__r2).get_room_leads_to() != null:
		wall_r2.queue_free()
	else:
		door__r2.queue_free()

	if GameGlobals.rng.randf_range(0, 1) >= 0.2:
		enemy_spawner.spawn_amount = GameGlobals.rng.randi_range(1, 2)
		enemy_spawner.spawn_enemy()
	else:
		enemy_spawner.queue_free()
	if GameGlobals.rng.randf_range(0, 1) >= 0.2:
		enemy_spawner_2.spawn_amount = GameGlobals.rng.randi_range(1, 2)
		enemy_spawner_2.spawn_enemy()
	else:
		enemy_spawner_2.queue_free()
	if GameGlobals.rng.randf_range(0, 1) >= 0.2:
		enemy_spawner_3.spawn_amount = GameGlobals.rng.randi_range(1, 2)
		enemy_spawner_3.spawn_enemy()
	else:
		enemy_spawner_3.queue_free()
	if GameGlobals.rng.randf_range(0, 1) >= 0.2:
		enemy_spawner_4.spawn_amount = GameGlobals.rng.randi_range(1, 2)
		enemy_spawner_4.spawn_enemy()
	else:
		enemy_spawner_4.queue_free()
	if GameGlobals.rng.randf_range(0, 1) >= 0.6:
		pet_pickup.queue_free()
	world_node.finish_room(get_path())
