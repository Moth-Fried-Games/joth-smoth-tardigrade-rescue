extends Area3D

@onready var sprite_3d: Sprite3D = $Sprite3D

# If this is a plushie, use the plushie sprite, otherwise, use the real pet sprite.
@export var plushie: bool = true
var starting_position: Vector3 = Vector3.INF


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if plushie:
		sprite_3d.region_rect.position.x = 0
	else:
		sprite_3d.region_rect.position.x = 128
	if starting_position != Vector3.INF:
		global_position = starting_position
	if not is_in_group("pets"):
		add_to_group("pets")
