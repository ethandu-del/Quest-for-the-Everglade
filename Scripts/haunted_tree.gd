extends CharacterBody2D

@onready var player = $/root/Game/player
@onready var anim = $AnimatedSprite2D
@export var max_health: int = 4
@export var friction: float = 800
var knockback_velocity: Vector2 = Vector2.ZERO
var health = max_health

var speed = 50

@export var attack_range: float = 300.0
@export var strafe_speed: float = 45.0
var random_move_direction: Vector2 = Vector2.ZERO

@onready var bullet_scene = preload("res://Prefabs/ghost_juice.tscn") 
@export var bullet_count: int = 12 
@export var bullet_speed: float = 150.0

func _process(delta: float) -> void:
	randomize()
	var speed = randi_range(35, 45)

func take_damage():
	health = health - 1
	modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)
	check_is_dead()

func check_is_dead():
	if health == 0 or health < 0:
		remove_from_group("enemies")
		queue_free()

func apply_knockback(from_position: Vector2, force: float) -> void:
	var direction = (global_position - from_position).normalized()
	knockback_velocity = direction * force

func _physics_process(delta: float) -> void:
	
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, friction * delta)
	
	if velocity.x != 0 or velocity.y != 0:
		anim.play("move")
	
	if not player:
		velocity = knockback_velocity
		move_and_slide()
		return

	var distance_to_player = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()

	var move_velocity = Vector2.ZERO

	if distance_to_player > attack_range:
		move_velocity = direction * speed
		random_move_direction = Vector2.ZERO
	else:
		if random_move_direction == Vector2.ZERO:
			pick_random_direction()
		move_velocity = random_move_direction * strafe_speed

	velocity = move_velocity + knockback_velocity

	move_and_slide()

func pick_random_direction():
	var random_angle = randf_range(0, 2 * PI)
	random_move_direction = Vector2.RIGHT.rotated(random_angle)

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
		body.apply_knockback(global_position, 250)
		apply_knockback(player.global_position, 400)

func shoot_ring() -> void:
	var angle_step = TAU / bullet_count
	
	for i in range(bullet_count):
		var angle = i * angle_step
		var bullet = bullet_scene.instantiate()
		
		bullet.global_position = global_position
		
		var direction = Vector2(cos(angle), sin(angle))
		
		if bullet.has_method("setup"):
			bullet.setup(direction * bullet_speed)
			
		get_tree().current_scene.add_child(bullet)
		get_tree().current_scene.move_child(bullet, 1)

func _on_shoot_timer_timeout() -> void:
	shoot_ring()
