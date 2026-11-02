extends CharacterBody2D

@onready var player = $/root/Game/player
@onready var anim = $AnimatedSprite2D
const SPORE = preload("res://Prefabs/spore.tscn")
@onready var timer: Timer = $Shoot_timer
var is_shooting_cooldown: bool = false

@export var speed: float = 50.0
@export var attack_range: float = 400.0


@export var max_health: int = 4
@export var friction: float = 800
var knockback_velocity: Vector2 = Vector2.ZERO
var health = max_health

@export var strafe_speed: float = 40.0
var random_move_direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, friction * delta)
	
	if velocity.x != 0 or velocity.y != 0:
		anim.play("Walk")
	
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
		attempt_to_shoot(player)

	velocity = move_velocity + knockback_velocity

	move_and_slide()

func pick_random_direction():
	var random_angle = randf_range(0, 2 * PI)
	random_move_direction = Vector2.RIGHT.rotated(random_angle)

func attempt_to_shoot(target) -> void:
	if not is_shooting_cooldown:
		is_shooting_cooldown = true
		timer.start()
		spawn_spore(target)

func spawn_spore(target) -> void:
	var spore = SPORE.instantiate()
	get_tree().current_scene.add_child(spore)
	get_tree().current_scene.move_child(spore, 1)
	
	spore.global_position = global_position
	
	var dir = (target.global_position - global_position).normalized()
	spore.direction = dir
	spore.rotation = dir.angle()
	
	apply_knockback(player.global_position, 200)

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
	knockback_velocity = direction * (force / 2)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
		body.apply_knockback(global_position, 150)
		apply_knockback(player.global_position, 400)


func _on_shoot_timer_timeout() -> void:
	is_shooting_cooldown = false
	pick_random_direction()
