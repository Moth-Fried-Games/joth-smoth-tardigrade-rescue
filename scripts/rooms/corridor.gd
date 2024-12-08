extends Node3D

@onready var room: DungeonRoom3D = $"."
@onready var wall_f: Node3D = $FORWARD/WALL_F
@onready var door__f: Node3D = $"FORWARD/DOOR?_F"
@onready var wall_b: Node3D = $BACK/WALL_B
@onready var door__b: Node3D = $"BACK/DOOR?_B"
@onready var wall_l: Node3D = $LEFT/WALL_L
@onready var door__l: Node3D = $"LEFT/DOOR?_L"
@onready var wall_r: Node3D = $RIGHT/WALL_R
@onready var door__r: Node3D = $"RIGHT/DOOR?_R"

var world_node: Node3D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	room.dungeon_done_generating.connect(setup_room)
	world_node = get_tree().current_scene
	world_node.add_room(get_path())


func setup_room() -> void:
	if room.get_door_by_node(door__f).get_room_leads_to() != null:
		wall_f.queue_free()
	else:
		door__f.queue_free()
	if room.get_door_by_node(door__b).get_room_leads_to() != null:
		wall_b.queue_free()
	else:
		door__b.queue_free()
	if room.get_door_by_node(door__l).get_room_leads_to() != null:
		wall_l.queue_free()
	else:
		door__l.queue_free()
	if room.get_door_by_node(door__r).get_room_leads_to() != null:
		wall_r.queue_free()
	else:
		door__r.queue_free()
	world_node.finish_room(get_path())
