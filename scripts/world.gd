extends Node3D

@onready var navigation_region_3d: NavigationRegion3D = $NavigationRegion3D
@onready var dungeon_generator_3d: DungeonGenerator3D = $NavigationRegion3D/DungeonGenerator3D

var player_node: CharacterBody3D = null
var camera_node: Camera3D = null

var dungeon_ready: bool = false
var rooms_list: Dictionary = {}
var rooms_ready: bool = false
var navigation_ready: bool = false
var world_ready: bool = false


func _ready() -> void:
	if is_instance_valid(navigation_region_3d):
		navigation_region_3d.bake_finished.connect(_on_navigation_region_3d_bake_finished)
	if is_instance_valid(dungeon_generator_3d):
		dungeon_generator_3d.done_generating.connect(_on_dungeon_generator_3d_done_generating)
		dungeon_generator_3d.generating_failed.connect(_on_dungeon_generator_3d_generating_failed)
		dungeon_generator_3d.generate()


func _process(_delta: float) -> void:
	if dungeon_ready:
		while not rooms_ready:
			rooms_ready = true
			for room in rooms_list.keys():
				if not rooms_list[room]:
					rooms_ready = false
			if rooms_ready:
				#await get_tree().create_timer(0.1).timeout
				navigation_region_3d.bake_navigation_mesh()
			await get_tree().process_frame
	if not world_ready:
		if dungeon_ready and rooms_ready and navigation_ready:
			world_ready = true
			GameGlobals.in_world = true
			UiMain.ui_transitions.toggle_transition(false)
			UiMain.ui_player.initialize()


func _on_dungeon_generator_3d_done_generating() -> void:
	dungeon_ready = true


func _on_dungeon_generator_3d_generating_failed() -> void:
	dungeon_ready = false
	dungeon_generator_3d.generate()


func _on_navigation_region_3d_bake_finished() -> void:
	navigation_ready = true


func add_room(room_path: String) -> void:
	rooms_list[room_path] = false


func finish_room(room_path: String) -> void:
	rooms_list[room_path] = true
