extends StaticBody2D

const EnemySlime = preload("res://Prefabs/slime.tscn")
const EnemyMushroom = preload("res://Prefabs/mushroom.tscn")
const BOSS = preload("res://Prefabs/stone_boss.tscn")

const ENEMY_POOL = [
	{"scene": EnemySlime, "cost": 10},
	{"scene": EnemyMushroom, "cost": 25}
]

@onready var enemy_spawn_area: CollisionShape2D = $Enemy_spawn_area/Enemy_spawn_area_collision

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
	if body.is_in_group("player"):
		spawn_room_enemies()
		game.enemy_spawn_func()
		self.queue_free()


func spawn_room_enemies():
	var budget = game.level_budget()
	print(budget)
	var min_cost = ENEMY_POOL[0]["cost"]
	
	var spawn_extents = get_spawn_bounds()
	
	while budget >= min_cost:
		var affordable_enemies = []
		for enemy in ENEMY_POOL:
			if enemy["cost"] <= budget:
				affordable_enemies.append(enemy)
		
		var chosen_enemy = affordable_enemies[randi() % affordable_enemies.size()]
		budget -= chosen_enemy["cost"]
		
		instance_enemy_in_bounds(chosen_enemy["scene"], spawn_extents)

func get_spawn_bounds():
	if enemy_spawn_area and enemy_spawn_area.shape is RectangleShape2D:
		var rect_shape = enemy_spawn_area.shape as RectangleShape2D
		var size = rect_shape.size
		var top_left = enemy_spawn_area.global_position - (size / 2.0)
		return Rect2(top_left, size)
	
	return Rect2(global_position, Vector2.ZERO)

func instance_enemy_in_bounds(enemy_scene: PackedScene, bounds: Rect2):
	var enemy_instance = enemy_scene.instantiate()
	
	var padding = 1.0
	var random_x = randf_range(bounds.position.x + padding, bounds.end.x - padding)
	var random_y = randf_range(bounds.position.y + padding, bounds.end.y - padding)
	
	enemy_instance.global_position = Vector2(random_x, random_y)
	
	var parent_node = get_parent()
	
	if parent_node:
		parent_node.add_child(enemy_instance)
		parent_node.move_child.call_deferred(enemy_instance, 0)


func _on_enemy_spawner_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Boss Level Activated")
		game.enemy_spawn_func()
		var boss = BOSS.instantiate()
		boss.global_position = self.global_position
		$/root/Game.add_child(boss)
		$/root/Game.move_child(boss, 1)
		self.queue_free()
