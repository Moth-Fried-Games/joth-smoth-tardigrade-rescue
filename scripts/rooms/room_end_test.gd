extends Node3D

@onready var room: DungeonRoom3D = null
@onready var enemy_spawner: Node3D = $EnemySpawner

var world_node: Node3D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	room = get_parent()
	room.dungeon_done_generating.connect(setup_room)
	world_node = get_tree().current_scene
	world_node.add_room(get_path())


func setup_room() -> void:
	enemy_spawner.spawn_enemy()
	world_node.finish_room(get_path())
