extends Node3D

## Spawn Enemies only once, otherwise, Spawn enemies on a Timer. True by Default.
@export var spawn_once: bool = true
## Amount of Time before spawning the next enemy.
@export var spawn_time: float = 3

@export var ground_melee: bool = true
@export var ground_range: bool = true
@export var floating_melee: bool = true
@export var floating_ranged: bool = true
@export var boss: bool = false

var enemy_spawns: Array[Resource] = []

@onready var text_mesh_instance_3d: MeshInstance3D = $TextMeshInstance3D
@onready var body_mesh_instance_3d: MeshInstance3D = $BodyMeshInstance3D
@onready var spawn_timer: Timer = $SpawnTimer

var world_node: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_mesh_instance_3d.visible = false
	body_mesh_instance_3d.visible = false
	world_node = get_tree().current_scene
	spawn_timer.timeout.connect(spawn_timer_timeout)
	if ground_melee:
		enemy_spawns.append(GameGlobals.enemy_resources["Ground Melee"])
	if ground_range:
		enemy_spawns.append(GameGlobals.enemy_resources["Ground Ranged"])
	if floating_melee:
		enemy_spawns.append(GameGlobals.enemy_resources["Floating Melee"])
	if floating_ranged:
		enemy_spawns.append(GameGlobals.enemy_resources["Floating Ranged"])
	if boss:
		enemy_spawns.append(GameGlobals.enemy_resources["Boss"])

func spawn_enemy() -> void:
	if spawn_time > 0:
		spawn_timer.start(spawn_time)
	else:
		spawn_timer_timeout()

func spawn_timer_timeout() -> void:
	var spawn_selection: Resource = enemy_spawns.pick_random()
	var enemy_node = spawn_selection.instantiate()
	enemy_node.starting_position = global_position
	enemy_node.starting_position.x += randf_range(-2.5,2.5)
	enemy_node.starting_position.z += randf_range(-2.5,2.5)
	world_node.add_child(enemy_node)
	if not spawn_once:
		spawn_timer.start()
	else:
		queue_free()
