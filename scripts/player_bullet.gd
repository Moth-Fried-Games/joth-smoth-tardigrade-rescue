extends Area3D

const SPEED: float = 64.0
var direction: Vector3 = Vector3()
var starting_position: Vector3 = Vector3()

var bullet_hit: bool = false

@onready var life_timer: Timer = $LifeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = starting_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if life_timer.is_stopped():
		queue_free()
	
	global_position.y += direction.y * SPEED * delta
	global_position.x += direction.x * SPEED * delta
	global_position.z += direction.z * SPEED * delta
	
	if has_overlapping_bodies():
		var bodies = get_overlapping_bodies()
		if bodies.size() > 0:
			for body in bodies:
				if body.is_in_group("enemies"):
					if not bullet_hit:
						bullet_hit = true
						body.process_hit()
				elif body.is_in_group("players"):
					pass
				else:
					if not bullet_hit:
						bullet_hit = true
		if bullet_hit:
			queue_free()
