extends Area2D

var direction: Vector2 = Vector2.ZERO
@export var speed: float = 600.0

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
		body.apply_knockback(global_position, 100)
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
