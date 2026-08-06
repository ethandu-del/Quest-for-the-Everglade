extends Area2D

var direction: Vector2
const SPEED = 10
var explosion_scene = preload("res://Prefabs/enemy_explosion.tscn")
@onready var game = $/root/Game

func _physics_process(delta: float) -> void:
	global_position += direction * SPEED


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage()
		body.apply_knockback(global_position, 250)
		game.check_group_count()
		queue_free()
		
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		explosion.emitting = true
		explosion.lifetime = randf_range(0.5, 0.7)
		
		$/root/Game.add_child(explosion)
		$/root/Game.move_child(explosion, 1)
