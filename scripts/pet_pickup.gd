extends Area3D

# If this is a plushie, use the plushie sprite, otherwise, use the real pet sprite.
@export var plushie: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_in_group("pets"):
		add_to_group("pets")
