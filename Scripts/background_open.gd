extends StaticBody2D

@onready var game : Node2D = $".."
@onready var camera : Camera2D = $"../Camera2D"
var camera_position = global_position

func _on_north_door_entry_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		camera_position = global_position.y
		camera_position -= 652
		camera.move_camera_up((camera_position), 2)


func _on_south_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		camera_position = global_position.y
		camera_position += 652
		camera.move_camera_up((camera_position), 2)


func _on_enemy_spawn_body_entered(body: CharacterBody2D) -> void:
	self.queue_free()
	
	game.enemy_spawn_func(global_position)
	
	
