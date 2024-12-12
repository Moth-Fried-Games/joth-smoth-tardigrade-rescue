extends Area3D

@onready var block_0: CyclopsBlock = $Block_0
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

var destroyed: bool = false

func _ready() -> void:
	if not is_in_group("doors"):
		add_to_group("doors")
	gpu_particles_3d.emitting = false
	gpu_particles_3d.one_shot = true

func destroy_door() -> void:
	if not destroyed:
		destroyed = true
		gpu_particles_3d.emitting = true
		GameGlobals.audio_manager.create_3d_audio_at_parent("sound_explosion", self)
		block_0.queue_free()
