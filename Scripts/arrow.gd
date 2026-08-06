extends Sprite2D

var speed: float = 120.0

func _physics_process(delta: float) -> void:
	global_position += Vector2(1, 0).rotated(rotation) * speed * delta
