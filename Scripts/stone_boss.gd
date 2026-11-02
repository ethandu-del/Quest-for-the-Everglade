extends CharacterBody2D

@onready var player = $/root/Game/player
@onready var anim = $AnimatedSprite2D
@onready var camera = $/root/Game/Camera2D
@onready var game = $/root/Game

@export var max_health: int = 40
@export var friction: float = 800

var health = max_health

const EnemySlime = preload("res://Prefabs/slime.tscn")
const EnemyMushroom = preload("res://Prefabs/mushroom.tscn")
const EnemyHaunted_Tree = preload("res://Prefabs/haunted_tree.tscn")

const ENEMY_POOL = [
	{"scene": EnemySlime, "cost": 10},
	{"scene": EnemyMushroom, "cost": 25},
	{"scene": EnemyHaunted_Tree, "cost": 35}
]

@onready var enemy_spawn_area: CollisionShape2D = $mini_enemy_spawn_area/CollisionShape2D

const BULLET = preload("res://Prefabs/boss_bullet.tscn")
@onready var shoot_timer: Timer = $shoot_cooldown
var is_shooting_cooldown: bool = true
var is_enemy_phase: bool = false
var is_enemy_phase_going: bool = false
var is_dead: bool = false

func _ready() -> void:
	shoot_timer.start()

func _physics_process(delta: float) -> void:
	attempt_to_shoot(player)
	var remaining_ememies = get_tree().get_nodes_in_group("enemies")
	if is_enemy_phase_going and is_enemy_phase and remaining_ememies.size() == 1:
		enemy_phase()

func take_damage():
	if is_enemy_phase_going == false and not is_dead:
		health = health - 1
		modulate = Color(1, 0, 0)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)
		check_is_dead()
		
		if health == 30 or health == 20 or health == 10:
			enemy_phase()
	
func check_is_dead():
	if health == 0 or health < 0:
		is_dead = true
		print("is dead")
		anim.play("death")
		

func apply_knockback(from_position: Vector2, force: float):
	pass

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
		body.apply_knockback(global_position, 250)

func attempt_to_shoot(target):
	if not is_shooting_cooldown and not is_enemy_phase_going and not is_dead:
		is_shooting_cooldown = true
		shoot_timer.start()
		anim.play("attack_ranged")
		
func _on_shoot_cooldown_timeout() -> void:
	is_shooting_cooldown = false
	
func spawn_bullet(target) -> void:
	var bullet = BULLET.instantiate()
	get_tree().current_scene.add_child(bullet)
	get_tree().current_scene.move_child(bullet, 1)
	
	bullet.global_position = global_position
	
	var dir = (target.global_position - global_position).normalized()
	bullet.direction = dir
	bullet.rotation = dir.angle()

func enemy_phase():
	if not is_enemy_phase:
		is_enemy_phase_going = true
		anim.play("enemy_phase_initiate")
		self.set_process(false)
	else:
		is_enemy_phase = false
		anim.play("enemy_phase_finish")
		self.set_process(true)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "enemy_phase_finish":
		is_enemy_phase_going = false
	if anim.animation == "enemy_phase_initiate":
		spawn_room_enemies()
		is_enemy_phase = true
	if anim.animation == "attack_ranged":
		spawn_bullet(player)
		camera.add_trauma(0.2)
	if anim.animation == "death":
		print("boss_dead")
		remove_from_group("enemies")
		GameManager.boss_defeated = true
		game.level_beat()
		queue_free()

func spawn_room_enemies():
	var budget = 0
	match GameManager.difficulty_level:
		1: budget = 80
		2: budget = 100
		3:budget = 120
		4: budget = 10
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
